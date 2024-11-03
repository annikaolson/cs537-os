#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

#define MAX_TICKETS 1<<5
#define MIN_TICKETS 1

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

// allow a process to set its own number of ticketes
int
sys_settickets(void) {
  // retrive arg n
  int n;
  if (argint(0, &n) < 0) {
    return -1;
  }

  // if the process tries to set a value lower than the
  // minimum amount of tickets, the number of tickets is
  // set to the default of 8
  if (n < MIN_TICKETS) {
    n = 8;
  } else if (n > MAX_TICKETS) {
    n = MAX_TICKETS;
  }

  // Call update tickets helper function
  struct proc *p = myproc();
  update_tickets(p, n);

  return 0;
}

// Retrieve scheduling information for all processes
int
sys_getpinfo(void) {
  // retrieve pstat ptr
  struct pstat *pstat;
  if(argptr(0, (void*)&pstat, sizeof(*pstat)) < 0) {
    return -1;
  }

  // Fill pstat with information on all processes
  // from the process table
  fill_pstat(pstat);

  return 0;
}
