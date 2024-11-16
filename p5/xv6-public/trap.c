#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"
#include "traps.h"
#include "spinlock.h"

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

    // Check that process exists
    struct proc *p = myproc();
    if (p == 0) {
      // error handle this case, break? panic?
      break;
    }

    // Check if the faulting address is part of a valid memory mapping
    int found_index = valid_memory_mapping_index(p, faulting_addr);

    if (found_index >= 0 && found_index < MAX_NUM_WMAPS) { // lazy allocation
      // struct of region for easy data access
      struct wmap_region *region = &p->wmap_regions[found_index];

      // page aligned virtual address for the start and end of the region
      uint region_start = PGROUNDDOWN(region->addr);
      uint region_end = PGROUNDDOWN(region->addr + region->length);

      // allocate and map all missing pages in the region that the page fault occured
      while (region_start < region_end) {
        // allocate a physical page
        char *new_page = kalloc();
        if (!new_page) {
          // allocation failed
          p->killed = 1;
          break;
        }

        // Anonymous mapping
        if (region->flags & MAP_ANONYMOUS) { 
          // clear the page
          memset(new_page, 0, PAGE_SIZE);
        } 
        // File-Backed Mapping: create a memory representation of a file
        else {
          struct file *file = p->ofile[region->fd];
          if (!file || fileread(f, new_page, PAGE_SIZE) != PAGE_SIZE) {
            // reading from file failed
            kfree(new_page);
            p->killed = 1;
            break;
          }
        }

        // map the page
        if (mappages(p->pgdir, region_start, PAGE_SIZE, V2P(new_page), PTE_W | PTE_U) < 0) {
          // mapping failed
          kfree(new_page);
          p->killed = 1;
          break;
        }

        region->n_loaded_pages++;  // increment the number of loaded pages
        region_start += PAGE_SIZE; // move to the next page
      }
    }
    // Page fault address is not a part of a mapping
    else {
      cprintf("Segmentation Fault\n");
      // Kill the process
      p->killed = 1;
    }

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
