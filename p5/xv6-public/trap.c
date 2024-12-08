#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"
#include "traps.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "fs.h"
#include "file.h"

// Interrupt descriptor table (shared by all CPUs).
struct gatedesc idt[256];
extern uint vectors[];  // in vectors.S: array of 256 entry pointers
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);

  initlock(&tickslock, "time");
}

void
idtinit(void)
{
  lidt(idt, sizeof(idt));
}

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(myproc()->killed)
      exit();
    myproc()->tf = tf;
    syscall();
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
    break;
  //////////////////////////////////////////////////////////////////////////////////////
  // Page Fault generated, allocate a physical page and let the user resume execution //
  //////////////////////////////////////////////////////////////////////////////////////
  case T_PGFLT: // T_PGFLT = 14
    // Get faulting address
    uint faulting_addr = rcr2();

    // Check if the faulting address is part of a valid memory mapping
    struct proc *p = myproc();
    if (p == 0) {
        break;
    }
    
    uint found_index = valid_memory_mapping_index(p, faulting_addr);
    pte_t *pte = walkpgdir(p->pgdir, (void*)faulting_addr, 0);
    uint pa = PTE_ADDR(*pte);
    uint flags = PTE_FLAGS(*pte);

    // Copy on write fault
    if(flags & PTE_COW && flags & PTE_P) {
      // alloc new page to copy the old page to
      char *new_page = kalloc();
      if (!new_page) {  // allocation failed
        p->killed = 1;
        break;
      }

      // copy old page to new page
      memmove(new_page, (char*)P2V(pa), PGSIZE);

      // Clear the COW flag for the faulting process
      *pte = V2P(new_page) | PTE_W | PTE_U | PTE_P;

      // Flush the TLB
      lcr3(V2P(p->pgdir));

      // free the old page 
      kfree((char*)P2V(pa));
    } 
    ///////////////////////////////////
    // Otherwise, WMAP related fault //
    ///////////////////////////////////
    else if (found_index >= 0 && found_index < MAX_NUM_WMAPS) { // lazy allocation
      // struct of region for easy data access
      struct wmap_region *region = &p->wmap_regions[found_index];
      uint page_addr = PGROUNDDOWN(faulting_addr); // page-aligned VA
      ////////////////
      // wmap Logic //
      ////////////////
      char *new_page = kalloc();  // allocate physical page
      if (!new_page) {  // allocation failed
        p->killed = 1;
        break;
      }

      ///////////////////////
      // Anonymous mapping //
      ///////////////////////
      if (region->flags & MAP_ANONYMOUS) { 
        // Clear the page
        memset(new_page, 0, PAGE_SIZE);
      } 
      
      /////////////////////////
      // File-backed mapping //
      /////////////////////////
      else { 
        // Read the page from the file
        region->file->off = page_addr - region->addr;
        if (fileread(region->file, new_page, PAGE_SIZE) > PAGE_SIZE) {
          panic("file read");
          kfree(P2V(new_page));
          p->killed = 1;
          break;
        }
      }

      // Map the populated page to the faulting address
      if (mappages(p->pgdir, (void*)page_addr, PAGE_SIZE, V2P(new_page), PTE_W | PTE_U | PTE_P) < 0) {
        panic("mappages");
        kfree(P2V(new_page));
        p->killed = 1;
        break;
      }

      region->n_loaded_pages++; // increment num pages
    } 
    ////////////////////////
    // Segmentation fault //
    ////////////////////////
    else {
        cprintf("Segmentation Fault\n");
        // kill the process
        myproc()->killed = 1;
    }
    break;

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
}
