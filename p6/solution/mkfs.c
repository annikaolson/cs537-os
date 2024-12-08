// PART 1: mkfs.c - 15% of grade

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
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

    // calculate the minimum size the disk image file must be
    int min_size;    // superblock + inodes + data blocks
    int inode_bitmap_size = (num_inodes + 7) / 8;
    int data_bitmap_size = (num_data_blocks + 7) / 8;
    int inode_table_size = num_inodes * BLOCK_SIZE;
    min_size = sizeof(struct wfs_sb) +
                        inode_bitmap_size +
                        data_bitmap_size +
                        inode_table_size +
                        num_data_blocks * BLOCK_SIZE;

    // initialize superblock
    struct wfs_sb superblock;
    superblock.num_inodes = num_inodes;
    superblock.num_data_blocks = num_data_blocks;
    superblock.i_bitmap_ptr = sizeof(struct wfs_sb);
    superblock.d_bitmap_ptr = superblock.i_bitmap_ptr + inode_bitmap_size;
    superblock.i_blocks_ptr = (superblock.d_bitmap_ptr + data_bitmap_size + BLOCK_SIZE - 1) & ~(BLOCK_SIZE - 1);
    superblock.d_blocks_ptr = superblock.i_blocks_ptr + inode_table_size;

    // init RAID-related fields
    superblock.raid_mode = raid_mode;
    superblock.num_disks = num_disks;
    // set disk order
    for (int i = 0; i < num_disks; i++) {
        strncpy(superblock.disk_order[i], disks[i], MAX_NAME);
    }

    // initialize root inode: other files and directorires can be created here
    struct wfs_inode root_inode;
    memset(&root_inode, 0, sizeof(struct wfs_inode));
    root_inode.num = 0; // inode number for root
    root_inode.mode = S_IFDIR | 0755; // rwx permissions
    root_inode.uid = getuid();  // initial value nonzero
    root_inode.gid = getgid();  // initial value nonzero
    root_inode.size = 0;    // root inode should have size 0
    root_inode.nlinks = 2;  // '.' and '..'
    time(&root_inode.atim);
    root_inode.mtim = root_inode.atim;
    root_inode.ctim = root_inode.atim;

    // initialize inode bitmap (mark inode 0 as allocated)
    char inode_bitmap[inode_bitmap_size];
    memset(inode_bitmap, 0, inode_bitmap_size);
    inode_bitmap[0] = 1;  // Mark inode 0 as allocated)

    // initialize all disks
    for (int i = 0; i < num_disks; i++) {
        int fd = open(disks[i], O_RDWR | O_CREAT, 0644);
        if (fd < 0) {
            return -ENOENT;
        }
        
        // check if disk image file is too small to accomodate number of blocks
        if (lseek(fd, 0, SEEK_END) < min_size) {
            close(fd);
            return -1;
        }

        // zero out disk
        lseek(fd, 0, SEEK_SET);
        char zero = 0;
        for (int j = 0; j < min_size; j++) {
            write(fd, &zero, 1);
        }

        // write superblock
        lseek(fd, 0, SEEK_SET);
        write(fd, &superblock, sizeof(struct wfs_sb));

        // write inode bitmap to disk
        lseek(fd, superblock.i_bitmap_ptr, SEEK_SET);
        write(fd, inode_bitmap, inode_bitmap_size);

        // write root inode
        lseek(fd, superblock.i_blocks_ptr, SEEK_SET);
        write(fd, &root_inode, sizeof(struct wfs_inode));

        // write other inodes
        for (int i = 1; i < num_inodes; i++) {
            struct wfs_inode inode;
            // Align to the next block boundary
            lseek(fd, superblock.i_blocks_ptr + i * BLOCK_SIZE, SEEK_SET);
            write(fd, &inode, sizeof(struct wfs_inode));  // write inode
        }

        // write datablocks to each disk - RAID dependent

        // RAID 0 (striping): one data stripe is 512B; first 512B of file are
        // written to disk 1, second 512B to disk 2, etc.
        if (raid_mode == 0) {
            for (int j = 0; j < num_data_blocks; j++) {
                char data[BLOCK_SIZE];
                memset(data, 0, BLOCK_SIZE);

                lseek(fd, superblock.d_blocks_ptr + j * BLOCK_SIZE, SEEK_SET);
                write(fd, data, BLOCK_SIZE);
            }
        } // RAID 1 (mirroring): all data and metadata are mirrored across all
        // disks, hence all images will look identically
        else if (raid_mode == 1) {
            for (int j = 0; j < num_data_blocks; j++) {
                char data[BLOCK_SIZE];
                memset(data, 0, BLOCK_SIZE);

                for (int k = 0; k < num_disks; k++) {
                    lseek(fd, superblock.d_blocks_ptr + j * BLOCK_SIZE, SEEK_SET);
                    write(fd, data, BLOCK_SIZE);
                }
            }
        } // RAID 2 [1v] (verified mirroring): this mode has identical on-disk
        // structure as plain RAID 1 but every read operation will compare all
        // copies of data blocks on different drives and return the data block
        // present on majority of the drives. if there is a tie, then data
        // block on disk with lower index is returned. By index we mean its
        // position during mount
        else if (raid_mode == 2) {
            for (int j = 0; j < num_data_blocks; j++) {
                char data[BLOCK_SIZE];
                memset(data, 0, BLOCK_SIZE);

                for (int k = 0; k < num_disks; k++) {
                    lseek(fd, superblock.d_blocks_ptr + j * BLOCK_SIZE, SEEK_SET);
                    write(fd, data, BLOCK_SIZE);  // write the same block to all disks
                }
            }
        }

        close(fd);  // done!
    }
    return 0;
}

int main(int argc, char** argv) {
    // vars for passed in args
    int raid_mode = -1; // init to invalid
    char *disks[10]; // piazza said 10 is reasonable lol
    int num_disks = 0;
    int num_inodes;
    int num_data_blocks;

    // parse CLAs (no set expected amount each time)
    for (int i = 1; i < argc; i++) {
            // '-r <raid mode>'
        if (!strcmp(argv[i], "-r") && (i + 1 < argc)) {
            if (!strcmp(argv[i + 1], "0") || !strcmp(argv[i + 1], "1") || !strcmp(argv[i + 1], "1v")) {
                if (!strcmp(argv[i + 1], "1v")) {
                    raid_mode = 2;
                } else {
                    raid_mode = atoi(argv[i + 1]);    // get following arg
                    i++;    // move onto next CLA
                }
            } else {
                fprintf(stderr, "Error: Invalid RAID mode: %s\n", argv[i + 1]);
                return 1;
            }
        }   // '-d <disk>'
        else if (!strcmp(argv[i], "-d") && (i + 1 < argc)) {
            if (num_disks < 10) {
                disks[num_disks++] = argv[i + 1];
                i++;    // move onto next CLA
            } else {
                return 1;   // too many disks
            }
        }   // '-i <num inodes in filesystem>'
        else if (!strcmp(argv[i], "-i") && (i + 1 < argc)) {
            num_inodes = atoi(argv[i + 1]); // get following arg
            i++;    // move onto next CLA
        }   // '-b <num data blocks in system>'
        else if (!strcmp(argv[i], "-b") && (i + 1 < argc)) {
            num_data_blocks = atoi(argv[i + 1]); // get following arg
            i++;    // move onto next CLA
        }
    }

    // must have at least two disks
    if (num_disks < 2) {
        return 1;   // pre-run failure
    }

    // check to see if a raid mode was passed in
    if (raid_mode == -1) {
        fprintf(stderr, "Error: No RAID mode specified.\n");
        return -1;
    }

    // round up number of blocks to multiple of 32 to prevent data structures
    // on disk from being misaligned
    if ((num_data_blocks % 32) != 0) {
        num_data_blocks += 32 - (num_data_blocks % 32);
    }

    // round up number of blocks to multiple of 32 to prevent data structures
    // on disk from being misaligned... inodes count too
    if ((num_inodes % 32) != 0) {
        num_inodes += 32 - (num_inodes % 32);
    }

    // initialize file to empty filesystem
    return create_fs(raid_mode, num_inodes, num_data_blocks, disks, num_disks);
}
