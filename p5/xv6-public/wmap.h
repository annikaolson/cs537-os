////////////////
// GIVEN CODE //
////////////////
#ifndef WMAP
#define WMAP

// Flags for wmap
#define MAP_SHARED 0x0002
#define MAP_ANONYMOUS 0x0004
#define MAP_FIXED 0x0008

// When any system call fails, returns -1
#define FAILED -1
#define SUCCESS 0

// for `getwmapinfo`
#define MAX_WMMAP_INFO 16
struct wmapinfo {
    int total_mmaps;                    // Total number of wmap regions
    int addr[MAX_WMMAP_INFO];           // Starting address of mapping
    int length[MAX_WMMAP_INFO];         // Size of mapping
    int n_loaded_pages[MAX_WMMAP_INFO]; // Number of pages physically loaded into memory
};

////////////////
// ADDED CODE //
////////////////

#define PHYSTOP 0xE000000  // Top of physical memory
#define PGSIZE 4096        // Page size
#define REF_COUNT_SIZE (PHYSTOP / PGSIZE)  // One byte per page

// Define constants
#define PAGE_SIZE 4096
#define MAX_NUM_WMAPS 16
#define PGNUM(a)    (((uint)(a)) / PAGE_SIZE)
#define PFN(va) ((uint)(va) >> 12)

// Structure to hold mapping region data
struct wmap_region {
    uint addr;     // Starting virtual address
    int length;    // Length of the region in bytes
    int flags;
    int fd; // File descriptor for file-backed mapping
    struct file *file;
    int n_loaded_pages;
};

#endif