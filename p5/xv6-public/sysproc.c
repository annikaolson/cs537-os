#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "wmap.h"

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
//  Success: the starting virtual address of the memory on success
//  Fail: FAILED
int 
sys_wmap(void){
  uint addr; // mapping placed at exactly addr, MAP_FIXED flag must be set
  int length; // the length of the mapping in bytes, greater than 0
  int flags; // file descriptor for the file to be mapped if file-backed mapping, can be ORed together
  int fd; // the kind of memory mapping you're requesting for, ignored if MAP_ANONYMOUS flag set

  // Addr must a multiple of page size and within 0x60000000 and 0x80000000


  // length must be greater than 0


  // MAP_SHARED: Flag that tells wmap that the mapping is shared
  //             Return error if not set


  // MAP_FIXED: Flag that declares that the mapping MUST be placed at exactly addr
  //            Return error if not set



  // Lazy allocation: Don't actually allocate any physical pages when wmap is called
  // Instead, keep track of the allocated region using some structure 
  // i.e. "remember" the mappings for the process
  // Most important to track: virtual address and length of the mapping


  //  Success: return the starting virtual address of the memory on success
  return 0;
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

  return 0;
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

  return SUCCESS;
}