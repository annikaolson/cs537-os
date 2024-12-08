#define FUSE_USE_VERSION 30
#include <fuse.h>
#include <errno.h>
#include <time.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>  
#include <fcntl.h> 
#include <libgen.h>
#include "wfs.h"

////////////////////////////////
// DECLARE CALLBACK FUNCTIONS //
////////////////////////////////
static int wfs_getattr(const char* path, struct stat* stbuf);
static int wfs_mknod(const char *path, mode_t mode, dev_t dev);
static int wfs_mkdir(const char *path, mode_t mode);
static int wfs_unlink(const char *path);
static int wfs_rmdir(const char *path);
static int wfs_read(const char* path, char *buf, size_t size, off_t offset, struct fuse_file_info* fi);
static int wfs_write(const char* path, const char *buf, size_t size, off_t offset, struct fuse_file_info* fi);
static int wfs_readdir(const char* path, void* buf, fuse_fill_dir_t filler, off_t offset, struct fuse_file_info* fi);

////////////////////////////
// FUSE OPERATIONS STRUCT //
////////////////////////////
static struct fuse_operations ops = {
    .getattr = wfs_getattr,
    .mknod = wfs_mknod,
    .mkdir = wfs_mkdir,
    .unlink = wfs_unlink,
    .rmdir = wfs_rmdir,
    .read = wfs_read,
    .write = wfs_write,
    .readdir = wfs_readdir,
};

/////////////////////////////
// MOUNTING THE FILESYSTEM //
/////////////////////////////
static struct wfs_sb superblock;
static char disks[10][MAX_NAME];

//////////////////////
// HELPER FUNCTIONS //
//////////////////////

/**
 * Read a superblock in from a disk
 * 
 * All metadata in disks are RAID 1, meaning they are mirrored across disks.
 * This includes the superblock. So, we have made an instance of a global
 * superblock, and this will be assigned the superblock for all disks for
 * the file system
 * 
 * When the args are read in when the program starts, the disks are stored in
 * a global disks array.
 * 
 * Returns 0 upon success, otherwise check for failure
*/
int read_superblock(int num_disks) {
    // open disk as file to read metadata
    FILE *disk_file = fopen(disks[0], "rb");
    if (!disk_file) {
        // file doesn't exist
        return -ENOENT;
    }

    // read superblock from first disk image; the superblock is at offset 0
    // fread() returns the number of elements read (1 - the superblock)
    // we are storing the superblock we read in the global superblock variable
    fseek(disk_file, 0, SEEK_SET);  // read from the start of the disk
    size_t elmts_read = fread(&superblock, sizeof(struct wfs_sb), 1, disk_file);
    if (elmts_read != 1) {
        fclose(disk_file);
        return -1;
    }

    // check number of disks in the read-in superblock compared to number of
    // disks that were passed in as args
    if (superblock.num_disks != num_disks) {
        if (superblock.num_disks < num_disks) {
            fprintf(stderr, "Error: not enough disks.\n");
        } else if (superblock.num_disks > num_disks) {
            fprintf(stderr, "Error: too many disks.\n");
        }
        fclose(disk_file);
        return -1;
    }

    // verify that all disks in the superblock match the disks passed in
    for (int i = 0; i < num_disks; i++) {
        int found = 0;
        // check if current disk name is in superblock's disk order
        for (int j = 0; j < superblock.num_disks; j++) {
            if (!strncmp(disks[i], superblock.disk_order[j], MAX_NAME)) {
                found = 1;
                break;
            }
        }

        // if name not found in superblock, error
        if (!found) {
            fprintf(stderr, "Disks do not match expected.\n");
            fclose(disk_file);
            return -1;
        }
    }

    fclose(disk_file);

    return 0;   // success!
}

/*
 * Function to read from metadata
 */
void read_metadata(off_t offset, void* buffer, size_t size){
    int fd = open(disks[0], O_RDWR);
    lseek(fd, offset, SEEK_SET);
    read(fd, buffer, size);
    close(fd);
}

/*
 * Function to write metadata
 */
void write_metadata(off_t offset, const void* buffer, size_t size){
    int fd;
    for (int i = 0; i < superblock.num_disks; i++) {
        fd = open(disks[i], O_RDWR);
        lseek(fd, offset, SEEK_SET);
        write(fd, buffer, size);
        close(fd);
    }
}

/*
 * Function to read from disk based on raid mode
 */
void read_disk(off_t offset, void* buffer, size_t size){
    int raid_mode = superblock.raid_mode;
    int fd;

    // Raid 0: read from disk in round robin fashion
    if (raid_mode == 0) {
        size_t bytes_remaining = size;  // Total data to read
        size_t buffer_offset = 0;       // Offset in the buffer
        int disk_index = 0;             // Disk to read from, starts at 0
        
        // Loop through the data, reading up to BLOCK_SIZE at a time in round-robin fashion
        while (bytes_remaining > 0) {
            // Calculate the chunk size to read (up to BLOCK_SIZE)
            size_t chunk_size = (bytes_remaining < BLOCK_SIZE) ? bytes_remaining : BLOCK_SIZE;

            // Open the current disk
            fd = open(disks[disk_index], O_RDONLY);

            // Seek to the correct position on the disk
            off_t disk_offset = offset + (disk_index * BLOCK_SIZE);  // Disk-specific offset
            lseek(fd, disk_offset, SEEK_SET);

            // Read the data from the disk into the buffer
            read(fd, (char *)buffer + buffer_offset, chunk_size);
            close(fd);

            // Update the remaining bytes to read and the buffer offset
            bytes_remaining -= chunk_size;
            buffer_offset += chunk_size;

            // Move to the next disk in round-robin fashion
            disk_index = (disk_index + 1) % superblock.num_disks;  // Cycle through disks
        }
    }
    // Raid 1: all data mirrored
    else if (raid_mode == 1) {
            int fd = open(disks[0], O_RDWR);
            lseek(fd, offset, SEEK_SET);
            read(fd, buffer, size);
            close(fd);
    }
    // Raid 1v: compare all copies of data on different disks
    // Returns the data block present on the majority of disks
    // In case of tie, return the data block with a lower index
    else if (raid_mode == 2) {
        char temp_buffers[superblock.num_disks][BLOCK_SIZE];
        int votes[superblock.num_disks];
        memset(votes, 0, sizeof(votes));

        size_t bytes_remaining = size;
        size_t buffer_offset = 0;

        while (bytes_remaining > 0) {
            size_t chunk_size = bytes_remaining > BLOCK_SIZE ? BLOCK_SIZE : bytes_remaining;

            // Read from all disks and verify
            for (int i = 0; i < superblock.num_disks; i++) {
                fd = open(disks[i], O_RDWR);
                lseek(fd, offset, SEEK_SET);
                read(fd, temp_buffers[i], chunk_size);
                close(fd);
            }

            // Compare blocks for majority vote
            for (int i = 0; i < superblock.num_disks; i++) {
                for (int j = 0; j < superblock.num_disks; j++) {
                    if (memcmp(temp_buffers[i], temp_buffers[j], chunk_size) == 0) {
                        votes[i]++;
                    }
                }
            }

            // Find majority
            int majority_index = 0;
            for (int i = 1; i < superblock.num_disks; i++) {
                if (votes[i] > votes[majority_index] ||
                    (votes[i] == votes[majority_index] && i < majority_index)) {
                    majority_index = i;
                }
            }

            // Copy the majority data
            memcpy((char*)buffer + buffer_offset, temp_buffers[majority_index], chunk_size);

            bytes_remaining -= chunk_size;
            buffer_offset += chunk_size;
            offset += chunk_size;
        }
    }
}

/*
 * Function to write to disk based on raid mode
 */
void write_disk(off_t offset, const void* buffer, size_t size) {
    int raid_mode = superblock.raid_mode;
    int fd;

    // Raid 0: write to disks in round robin fashion
    if (raid_mode == 0) {
        size_t bytes_remaining = size;  // Total data to write
        size_t buffer_offset = 0;       // Offset in the buffer
        int disk_index = 0;             // Disk to write to, starts at 0
        
        // Loop through the data, writing up to BLOCK_SIZE at a time in round-robin fashion
        while (bytes_remaining > 0) {
            // Calculate the chunk size to write (up to BLOCK_SIZE)
            size_t chunk_size = (bytes_remaining < BLOCK_SIZE) ? bytes_remaining : BLOCK_SIZE;

            // Open the current disk
            fd = open(disks[disk_index], O_RDWR);

            // Seek to the correct position on the disk
            off_t disk_offset = offset + (disk_index * BLOCK_SIZE);  // Disk-specific offset
            lseek(fd, disk_offset, SEEK_SET);

            // Write the data to the disk
            write(fd, (char *)buffer + buffer_offset, chunk_size);
            close(fd);

            // Update the remaining bytes to write and the buffer offset
            bytes_remaining -= chunk_size;
            buffer_offset += chunk_size;

            // Move to the next disk in round-robin fashion
            disk_index = (disk_index + 1) % superblock.num_disks;  // Cycle through disks
        }
    }
    // Raid 1 or 1v: all data is mirrored
    else if (raid_mode == 1 || raid_mode == 2) {
        for (int i = 0; i < superblock.num_disks; i++) {
            fd = open(disks[i], O_RDWR);
            lseek(fd, offset, SEEK_SET);
            write(fd, buffer, size);
            close(fd);
        }
    }
}

/*
 * Allocates spot for inode but doesn't initialize
 * 
 * Returns the allocated inode number or -1
 */
int allocate_inode() {
    // calculate the size of the inode bitmap in bytes
    int bitmap_size = (superblock.num_inodes + 7) / 8;

    // buffer for the inode bitmap
    char bitmap[bitmap_size];

    // read the inode bitmap
    read_metadata(superblock.i_bitmap_ptr, bitmap, bitmap_size);

    // search for a free bit in the bitmap
    for (int i = 0; i < superblock.num_inodes; i++) {
        int byte_index = i / 8; // Byte index in the bitmap
        int bit_index = i % 8;  // Bit position within the byte

        if (!(bitmap[byte_index] & (1 << bit_index))) {
            // mark the bit as allocated
            bitmap[byte_index] |= (1 << bit_index);

            // write the updated bitmap back to disk
            write_metadata(superblock.i_bitmap_ptr, bitmap, bitmap_size);

            // return the allocated inode number
            return i;
        }
    }

    // no free inodes available
    return -ENOSPC;
}

/*
 * Helper function to read in an inode from the number
 */
int read_inode(int inode_num, struct wfs_inode *inode) {
    if (inode_num < 0 || inode_num >= superblock.num_inodes) {
        return -EINVAL; // Invalid inode number
    }

    read_metadata(superblock.i_blocks_ptr + (inode_num * BLOCK_SIZE), inode, sizeof(struct wfs_inode));

    return 0; // Success
}

/*
 * Writes a new inode to disk
 */
int write_inode(int inode_num, struct wfs_inode inode) {
    if (inode_num < 0 || inode_num >= superblock.num_inodes) {
        return -EINVAL; // Invalid inode number
    }

    write_metadata(superblock.i_blocks_ptr + (inode_num * BLOCK_SIZE), &inode, sizeof(struct wfs_inode));

    return 0; // Success
}

/*
 * Helper function to free inode
 */
void free_inode(int inode_num) {
    // Reset the inode to zero
    struct wfs_inode empty_inode = {0};

    // Write the cleared inode back to the inode table
    write_inode(inode_num, empty_inode);
}

/*
 * Allocate and initializes a new data block
 *
 * Returns data block number or -ENOSPC
 */
int allocate_data_block() {
    // calculate the size of the data block bitmap in bytes
    int bitmap_size = (superblock.num_data_blocks + 7) / 8;

    // buffer for the data block bitmap
    char bitmap[bitmap_size];

    // read the data block bitmap
    read_metadata(superblock.d_bitmap_ptr, bitmap, bitmap_size);

    // iterate over bitmap to find first free block
    for (int byte_index = 0; byte_index < bitmap_size; ++byte_index) {
        for (int bit_index = 0; bit_index < 8; ++bit_index) {
            if (!(bitmap[byte_index] & (1 << bit_index))) {
                // Mark the bit as allocated
                bitmap[byte_index] |= (1 << bit_index);

                // Write the updated bitmap back to disk
                write_disk(superblock.d_bitmap_ptr, bitmap, bitmap_size);

                // Calculate the block number
                int block_number = byte_index * 8 + bit_index;

                // initialize the new data block to zero
                char zero_block[BLOCK_SIZE] = {0};

                // Write the initialized data block to disk
                write_disk(superblock.d_blocks_ptr + (block_number * BLOCK_SIZE), zero_block, BLOCK_SIZE);

                // Return the allocated block number
                return block_number;
            }
        }
    }

    return -ENOSPC; // No free data blocks available
}

/*
 * Helper function to read a data block from the disk
 */
int read_data_block(int block_num, void *buffer) {
    if (block_num < 0 || block_num >= superblock.num_data_blocks) {
        return -EINVAL; // Invalid block number
    }

    read_disk(superblock.d_blocks_ptr + (block_num * BLOCK_SIZE), buffer, BLOCK_SIZE);

    return 0; // Success
}

/*
 * Writes a new data block to disk
 */
int write_data_block(int block_num, const void *buffer) {
    if (block_num < 0 || block_num >= superblock.num_data_blocks) {
        return -EINVAL; // Invalid block number
    }

    write_disk(superblock.d_blocks_ptr + (block_num * BLOCK_SIZE), buffer, BLOCK_SIZE);

    return 0; // Success
}

/*
 * Helper function to free data block
 */
void free_data_block(int block_num) {
    // Get the block's bitmap index and bit position
    int bitmap_index = block_num / 8;
    int bit_position = block_num % 8;

    // Read the data block bitmap (from all disks if necessary)
    char bitmap[superblock.num_data_blocks / 8 + 1];  // Make sure the bitmap size is enough
    read_metadata(superblock.d_bitmap_ptr, bitmap, sizeof(bitmap));

    // Clear the corresponding bit in the bitmap
    bitmap[bitmap_index] &= ~(1 << bit_position);

    // Write the updated bitmap back to disk
    write_metadata(superblock.d_bitmap_ptr, bitmap, sizeof(bitmap));
}


/*
 * Resolve path into an inode
 * 
 * Returns the inode number or -
 */
int resolve_path(const char *path) {
    char path_copy[MAX_PATH];

    // copy path to avoid modifying the original
    strncpy(path_copy, path, MAX_PATH);

    // start at root directory (inode 0)
    // root directory handling is built in
    int current_inode_num = 0;
    char *component = strtok(path_copy, "/");

    while (component != NULL) {
        struct wfs_inode dir_inode; // directory inode

        // read the current inode
        if (read_inode(current_inode_num, &dir_inode) < 0){
            return -EINVAL;
        }

        // check that the current inode is a directory
        if (!S_ISDIR(dir_inode.mode)){
            return -EINVAL;
        }

        // look up the component (file or directory) in the current directory's blocks
        int found_inode = -1;

        // NOTE: last block[N_BLOCKS] reserved for indirect, rest are wsf_dentry
        for (int i = 0; i < D_BLOCK; i++) {
            struct wfs_dentry entry[DENTRIES_PER_BLOCK]; // size is BLOCK_SIZE
            // read in the directory entry
            if (read_data_block(dir_inode.blocks[i], entry) < 0){
                return -EINVAL;
            }

            // check directory entry
            for (int j = 0; j < DENTRIES_PER_BLOCK; j ++){
                if (strcmp(entry[j].name, component) == 0) {
                    // found the component, save inode number
                    found_inode = entry[j].num;
                    break;
                }
            }

            // directory entry found, break out of loop
            if (found_inode != -1){
                break;
            }
        }

        // check if component was found
        if (found_inode == -1) {
            printf("Component not found: %s\n", component);
            return -1;
        }

        current_inode_num = found_inode;

        // continue to the next component
        component = strtok(NULL, "/");
    }

    // return the inode number of the final component
    return current_inode_num;
}

/*
 * Split the path
 */
void split_path(const char* path, char* parent_path, char* file_name) {
    char temp_path[MAX_PATH];
    strncpy(temp_path, path, MAX_PATH);

    // Find the last '/' in the path
    char* last_slash = strrchr(temp_path, '/');
    if (last_slash != NULL) {
        *last_slash = '\0';  // Null-terminate the parent path
        strncpy(file_name, last_slash + 1, MAX_NAME);  // Get the file name
    } else {
        parent_path[0] = '.';  // No slash, the parent is the current directory
        parent_path[1] = '\0';
        strncpy(file_name, path, MAX_NAME);
    }

    strncpy(parent_path, temp_path, MAX_PATH);
}

/*
 * Find the block for the path
 */
int find_block_for_path(struct wfs_inode* parent_inode, const char* file_name) {
    for (int i = 0; i < N_BLOCKS && parent_inode->blocks[i] != 0; i++) {
        struct wfs_dentry dentries[DENTRIES_PER_BLOCK];
        if (read_data_block(parent_inode->blocks[i], dentries) < 0) {
            return -EINVAL;  // Failed to read data block
        }

        for (int j = 0; j < DENTRIES_PER_BLOCK; j++) {
            if (strcmp(dentries[j].name, file_name) == 0) {
                return i;  // Found the block containing the directory entry
            }
        }
    }

    return -ENOENT;  // Directory entry not found
}

/* 
 * Remove a dentry
 */
int remove_directory_entry(const char* path) {
    // Step 1: Resolve the parent path and the filename
    char parent_path[MAX_PATH];
    char file_name[MAX_NAME];
    split_path(path, parent_path, file_name);

    // Step 2: Find the inode for the parent directory
    int parent_inode_num = resolve_path(parent_path);
    if (parent_inode_num < 0) {
        return -ENOENT;  // Parent directory not found
    }

    // Step 3: Read the parent inode
    struct wfs_inode parent_inode;
    if (read_inode(parent_inode_num, &parent_inode) < 0) {
        return -EINVAL;  // Invalid parent inode
    }

    // Step 4: Find the block where the entry is located
    int block_index = find_block_for_path(&parent_inode, file_name);
    if (block_index < 0) {
        return -ENOENT;  // File/directory not found
    }

    // Step 5: Read the data block containing the entry
    struct wfs_dentry dentries[DENTRIES_PER_BLOCK];
    if (read_data_block(parent_inode.blocks[block_index], dentries) < 0) {
        return -EINVAL;  // Failed to read data block
    }

    // Step 6: Find and remove the entry from the data block
    int entry_found = 0;
    for (int i = 0; i < DENTRIES_PER_BLOCK; i++) {
        if (strcmp(dentries[i].name, file_name) == 0) {
            // Mark entry as deleted (set inode number to 0)
            dentries[i].num = 0;
            entry_found = 1;
            break;
        }
    }

    if (!entry_found) {
        return -ENOENT;  // Directory entry not found
    }

    // Step 7: Write the updated data block back to disk
    if (write_data_block(parent_inode.blocks[block_index], dentries) < 0) {
        return -EINVAL;  // Failed to write data block
    }

    // Step 8: Decrease the nlinks of the parent inode
    parent_inode.nlinks--;
    if (write_inode(parent_inode_num, parent_inode) < 0) {
        return -EINVAL;  // Failed to write updated parent inode
    }

    return 0;  // Successfully removed directory entry
}

////////////////////////
// CALLBACK FUNCTIONS //
////////////////////////

/*
 * "
 * Return file attributes
 * 
 * The "stat" structure is described in detail in the stat(2) manual page. 
 * For the given pathname, this should fill in the elements of the "stat" structure. 
 * If a field is meaningless or semi-meaningless (e.g., st_ino) then it should be set 
 * to 0 or given a "reasonable" value. 
 * This call is pretty much required for a usable filesystem.
 * "
 * 
 * path: file or directory path requested by the user
 * stbuf: a struct stat pointer to store the attributes of the file or directry
 * return: 
 *      0 on sucess
 *      -ENOENT if the file/directory doesn't exist
 */
static int wfs_getattr(const char* path, struct stat* stbuf) {
    printf("wfs_getattr called with path: %s\n", path);
    
    // get the inode number from the path
    int inode_num = resolve_path(path);

    // check if the inode exists
    if (inode_num < 0){
        // file/directory does not exist 
        return -ENOENT;
    }

    // get the inode from the inode number
    struct wfs_inode inode;
    if (read_inode(inode_num, &inode) < 0) {
        // invalid inode number
        return -ENOSPC;
    }

    // fill in stat struct based on the inode
    stbuf->st_ino = inode.num;          // Inode number
    stbuf->st_mode = inode.mode;        // File type and permissions
    stbuf->st_nlink = inode.nlinks;     // Number of hard links
    stbuf->st_uid = inode.uid;          // User ID of the owner
    stbuf->st_gid = inode.gid;          // Group ID of the owner
    stbuf->st_size = inode.size;        // Size in bytes
    stbuf->st_atime = inode.atim;       // Time of last access
    stbuf->st_mtime = inode.mtim;       // Time of last modification
    stbuf->st_ctime = inode.ctim;       // Time of last status change

    // success
    return 0;
}

/*
 * Make a special (device) file, FIFO, or socket. 
 * See mknod(2) for details.
 */
static int wfs_mknod(const char *path, mode_t mode, dev_t dev) {
    printf("wfs_mknod called with path: %s\n", path);
        printf("wfs_mkdir called with path: %s\n", path);

    if (!path || strlen(path) == 0) {
        return -EINVAL;  // Invalid path
    }

    // Make a temporary copy of the path
    char path_copy[strlen(path) + 1];
    strcpy(path_copy, path);

    // Extract the parent path and directory name
    char *parent_path = dirname(path_copy);
    char path_copy2[strlen(path) + 1];
    strcpy(path_copy2, path);
    char *file_name = basename(path_copy2);

    // Validate parent path and directory name
    if (!parent_path || !file_name || strlen(file_name) == 0) {
        return -EINVAL;  // Invalid components
    }

    int parent_inode_num = resolve_path(parent_path);
    if (parent_inode_num < 0) {
        // parent directory doesn't exist
        return -ENOENT;
    }

    struct wfs_inode parent_inode;
    if (read_inode(parent_inode_num, &parent_inode) < 0) {
        // error reading inode
        return -EINVAL;
    }

    if (!S_ISDIR(parent_inode.mode)) {
        // parent is not a directory
        return -ENOTDIR;
    }

    for (int i = 0; i < D_BLOCK; i++) {
        int index = parent_inode.blocks[i];
        int byte_index = index / 8; // Byte index in the bitmap
        int bit_index = index % 8;  // Bit position within the byte

        // calculate the size of the data block bitmap in bytes
        int bitmap_size = (superblock.num_data_blocks + 7) / 8;

        // buffer for the data block bitmap
        char bitmap[bitmap_size];

        // read the data block bitmap
        read_metadata(superblock.d_bitmap_ptr, bitmap, bitmap_size);

        // check if bitmap is allocated for that spot 
        // or if data block is "zero" but either not root node or i != 0
        if ((!(bitmap[byte_index] & (1 << bit_index)))
            || (index == 0 && (parent_inode.num != 0 || i != 0))) {
            parent_inode.blocks[i] = allocate_data_block();
            if (parent_inode.blocks[i] < 0) {
                // return error if no blocks available
                return -ENOSPC;
            }
        }

        // data block is now allocated, read data block
        struct wfs_dentry dentries[DENTRIES_PER_BLOCK];
        if (read_data_block(parent_inode.blocks[i], dentries) < 0) {
            return -EINVAL;
        }

        // try to write to data block
        for (int j = 0; j < DENTRIES_PER_BLOCK; j++) {
            if (strcmp(dentries[j].name, file_name) == 0) {
                // directory already exists
                return -EEXIST;
            }
            else if (dentries[j].num == 0) {
                // make the new directory
                strncpy(dentries[j].name, file_name, MAX_NAME);

                // make the new inode
                dentries[j].num = allocate_inode();

                if (dentries[j].num < 0) {
                    // invalid inode
                    return -ENOSPC;
                }

                // write dentry to disk
                write_data_block(parent_inode.blocks[i], dentries);

                // initialize the new inode
                struct wfs_inode new_inode = {0};
                new_inode.num = dentries[j].num;
                new_inode.mode = mode;
                new_inode.uid = getuid();  // initial value nonzero
                new_inode.gid = getgid();  // initial value nonzero
                new_inode.size = 0; // initial size 0
                time(&new_inode.atim);
                new_inode.mtim = new_inode.atim;
                new_inode.ctim = new_inode.atim;
                new_inode.nlinks = 2;  // At least 2 links for a new directory (one for "." and one for "..")

                // write the new inode to disk
                write_inode(new_inode.num, new_inode);

                // update the parent
                parent_inode.nlinks++;
                parent_inode.mtim = time(NULL);

                return write_inode(parent_inode_num, parent_inode);
            }
        }
    }

    return -ENOSPC; // No space in parent directory
}

/*
 * Create a directory with the given name. The directory permissions are encoded in mode. 
 *
 * See mkdir(2) for details. 
 * This function is needed for any reasonable read/write filesystem.
 */
static int wfs_mkdir(const char *path, mode_t mode) {
    printf("wfs_mkdir called with path: %s\n", path);

    if (!path || strlen(path) == 0) {
        return -EINVAL;  // Invalid path
    }

    // Make a temporary copy of the path
    char path_copy[strlen(path) + 1];
    strcpy(path_copy, path);

    // Extract the parent path and directory name
    char *parent_path = dirname(path_copy);
    char path_copy2[strlen(path) + 1];
    strcpy(path_copy2, path);
    char *dir_name = basename(path_copy2);

    // Validate parent path and directory name
    if (!parent_path || !dir_name || strlen(dir_name) == 0) {
        return -EINVAL;  // Invalid components
    }

    int parent_inode_num = resolve_path(parent_path);
    if (parent_inode_num < 0) {
        // parent directory doesn't exist
        return -ENOENT;
    }

    struct wfs_inode parent_inode;
    if (read_inode(parent_inode_num, &parent_inode) < 0) {
        // error reading inode
        return -EINVAL;
    }

    if (!S_ISDIR(parent_inode.mode)) {
        // parent is not a directory
        return -ENOTDIR;
    }

    struct wfs_dentry dentries[DENTRIES_PER_BLOCK];
    for (int i = 0; i < D_BLOCK; i++) {
        int index = parent_inode.blocks[i];
        int byte_index = index / 8; // Byte index in the bitmap
        int bit_index = index % 8;  // Bit position within the byte

        // calculate the size of the data block bitmap in bytes
        int bitmap_size = (superblock.num_data_blocks + 7) / 8;

        // buffer for the data block bitmap
        char bitmap[bitmap_size];

        // read the data block bitmap
        read_metadata(superblock.d_bitmap_ptr, bitmap, bitmap_size);

        // check if bitmap is allocated for that spot
        // or if data block is "zero" but not root node
        if (!(bitmap[byte_index] & (1 << bit_index))
            || (index == 0 && (parent_inode.num != 0 || i != 0))) {
            parent_inode.blocks[i] = allocate_data_block();
            if (parent_inode.blocks[i] < 0) {
                // return error if no blocks available
                return -ENOSPC;
            }
        }

        // data block was or now is allocated
        if (read_data_block(parent_inode.blocks[i], dentries) < 0) {
            return -EINVAL;
        }

        for (int j = 0; j < DENTRIES_PER_BLOCK; j++) {
            if (strcmp(dentries[j].name, dir_name) == 0) {
                // directory already exists
                return -EEXIST;
            }
            else if (dentries[j].num == 0) {
                // make the new directory
                strncpy(dentries[j].name, dir_name, MAX_NAME);

                // make the new inode
                dentries[j].num = allocate_inode();

                if (dentries[j].num < 0) {
                    // invalid inode
                    return -ENOSPC;
                }

                // write dentry to disk
                write_data_block(parent_inode.blocks[i], dentries);

                // initialize the new inode
                struct wfs_inode new_inode = {0};
                new_inode.num = dentries[j].num;
                new_inode.mode = S_IFDIR | mode;  // Directory mode + requested permissions
                new_inode.uid = getuid();  // initial value nonzero
                new_inode.gid = getgid();  // initial value nonzero
                new_inode.size = 0; // initial size 0
                time(&new_inode.atim);
                new_inode.mtim = new_inode.atim;
                new_inode.ctim = new_inode.atim;
                new_inode.nlinks = 2;  // At least 2 links for a new directory (one for "." and one for "..")

                // write the new inode to disk
                write_inode(new_inode.num, new_inode);

                // update the parent
                parent_inode.nlinks++;
                parent_inode.mtim = time(NULL);

                return write_inode(parent_inode_num, parent_inode);
            }
        }
    }

    return -ENOSPC; // No space in parent directory
}

/*
 * Remove (delete) the given file, symbolic link, hard link, or special node. 
 *
 * Note that if you support hard links, unlink only deletes the data when the last hard link 
 * is removed. 
 * See unlink(2) for details.
 */
static int wfs_unlink(const char *path) {
    printf("wfs_unlink called with path: %s\n", path);

    // Step 1: Resolve the path to get the inode number of the file
    int inode_num = resolve_path(path);
    if (inode_num < 0) {
        return -ENOENT;  // File not found
    }

    // Step 2: Read the inode of the file
    struct wfs_inode inode;
    if (read_inode(inode_num, &inode) < 0) {
        return -EINVAL;  // Invalid inode
    }

    // Step 3: Check if it's a regular file (not a directory)
    if (!S_ISREG(inode.mode)) {
        return -EISDIR;  // It's a directory, not a file
    }

    // Step 4: Free the data blocks associated with the file
    for (int i = 0; i < N_BLOCKS; i++) {
        if (inode.blocks[i] == 0) {
            continue;  // No block allocated
        }

        // Mark the block as free in the bitmap
        free_data_block(inode.blocks[i]);

        // Reset the block to 0 in the inode
        inode.blocks[i] = 0;
    }

    // Step 5: Decrement the link count (nlinks) of the inode
    inode.nlinks--;
    if (inode.nlinks == 0) {
        // If the link count is 0, we can safely remove the inode
        free_inode(inode_num);
    } else {
        // Otherwise, just update the inode
        write_inode(inode_num, inode);
    }

    // Step 6: Remove the directory entry if this file is in a directory
    // This step depends on the directory structure and may involve finding the parent directory
    // and removing the entry from its list of files (usually done in the parent directory's data block)
    if (remove_directory_entry(path) < 0) {
        return -ENOSPC;  // Failed to remove directory entry
    }

    return 0;  // Success
}

/*
 * Remove the given directory. 
 *
 * This should succeed only if the directory is empty (except for "." and ".."). 
 * See rmdir(2) for details.
 */
static int wfs_rmdir(const char *path) {
    printf("wfs_rmdir called with path: %s\n", path);

    // Step 1: Resolve the path and get the parent directory
    int parent_inode_num = resolve_path(path);
    if (parent_inode_num < 0) {
        printf("Parent directory not found: %s\n", path);
        return -ENOENT;  // Parent directory not found
    }

    // Step 2: Read the parent directory inode
    struct wfs_inode parent_inode;
    if (read_inode(parent_inode_num, &parent_inode) < 0) {
        return -EINVAL;  // Invalid parent inode
    }

    // Step 3: Find the directory entry in the parent directory
    struct wfs_dentry dentries[DENTRIES_PER_BLOCK];
    int dir_block_index = find_block_for_path(&parent_inode, path);
    if (dir_block_index < 0) {
        printf("Directory not found in parent directory: %s\n", path);
        return -ENOENT;  // Directory not found
    }

    // Step 4: Read the data block containing directory entries
    if (read_data_block(parent_inode.blocks[dir_block_index], dentries) < 0) {
        return -EINVAL;  // Failed to read the data block
    }

    // Step 5: Locate the directory entry and verify it's empty
    struct wfs_inode dir_inode;
    int dir_entry_found = 0;
    for (int i = 0; i < DENTRIES_PER_BLOCK; i++) {
        if (strcmp(dentries[i].name, path) == 0) {
            dir_entry_found = 1;
            if (read_inode(dentries[i].num, &dir_inode) < 0) {
                return -EINVAL;  // Failed to read the directory inode
            }
            break;
        }
    }
    if (!dir_entry_found) {
        return -ENOENT;  // Directory entry not found in parent
    }

    // Step 6: Check if the directory is empty
    printf("Directory inode nlinks: %d\n", dir_inode.nlinks);
    if (dir_inode.nlinks > 2) {
        return -ENOTEMPTY;  // Directory is not empty
    }

    // Step 7: Remove the directory entry from the parent directory
    for (int i = 0; i < DENTRIES_PER_BLOCK; i++) {
        if (strcmp(dentries[i].name, path) == 0) {
            dentries[i].num = 0;  // Mark the directory entry as removed
            write_data_block(parent_inode.blocks[dir_block_index], dentries);
            break;
        }
    }

    // Step 8: Free the directory's data blocks and inode
    for (int i = 0; i < N_BLOCKS; i++) {
        if (dir_inode.blocks[i] != 0) {
            free_data_block(dir_inode.blocks[i]);
        }
    }

    // Free the directory inode
    free_inode(dentries[0].num);

    // Step 9: Update the parent inode (decrease the link count)
    parent_inode.nlinks--;
    write_inode(parent_inode_num, parent_inode);

    return 0;  // Success
}

/*
 * Read sizebytes from the given file into the buffer buf, beginning offset bytes into the file. 
 *
 * See read(2) for full details. 
 * Returns the number of bytes transferred, or 0 if offset was at or beyond the end of the file. 
 * Required for any sensible filesystem.
 *
 * path: path of file that is being written to
 * buf: data to be written to the file
 * size: number of bytes to be written to file starting from the offset
 * offset: offset within the file where the write operation should start
 */
static int wfs_read(const char* path, char *buf, size_t size, off_t offset, struct fuse_file_info* fi) {
    printf("wfs_read called with path: %s\n", path);

    // Step 1: Resolve the path to get the inode number
    int inode_num = resolve_path(path);
    if (inode_num < 0) {
        return -ENOENT;  // File does not exist
    }

    // Step 2: Read the inode
    struct wfs_inode inode;
    if (read_inode(inode_num, &inode) < 0) {
        return -EINVAL;  // Invalid inode number
    }

    // Step 3: Check if it's a regular file
    if (!S_ISREG(inode.mode)) {
        return -EINVAL;  // Not a regular file
    }

    // Step 4: Check if the offset is beyond the file size
    if (offset >= inode.size) {
        return 0;  // End of file reached, nothing to read
    }

    // Step 5: Start reading data from the file
    size_t bytes_read = 0;
    while (bytes_read < size && offset + bytes_read < inode.size) {
        // Find the block index based on the offset
        int block_index = (offset + bytes_read) / BLOCK_SIZE;
        int block_offset = (offset + bytes_read) % BLOCK_SIZE;

        // Check if the data block exists
        if (inode.blocks[block_index] == 0) {
            return -EIO;  // Error: No data block allocated (unexpected)
        }

        // Read the data block into a temporary buffer
        char data_block[BLOCK_SIZE];
        if (read_data_block(inode.blocks[block_index], data_block) < 0) {
            return -EIO;  // Failed to read data block
        }

        // Calculate how many bytes to copy from the current block
        size_t bytes_to_copy = size - bytes_read;
        size_t block_remaining = BLOCK_SIZE - block_offset;
        size_t copy_size = (bytes_to_copy < block_remaining) ? bytes_to_copy : block_remaining;

        // Copy the data into the buffer
        memcpy(buf + bytes_read, data_block + block_offset, copy_size);

        // Update the number of bytes read and move the offset
        bytes_read += copy_size;
    }

    return bytes_read;  // Return the number of bytes read
}

/*
 * As for read above, except that it can't return 0.
 */
static int wfs_write(const char* path, const char *buf, size_t size, off_t offset, struct fuse_file_info* fi) {
    printf("wfs_write called with path: %s\n", path);

    // Step 1: Resolve path and get inode number
    int inode_num = resolve_path(path);
    if (inode_num < 0) {
        return -ENOENT;  // File does not exist
    }

    // Step 2: Read the inode for the file
    struct wfs_inode inode;
    if (read_inode(inode_num, &inode) < 0) {
        return -EINVAL;  // Invalid inode
    }

    // Step 3: Validate the inode type (regular file)
    if (!S_ISREG(inode.mode)) {
        return -EINVAL;  // Invalid inode type
    }

    // Step 4: Update file size if necessary
    if (offset + size > inode.size) {
        inode.size = offset + size;
        write_inode(inode_num, inode);  // Save the updated inode
    }

    // Step 5: Read the bitmap for data block allocation
    int bitmap_size = (superblock.num_data_blocks + 7) / 8;
    char bitmap[bitmap_size];
    read_metadata(superblock.d_bitmap_ptr, bitmap, bitmap_size);

    // Step 6: Write to data block(s)
    size_t bytes_written = 0;
    while (bytes_written < size) {
        // Calculate the block index and block offset
        int block_index = (offset + bytes_written) / BLOCK_SIZE;
        int block_offset = (offset + bytes_written) % BLOCK_SIZE;

        // Step 7: Check if the block has been allocated (bitmap check)
        if (block_index == 0) {
            // Special case for the first data block (block 0)
            if (!(bitmap[0] & (1 << 0))) {  // Check if the first bit (block 0) is not allocated
                // Block 0 is unallocated, so we need to allocate it
                inode.blocks[block_index] = allocate_data_block();
                if (inode.blocks[block_index] < 0) {
                    return -ENOSPC;  // No space left to allocate a block
                }
                // Mark the block as allocated in the bitmap
                bitmap[0] |= (1 << 0);  // Set the bit for block 0
                write_metadata(superblock.d_bitmap_ptr, bitmap, bitmap_size);  // Write the updated bitmap
            }
        } else {
            // For other blocks, check the bitmap and allocate if necessary
            if (!(bitmap[block_index / 8] & (1 << (block_index % 8)))) {
                // Block is not allocated, so we need to allocate it
                inode.blocks[block_index] = allocate_data_block();
                if (inode.blocks[block_index] < 0) {
                    return -ENOSPC;  // No space left to allocate a block
                }
                // Mark the block as allocated in the bitmap
                bitmap[block_index / 8] |= (1 << (block_index % 8));  // Set the bit for this block
                write_metadata(superblock.d_bitmap_ptr, bitmap, bitmap_size);  // Write the updated bitmap
            }
        }

        // Step 8: Read the data block into a buffer
        char data_block[BLOCK_SIZE] = {0};
        if (read_data_block(inode.blocks[block_index], data_block) < 0) {
            return -EINVAL;  // Invalid data block
        }

        // Step 9: Write data to the buffer
        size_t chunk_size = (size - bytes_written) < (BLOCK_SIZE - block_offset) ? (size - bytes_written) : (BLOCK_SIZE - block_offset);
        memcpy(data_block + block_offset, buf + bytes_written, chunk_size);

        // Step 10: Write the modified data block back to disk
        if (write_data_block(inode.blocks[block_index], data_block) < 0) {
            return -EINVAL;  // Failed to write data block
        }

        // Step 11: Update the number of bytes written
        bytes_written += chunk_size;
    }

    // Step 12: Update the inode's modification time and write it back
    inode.mtim = time(NULL);
    write_inode(inode_num, inode);

    return size;  // Return the number of bytes written
}

/*
 * Return one or more directory entries (struct dirent) to the caller. 
 * This is one of the most complex FUSE functions. 
 * It is related to, but not identical to, the readdir(2) and getdents(2) system calls, and the 
 * readdir(3) library function. 
 * Because of its complexity, it is described separately below. Required for essentially any filesystem, since it's what makes ls and a whole bunch of other things work.
 */
static int wfs_readdir(const char* path, void* buf, fuse_fill_dir_t filler, off_t offset, struct fuse_file_info* fi) {
    printf("wfs_readdir called with path: %s\n", path);

    // Step 1: Resolve the path to get the inode number
    int inode_num = resolve_path(path);
    if (inode_num < 0) {
        return -ENOENT;  // Directory not found
    }

    // Step 2: Read the inode of the directory
    struct wfs_inode inode;
    if (read_inode(inode_num, &inode) < 0) {
        return -EINVAL;  // Invalid inode
    }

    // Step 3: Check if the inode is a directory (S_ISDIR checks if it's a directory)
    if (!S_ISDIR(inode.mode)) {
        return -ENOTDIR;  // Not a directory
    }

    // Step 4: Read the directory's data blocks and pass each entry to the filler
    struct wfs_dentry dentries[DENTRIES_PER_BLOCK];  // Buffer for directory entries
    for (int i = 0; i < N_BLOCKS; i++) {
        if (inode.blocks[i] == 0) {
            continue;  // No block allocated for this entry
        }

        // Read the data block into dentries
        if (read_data_block(inode.blocks[i], dentries) < 0) {
            return -EINVAL;  // Failed to read the block
        }

        // Add each directory entry to the filler
        for (int j = 0; j < DENTRIES_PER_BLOCK; j++) {
            if (dentries[j].num == 0) {
                continue;  // Empty entry, skip
            }

            // Use the filler to return the directory entry
            if (filler(buf, dentries[j].name, NULL, 0)) {
                return -ENOMEM;  // If the filler fails
            }
        }
    }

    return 0;  // Success
}

/*
    The readdir function is somewhat like read, in that it starts at a given offset and returns results in a caller-supplied buffer. 
    However, the offset not a byte offset, and the results are a series of struct dirents rather than being uninterpreted bytes. 
    To make life easier, FUSE provides a "filler" function that will help you put things into the buffer.

    The general plan for a complete and correct readdir is:
        1. Find the first directory entry following the given offset (see below).
        2. Optionally, create a struct stat that describes the file as for getattr (but FUSE only looks at st_ino and the file-type bits of st_mode).
        3. Call the filler function with arguments of buf, the null-terminated filename, the address of your struct stat (or NULL if you have none), and the offset of the next directory entry.
        4. If filler returns nonzero, or if there are no more files, return 0.
        5. Find the next file in the directory.
        6. Go back to step 2.
    
    From FUSE's point of view, the offset is an uninterpreted off_t (i.e., an unsigned integer). 
    You provide an offset when you call filler, and it's possible that such an offset might come back to you as an argument later. 
    Typically, it's simply the byte offset (within your directory layout) of the directory entry, but it's really up to you.

    It's also important to note that readdir can return errors in a number of instances; 
    in particular it can return -EBADF if the file handle is invalid, or -ENOENT if you use the path argument and the path doesn't exist.
*/

///////////////////
// MAIN FUNCTION //
///////////////////
int main(int argc, char** argv){
    // check the number of inputs
    if (argc < 5) {
        fprintf(stderr, "Too few args\n");
        return -1;
    }

    // parse disks and flags
    int num_disks = 0;
    char *mount_point = NULL;

    // process arguments, skip program name
    for (int i = 1; i < argc; i++) {
        // handle -s flag (mount point)
        if (strcmp(argv[i], "-s") == 0) {
            if (i + 1 < argc) {
                mount_point = argv[i + 1];  // mount point is after -s
                i++;  // skip mount point argument
            } else {
                fprintf(stderr, "Error: Missing mount point after -s\n");
                return -1;
            }
        }
        // check for the -f flag (foreground)
        else if (strcmp(argv[i], "-f") == 0) {
            // ignore the -f flag
        }
        // otherwise, treat the argument as a disk image
        else {
            if (num_disks < MAX_DISKS) {
                strncpy(disks[num_disks], argv[i], MAX_NAME);
                num_disks++;
            } else {
                fprintf(stderr, "Too many disk arguments\n");
                return -1;
            }
        }
    }

    // at least two disks are specified
    if (num_disks < 2) {
        fprintf(stderr, "Not enough disks\n");
        return -1;
    }

    // check the number of disks by reading the superblock
    int read_sb_res = read_superblock(num_disks);
    if (read_superblock(num_disks) != 0) {
        return read_sb_res;
    }

    // check for valid mount point
    if (mount_point == NULL) {
        fprintf(stderr, "Missing mount point\n");
        return -1;
    }

    // prepare arguments for FUSE 
    int fuse_argc = 0;

    // count the flags and the mount point argument
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-s") == 0 || strcmp(argv[i], "-f") == 0) {
            fuse_argc++;
        }
    }

    // one argument for the program name and one for the mount point
    fuse_argc += 2;

    // allocate fuse_argv with appropriate size
    char *fuse_argv[fuse_argc];

    // initialize fuse_argv with program name
    int fuse_index = 0;
    fuse_argv[fuse_index++] = argv[0];

    // add flags (-s, -f)
    for (int i = 1; i < argc - 1; i++) {
        if (strcmp(argv[i], "-s") == 0 || strcmp(argv[i], "-f") == 0) {
            fuse_argv[fuse_index++] = argv[i];
        }
    }

    // add the mount point as the last argument
    fuse_argv[fuse_index++] = argv[argc - 1];

    /*
    // Debugging: print out arguments passed to FUSE
    for (int i = 0; i < fuse_index; i++) {
        printf("fuse_argv[%d] = %s\n", i, fuse_argv[i]);
    }

    printf("fuse_argc = %d\n", fuse_argc);*/

    // pass filtered arguments to FUSE
    return fuse_main(fuse_argc, fuse_argv, &ops, NULL);
}