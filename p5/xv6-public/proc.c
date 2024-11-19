#include "types.h"
#include "defs.h"
#include "param.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "fs.h"
#include "mmu.h"
#include "memlayout.h"
#include "x86.h"
#include "proc.h"
#include "file.h"

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
}

// Must be called with interrupts disabled
int
cpuid() {
  return mycpu()-cpus;
}

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
  int apicid, i;
  
  if(readeflags()&FL_IF)
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
}

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
  struct cpu *c;
  struct proc *p;
  pushcli();
  c = mycpu();
  p = c->proc;
  popcli();
  return p;
}

//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;

  ////////////////////////////////////////////////////////
  // Initialize wmap regions struct and wmap_count to 0 //
  ////////////////////////////////////////////////////////
  p->wmap_count = 0;
  memset(p->wmap_regions, 0, sizeof(p->wmap_regions));

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
  
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);

  p->state = RUNNABLE;

  release(&ptable.lock);
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  struct proc *curproc = myproc();

  sz = curproc->sz;
  if(n > 0){
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  curproc->sz = sz;
  switchuvm(curproc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  /*
  // copy the process size
  np->sz = curproc->sz;

  // allocate and set up a page directory for the child process
  if ((np->pgdir = setupkvm()) == 0) {
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }

  // copy parent's page table and mark shared pages as COW
  for (uint va = 0; va < curproc->sz; va += PGSIZE) {
    pte_t *pte = walkpgdir(curproc->pgdir, (void *)va, 0);  // pte of parent
    if (!pte || !(*pte & PTE_P)) {
      continue; // unmapped page, skip
    }

    // get pa and flags of parent from pte
    uint pa = PTE_ADDR(*pte);
    uint flags = PTE_FLAGS(*pte);

    // mark writable pages as COW
    if (flags & PTE_W) {
      flags &= ~PTE_W;    // remove write permission
      flags |= PTE_COW;   // add COW flag
      *pte = pa | flags;  // update parent's pte
    }

    // maps same physical page in child's page table
    if (mappages(np->pgdir, (void *)va, PGSIZE, pa, flags) < 0) {
      freevm(np->pgdir);
      np->state = UNUSED;
      return -1;
    }

    increment_ref_count(pa);

  }*/

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
  np->parent = curproc;
  *np->tf = *curproc->tf;

  // Mark the parent’s pages as read-only in both parent and child page tables
    // so we can trigger a page fault on write
    for(i = 0; i < curproc->sz; i += PGSIZE){
        pte_t *pte = walkpgdir(np->pgdir, (void*)i, 0);
        if (pte && (*pte & PTE_P)) {
            // Mark the page as read-only (COW)
            *pte &= ~PTE_W;  // remove write access
            *pte |= PTE_COW; // set COW flag
            // Increment reference count for the shared page (if COW)
            increment_ref_count(PTE_ADDR(*pte));
        }
    }

    // Set up the kernel stack for the child process
    if((np->kstack = kalloc()) == 0) {
        freevm(np->pgdir);
        kfree(np->kstack);
        return -1;
    }

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));

  pid = np->pid;

  acquire(&ptable.lock);

  np->state = RUNNABLE;

  release(&ptable.lock);

  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  struct proc *curproc = myproc();
  struct proc *p;
  int fd;

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd]){
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(curproc->cwd);
  end_op();
  curproc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == curproc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != curproc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        p->state = UNUSED;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
  }
}

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();
  c->proc = 0;
  
  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
      switchuvm(p);
      p->state = RUNNING;

      swtch(&(c->scheduler), p->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);

  }
}

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = mycpu()->intena;
  swtch(&p->context, mycpu()->scheduler);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
  myproc()->state = RUNNABLE;
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  if(p == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }
  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}

//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}

//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}

// Helper method for wmap
//
// Returns: 
//  Success: the starting virtual address of the memory
//  Fail: FAILED
int wmap_helper(uint addr, int length, int flags, int fd){

  struct proc *p = myproc();  // get current process
  struct file *f = p->ofile[fd];
  
  //////////////////////////////
  // Check validity of inputs //
  //////////////////////////////

  // Addr must a multiple of page size and within 0x60000000 and 0x80000000
  if (addr % PAGE_SIZE != 0 || addr < 0x60000000 || addr >= 0x80000000) {
    // Address not page-aligned or out of allowed range
    return FAILED;
  }

  // length must be greater than 0
  if (length <= 0) {
    // Invalid mapping length
    return FAILED;
  }

  // MAP_SHARED: Flag that tells wmap that the mapping is shared
  // MAP_FIXED: Flag that declares that the mapping MUST be placed at exactly addr
  // Return error if MAP_SHARED and MAP_FIXED not set
  if (!(flags & MAP_SHARED) || !(flags & MAP_FIXED)) {
    // MAP_SHARED or MAP_FIXED flags not set
    return FAILED;
  }

  // MAP_ANONYMOUS: Flag that this is NOT a file-backed mapping, if set ignore fd
  // Otherwise assume fd belongs to a file of type FD_INODE and was opened in O_RDRW mode
  // File-backed mapping: expect the map size to be equal to the file size
  if (!(flags & MAP_ANONYMOUS)){
    // file-backed mapping
    if (fd < 0 || fd >= NOFILE) {
      return FAILED;  // invalid fd
    }

    // retrieve file pointer
    if (!f) {
      return FAILED;  // file not open
    }

    // ensure file is readable and writable
    if (!(f->readable && f->writable)) {
      return FAILED;
    }

    // make sure file is of type INODE
    if (f->type != FD_INODE) {
      return FAILED;
    }

    filedup(f);

    ilock(f->ip);
    if (length > f->ip->size) {
      iunlock(f->ip);
      fileclose(f);
      return FAILED;  // Mapping length exceeds file size
    }
    iunlock(f->ip);  // Unlock the inode

  } else {  // anonymous, no file-backed mapping
    fd = -1;  // ignore fd
  }

  ///////////////////////////////////////////////////////
  // Check if we hit the maximum number of memory maps //
  ///////////////////////////////////////////////////////
  acquire(&ptable.lock);

  // Check if we allocate any more memory maps
  if (p->wmap_count >= MAX_NUM_WMAPS){
    // Cannot allocate any more maps
    release(&ptable.lock);
    return FAILED;
  }

  /////////////////////////////////////////
  // Check for overlapping memory regions//
  /////////////////////////////////////////
  uint new_map_end = addr + length;
  for (int i = 0; i < p->wmap_count; i++) {
    uint region_start = p->wmap_regions[i].addr;
    uint region_end = region_start + p->wmap_regions[i].length;

    // check if the new mapping overlaps with an existing one
    if (!(new_map_end <= region_start || addr >= region_end)) {
      release(&ptable.lock);
      return FAILED;
    }
  }

  ////////////////////////////////////////////////////////////////////////
  // Lazy Allocation:                                                   //
  // Don't actually allocate any physical pages when wmap is called     //
  // Instead, keep track of the allocated region using some structure   //
  // i.e. "remember" the mappings for the process                       //
  // Most important to track: virtual address and length of the mapping //
  ////////////////////////////////////////////////////////////////////////

  // Track the mapping in `wmap_regions`
  struct wmap_region *region = &p->wmap_regions[p->wmap_count];
  region->addr = addr;
  region->length = length;
  region->flags = flags;
  region->fd = fd;
  region->file = f;
  p->wmap_count++;

  release(&ptable.lock);

  // Success: the starting virtual address of the memory
  return addr;
}


// Helper function called by kernel to check if valid memory mapping
// Success: returns wmap region index
// Fail: returns -1
int valid_memory_mapping_index(struct proc *p, uint faulting_addr){
  acquire(&ptable.lock);
  // Iterate through the process's memory regions (wmap_regions)
  for (int i = 0; i < p->wmap_count; i++) {
    uint start_addr = p->wmap_regions[i].addr;
    int length = p->wmap_regions[i].length;

    // Check if the faulting address is within the bounds of this memory region
    if (faulting_addr >= start_addr && faulting_addr < start_addr + length) {
      // Success
      release(&ptable.lock);
      return i;
    }
  }

  // Fail: address not found within bounds
  release(&ptable.lock);
  return -1;
}

// helper function for wunmap
// returns 0 upon success, -1 upon fail 
int wunmap_helper(uint addr) {
  struct proc *p = myproc();  // current process
  int region_index = -1;

  acquire(&ptable.lock);
  // find mapping starting at addr
  for (int i = 0; i < p->wmap_count; i++) {
    if (p->wmap_regions[i].addr == addr) {
      region_index = i; // found region to unmap
      break;
    }
  }

  // no mapping found
  if (region_index == -1) {
    release(&ptable.lock);
    return FAILED;
  }

  // struct of region for easy data access
  struct wmap_region *region = &p->wmap_regions[region_index];

  release(&ptable.lock);

  if (!(region->flags & MAP_ANONYMOUS)) {
    struct file *f = region->file;

    // Validate file
    if (!f || f->type != FD_INODE || !(f->readable && f->writable)) {
      fileclose(f);
      return FAILED;  // Invalid file/not writable or readable
    }

    // For each page in the region, write back changes to the file
    for (uint va = region->addr; va < region->addr + region->length; va += PAGE_SIZE) {
      pte_t *pte = walkpgdir(p->pgdir, (void *)va, 0);  // Get PTE for page
      if (pte && (*pte & PTE_P)) {  // Page exists in memory
        uint physical_addr = PTE_ADDR(*pte);
        char *mem = (char*)P2V(physical_addr);

        begin_op();
        ilock(f->ip);  // Lock inode to modify
        // Write page content back to file (use the correct offset)
        if (writei(f->ip, mem, va - region->addr, PAGE_SIZE) > PAGE_SIZE) {
          iunlock(f->ip);  // Unlock inode if the write fails
          end_op();  // End the operation (release file system locks)
          fileclose(f);
          return FAILED;
        }
        iunlock(f->ip);
        end_op();
      }
    }
    fileclose(f);  // Close file after operation
  }

  acquire(&ptable.lock);

  // remove mapping from page table
  for (uint curr_addr = region->addr; curr_addr < region->addr + region->length; curr_addr += PAGE_SIZE) {
    // Calculate the page directory index and page table index
    uint pdx = PDX(curr_addr);
    uint ptx = PTX(curr_addr);

    // Get the page table entry from the page directory (pgdir)
    pde_t *pde = &p->pgdir[pdx];  // Get the page directory entry for the address
    if (*pde & PTE_P) {  // Check if the page directory entry is present
      pte_t *pt = (pte_t*)P2V(PTE_ADDR(*pde));  // Get the physical address of the page table
      pte_t *pte = &pt[ptx];  // Get the page table entry for the address

      if (*pte & PTE_P) {  // Check if the page table entry is valid and page is present in memory
        uint physical_addr = PTE_ADDR(*pte);  // Get physical address from the PTE
        kfree(P2V(physical_addr));  // Free the physical page mapped to this virtual address
      }
      *pte = 0;  // Clear the PTE (unmap the page)
    }
  }

  // remove mapping from proc's memory regions
  for (int i = region_index; i < p->wmap_count - 1; i++) {
    p->wmap_regions[i] = p->wmap_regions[i + 1];
  }

  p->wmap_regions[p->wmap_count-1].addr = 0;
  p->wmap_regions[p->wmap_count-1].length = 0;
  p->wmap_regions[p->wmap_count-1].flags = 0;
  p->wmap_regions[p->wmap_count-1].file = 0;
  p->wmap_regions[p->wmap_count-1].fd = 0;
  p->wmap_regions[p->wmap_count-1].n_loaded_pages = 0;
  p->wmap_count--;

  lcr3(V2P(p->pgdir));

  release(&ptable.lock);
  return SUCCESS;

}

int getwmapinfo_helper(struct proc *p, struct wmapinfo *wminfo) {
  // initialize wminfo struct
  memset(wminfo, 0, sizeof(struct wmapinfo));

  acquire(&ptable.lock);

  // iterate over active memory mappings
  for (int i = 0; i < p->wmap_count && i < MAX_WMMAP_INFO; i++) {
    // get address and length
    wminfo->addr[i] = (uint)p->wmap_regions[i].addr;
    wminfo->length[i] = p->wmap_regions[i].length;

    // count loaded pages for this region
    int loaded_pages = 0;
    for (uint va = wminfo->addr[i]; va < wminfo->addr[i] + wminfo->length[i]; va += PAGE_SIZE) {
      pte_t *pte = walkpgdir(p->pgdir, (void *)va, 0);  // get pte for page
      if (pte && (*pte & PTE_P)) {  // pte exists
        loaded_pages++;
      }
    }
    wminfo->n_loaded_pages[i] = loaded_pages;
  }

  // set total number of memory mappings
  wminfo->total_mmaps = p->wmap_count;
  
  release(&ptable.lock);

  // success
  return SUCCESS;
}
