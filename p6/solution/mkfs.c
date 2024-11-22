// PART 1: mkfs.c - 15% of grade
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include "wfs.h"

/**
 * Initializes a file to an empty filesystem.
 * For example, `./mkfs -r 1 -d disk1 -d disk2 -i 32 -b 200`
 *  initializes all disks (disk1 and disk2) to an empty filesystem with 32
 *  inodes and 224 data blocks
 * The size of the inode and data bitmaps are determined by the number of
 *  blocks specified by mkfs
 * If mkfs finds that the disk image file is too small to accomodate the number
 *  of blocks, it should exit with return code 0
 * mkfs should write the superblock and root inode to the disk image
 * 
 * returns 1 upon error, 0 upon success
*/
int create_fs(int raid_mode, int num_inodes, int num_data_blocks, char **disks, int num_disks) {
    // initialize all disks
    for (int i = 0; i < num_disks; i++) {
        int fd = open(disks[i], O_RDWR | O_CREAT, 0644);
        if (fd < 0) {
            return 1;
        }
        
        // check if disk image file is too small to accomodate number of blocks
        size_t min_size;    // superblock + inodes + data blocks
        size_t min_size = sizeof(struct wfs_sb) +
                        num_inodes * sizeof(struct wfs_inode) +
                        num_data_blocks / 8 +
                        num_inodes / 8;
        if (lseek(fd, 0, SEEK_END) < min_size) {
            close(fd);
            return 1;
        }
    }
}

int main(int argc, char** argv) {
    // verify number of CLAs
    if (argc < 1) {
        return -1;  // should be at lesaet 1 CLA
    }

    // vars for passed in args
    int raid_mode;
    // TODO: make disks array *disks[n];
    int num_disks;
    int num_inodes;
    int num_data_blocks;

    // parse CLAs (no set expected amount each time)
    for (int i = 1; i < argc; i++) {
            // '-r <raid mode>'
        if (!strcmp(argv[i], "-r")) {
            raid_mode = atoi(argv[i + 1]);    // get following arg
            i++;    // move onto next CLA
        }   // '-d <disk>'
        else if (!strcmp(argv[i], "-d")) {
            // TODO: add disk to disks array
        }   // '-i <num inodes in filesystem>'
        else if (!strcmp(argv[i], "-i")) {
            num_inodes = atoi(argv[i + 1]); // get following arg
            i++;    // move onto next CLA
        }   // '-b <num data blocks in system>'
        else if (!strcmp(argv[i], "-b")) {
            num_data_blocks = atoi(argv[i + 1]); // get following arg
            i++;    // move onto next CLA
        }
    }

    // round up number of blocks to multiple of 32 to prevent data structures
    // on disk from being misaligned
    if ((num_data_blocks % 32) != 0) {
        num_data_blocks += 32 - (num_data_blocks % 32);
    }

    // initialize file to empty filesystem
}