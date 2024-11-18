#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return myproc()->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

// uint wmap(uint addr, int length, int flags, int fd);
// Memory management system call
//
// Memory Allocation Modes:
//  1. Anonymous: similar to malloc
//  2. File-Backed Mapping: create a memory representation of a file
// 
// Returns: 
//  Success: the starting virtual address of the memory
//  Fail: FAILED
int 
sys_wmap(void){
  uint addr; // mapping placed at exactly addr, MAP_FIXED flag must be set
  int length; // the length of the mapping in bytes, greater than 0
  int flags; // file descriptor for the file to be mapped if file-backed mapping, can be ORed together
  int fd; // the kind of memory mapping you're requesting for, ignored if MAP_ANONYMOUS flag set

  ////////////////
  // Get inputs //
  ////////////////
  if (argint(0, (int*)&addr) < 0){
    // Failed to retrieve addr
    return FAILED;
  }
  if (argint(1, &length) < 0){
    // Failed to retrieve length
    return FAILED;
  }
  if (argint(2, &flags) < 0){
    // Failed to retrieve flags
    return FAILED;
  }
  if (argint(3, &fd) < 0){
    // Failed to retrieve fd
    return FAILED;
  }

  // Success: return the starting virtual address of the memory on success
  // Fail: return FAILED
  return wmap_helper(addr, length, flags, fd);
}

// int wunmap(uint addr);
// Removes the mapping starting at addr from the process virtual address space
//
// Returns:
//  Success: SUCCESS
//  Fail: FAILED
int 
sys_wunmap(void){
  uint addr;

  ///////////////
  // Get input //
  ///////////////
  if (argint(0, (int*)&addr) < 0){
    // Failed to retrieve addr
    return FAILED;
  }
  
  //return wunmap_helper(addr);
  return SUCCESS;
}

// uint va2pa(uint va);
// Translate a virtual address according to the page table for the calling process
//
// Returns:
//  Success: the physical address on success
//  Fail: -1
uint 
sys_va2pa(void){
  uint va;
  pte_t *pte;
  uint pa;

  ///////////////
  // Get input //
  ///////////////
  if (argint(0, (int*)&va) < 0){
    // Failed to retrieve addr
    return FAILED;
  }

  // get PTE for virtual address
  pte = walkpgdir(myproc()->pgdir, (void *)va, 0);
  if (pte == 0 || !(*pte & PTE_P)) {
      return -1;  // invalid translation or not present
  }
  // get physical address from PTE
  pa = PTE_ADDR(*pte) | (va & 0xFFF); // page base addr with offset

  return pa;
}

// int getwmapinfo(struct wmapinfo *wminfo);
// retrieves information about the process address space by populating struct wmapinfo
//
// Returns:
//  Success: SUCCESS
//  Fail: FAILED
int 
sys_getwmapinfo(){
  struct wmapinfo *wminfo;
  ///////////////
  // Get input //
  ///////////////
  if (argptr(0, (char **)&wminfo, sizeof(*wminfo)) < 0) {
    // Failed to retrieve the pointer to wmapinfo
    return FAILED;
  }

  // initialize wmapinfo struct
  memset(wminfo, 0, sizeof(struct wmapinfo));

  return getwmapinfo_helper(myproc(), wminfo);
}