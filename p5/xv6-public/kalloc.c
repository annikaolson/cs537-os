// Physical memory allocator, intended to allocate
// memory for user processes, kernel stacks, page table pages,
// and pipe buffers. Allocates 4096-byte pages.

#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "spinlock.h"

void freerange(void *vstart, void *vend);
extern char end[]; // first address after kernel loaded from ELF file
                   // defined by the kernel linker script in kernel.ld

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  int use_lock;
  struct run *freelist;
} kmem;

char ref_count[PFN_MAX];
struct spinlock ref_count_lock;

// Initialize the reference count array
void init_refcount() {
  initlock(&ref_count_lock, "ref_count_lock");
  for (int i = 0; i < PFN_MAX; i++) {
    ref_count[i] = 0;
  }
}

// Increment the reference count for a physical page
void incr_refcount(uint paddr) {
  // Only increment if after kinit2
  if(kmem.use_lock){
    int page_idx = paddr / PGSIZE;
    if (page_idx < PFN_MAX) {
      acquire(&ref_count_lock);
      ref_count[page_idx]++;
      release(&ref_count_lock);
    }
  }
}

// Decrement the reference count for a physical page
void dec_refcount(uint paddr) {
  int page_idx = paddr / PGSIZE;
  if (page_idx < PFN_MAX) {
    acquire(&ref_count_lock);
    if (ref_count[page_idx] > 0) {
        ref_count[page_idx]--;
    }
    release(&ref_count_lock);
  }
}

// Function to get the reference count for a specific physical page
int get_refcount(uint paddr) {
  int page_idx = paddr / PGSIZE;
  if (page_idx < PFN_MAX) {
    return ref_count[page_idx];
  }
  return -1;
}

// Initialization happens in two phases.
// 1. main() calls kinit1() while still using entrypgdir to place just
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
  initlock(&kmem.lock, "kmem");
  kmem.use_lock = 0;
  freerange(vstart, vend);
}

void
kinit2(void *vstart, void *vend)
{
  freerange(vstart, vend);
  kmem.use_lock = 1;
  init_refcount();
}

void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
    kfree(p);
}
//PAGEBREAK: 21
// Free the page of physical memory pointed at by v,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
  struct run *r;
  uint pa = V2P(v);

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
    panic("kfree");


  if(kmem.use_lock){
    // Decrement the reference amount
    dec_refcount(pa);
    
    // Acquire the lock
    acquire(&kmem.lock);
  }

  // Only free the page when the reference count reaches 0
  if (get_refcount(pa) == 0){
    // Fill with junk to catch dangling refs.
    memset(v, 1, PGSIZE);
    r = (struct run*)v;
    r->next = kmem.freelist;
    kmem.freelist = r;
  }
  if(kmem.use_lock)
      release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
  struct run *r;

  if(kmem.use_lock)
    acquire(&kmem.lock);
  r = kmem.freelist;
  if(r)
    kmem.freelist = r->next;
  if(kmem.use_lock)
    release(&kmem.lock);
  return (char*)r;
}

