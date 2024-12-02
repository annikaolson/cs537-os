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
void *disk_map = NULL;

/*
 * Helper function to read the superblock
 */
int read_superblock(const char *disk, struct wfs_sb *superblock) {
    FILE *fp = fopen(disk, "rb");
    if (!fp) {
        perror("Error opening disk");
        return -1;
    }

    // Read the superblock from the beginning of the disk
    if (fread(superblock, sizeof(superblock), 1, fp) != 1) {
        perror("Error reading superblock");
        fclose(fp);
        return -1;
    }

    fclose(fp);
    return 0;
}

/*
 * Function for mounting the filesystem
 */
int mount_fs(char **disks, int num_disks) {
    // validate number of disks against superblock
    if (num_disks != superblock.num_disks) {
        fprintf(stderr, "Error: Invalid number of disks. Expected %d disks, but got %d.\n", superblock.num_disks, num_disks);
        return -1;
    }

    // read the superblock from the first disk
    if (read_superblock(disks[0], &superblock) != 0) {
        // failed to read superblock
        return -1;
    }

    // handle RAID logic based on RAID mode
    switch (superblock.raid_mode) {
        // RAID 0 (striping)
        case 0:
            // read data block from each disk (round-robin)
            
            break;

        // RAID 1 (mirroring)
        case 1:
            // data is mirrored, read from disk 0 since it doesn't matter
            
            break;

        // RAID 1V (verified mirroring)
        case 2:
            // compare data on all disks and return the majority
            break;

        default:
            fprintf(stderr, "Error: Unknown RAID mode %d.\n", superblock.raid_mode);
            return -1;
    }

    // Step 5: If everything checks out, the filesystem is successfully mounted
    printf("Filesystem successfully mounted.\n");
    return 0;
}

//////////////////////
// HELPER FUNCTIONS //
//////////////////////

/**
 * allocates an inode by searching the inode bitmap to find the first
 * free inode
 * 
 * returns the inode number or error if no free inodes available
*/
int allocate_inode() {
    // access the inode bitmap from disk
    char *inode_bitmap = (char *)(disk_map) + superblock.i_bitmap_ptr;

    // find the first free inode in the inode bitmap
    for (size_t i = 0; i < superblock.num_inodes; i++) {
        if (!(inode_bitmap[i / 8] & (1 << (i % 8)))) {
            // mark the inode as used by setting the corresponding bit
            inode_bitmap[i / 8] |= (1 << (i % 8));

            // return the inode number
            return i + 1;
        }
    }

    return -ENOSPC;  // no free inode
}

/**
 * allocates a data block by searching the dta block bitmap to find the first
 * free block
 * 
 * returns the inode number or error if no free inodes available
*/
int allocate_data_block() {
    // access the inode bitmap from disk
    char *data_bitmap = (char *)(disk_map) + superblock.d_bitmap_ptr;

    // find the first free inode in the inode bitmap
    for (size_t i = 0; i < superblock.num_data_blocks; i++) {
        if (!(data_bitmap[i / 8] & (1 << (i % 8)))) {
            // mark the data block as used by setting the corresponding bit
            data_bitmap[i / 8] |= (1 << (i % 8));

            return i + 1;
        }
    }

    return -ENOSPC;  // no free inode
}

// Function to get inode given the inode number
struct wfs_inode *get_inode(int inode_num) {
    // Calculate the block in which the inode is stored
    // Assuming the inode table starts at a known block, for example, superblock.i_table_ptr
    // and each inode takes up sizeof(struct wfs_inode) bytes
    
    size_t inode_size = sizeof(struct wfs_inode);
    size_t inode_table_offset = superblock.i_blocks_ptr;  // The starting block of the inode table

    // Calculate the offset to the inode based on the inode number (inodes are usually stored sequentially)
    size_t inode_offset = inode_num * inode_size;

    // Get the pointer to the inode data
    struct wfs_inode *inode = (struct wfs_inode *)((char *)disk_map + inode_table_offset + inode_offset);

    // Return the inode or NULL if not found (in case of error, for simplicity assuming valid inode)
    return inode;
}

void init_dentry(struct wfs_dentry *entry, const char *name, int inode_num) {
    // Ensure that the entry and name are valid
    if (entry == NULL || name == NULL) {
        return;
    }

    // Initialize the name (copy the string into the dentry's name field)
    strncpy(entry->name, name, MAX_NAME - 1); // Make sure to not exceed max length
    entry->name[MAX_NAME - 1] = '\0'; // Ensure null-termination

    // Set the inode number for this entry
    entry->num = inode_num;

    // Optionally, you could set additional fields in the entry if needed
    // entry->next = NULL; // Example if you have a linked list
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

    // check if path refers to root directory
    if (!strcmp(path, "/")) {
        // root inode is inode 0
        struct wfs_inode root_inode;
        int fd = open(superblock.disk_order[0], O_RDWR);
        if (fd < 0) {
            return -ENOENT; // disk open fails
        }

        // seek to root inode location
        lseek(fd, superblock.i_blocks_ptr, SEEK_SET);
        read(fd, &root_inode, sizeof(struct wfs_inode));

        // set stbuf (stat)
        memset(stbuf, 0, sizeof(struct stat));
        stbuf->st_mode = root_inode.mode;
        stbuf->st_size = root_inode.size;
        stbuf->st_uid = root_inode.uid;
        stbuf->st_gid = root_inode.gid;
        stbuf->st_nlink = root_inode.nlinks;
        stbuf->st_atime = root_inode.atim;
        stbuf->st_mtime = root_inode.mtim;
        stbuf->st_ctime = root_inode.ctim;

        close(fd);
        return 0;   // success
    }

    // not root, so lookup file path
    int fd = open(superblock.disk_order[0], O_RDWR);
    if (fd < 0) {
        return -ENOENT;
    }

    //struct wfs_inode inode;

    // TODO: what if not inode 0?

    return 0;
}

/*
 * Make a special (device) file, FIFO, or socket. 
 * See mknod(2) for details.
 */
static int wfs_mknod(const char *path, mode_t mode, dev_t dev) {
    printf("wfs_mknod called with path: %s\n", path);
    return 0;
}

/*
 * Create a directory with the given name. The directory permissions are encoded in mode. 
 *
 * See mkdir(2) for details. 
 * This function is needed for any reasonable read/write filesystem.
 */
static int wfs_mkdir(const char *path, mode_t mode) {
    printf("wfs_mkdir called with path: %s\n", path);
    
    // get parent directory from path
    char parent_path[MAX_NAME];
    char dir_name[MAX_NAME];
    int i = strlen(path) - 1;

    // extract directory name and parent path
    while (i >= 0 && path[i] != '/') {
        i--;
    }

    // no slash, creating a directory at root level
    if (i < 0) {
        strncpy(parent_path, "/", sizeof(parent_path));
        strncpy(dir_name, path, sizeof(dir_name));
    } else {
        strncpy(parent_path, path, i + 1);
        parent_path[i + 1] = '\0';  // null terminate
        strncpy(dir_name, path + 1 + 1, sizeof(dir_name));
    }

    // find partent directory inode
    struct wfs_inode *parent_inode = get_inode(0);  // TODO: get inode number
    if (parent_inode == NULL) {
        return -ENOENT; // parent directory doesn't exist
    }

    // check if directory already exists
    struct wfs_dentry *parent_entries = (struct wfs_dentry *)(disk_map) + parent_inode->blocks[0];
    int num_entries = parent_inode->size / sizeof(struct wfs_dentry);

    for (int i = 0; i < num_entries; i++) {
        if (!strcmp(parent_entries[i].name, dir_name)) {
            return -EEXIST; // directory already exists
        }
    }

    // allocate inode for new directory
    int dir_inode_num = allocate_inode();
    if (dir_inode_num < 0) {
        return dir_inode_num;   // error allocating inode
    }

    struct wfs_inode new_dir_inode;
    memset(&new_dir_inode, 0, sizeof(struct wfs_inode));

    // set up new directory inode
    new_dir_inode.mode = __S_IFDIR | mode;  // directory mode
    new_dir_inode.size = 2 * sizeof(struct wfs_dentry);  // entries for '.' and '..'
    new_dir_inode.nlinks = 2;  // '.' and '..'
    new_dir_inode.uid = getuid();
    new_dir_inode.gid = getgid();
    time(&new_dir_inode.atim);
    new_dir_inode.mtim = new_dir_inode.atim;
    new_dir_inode.ctim = new_dir_inode.atim;

    // alloc data block for new directory
    int data_block = allocate_data_block();
    if (data_block < 0) {
        return data_block;  // error allocating data block
    }

    // assign the data block to the directory inode
    new_dir_inode.blocks[0] = data_block;

    // add directory entries for '.' and '..'
    struct wfs_dentry new_dir_entries[2];
    init_dentry(&new_dir_entries[0], ".", dir_inode_num);  // itself
    init_dentry(&new_dir_entries[1], "..", parent_inode->num);  // parent directory

    // write the directory entries to the data block
   // write_data_block(data_block, new_dir_entries);

    // write the new directory inode to the inode table
    //write_inode(dir_inode_num, &new_dir_inode);

    // update parent directory with the new directory entry
    struct wfs_dentry new_parent_entry;
    init_dentry(&new_parent_entry, dir_name, dir_inode_num);

    // add the new directory entry to the parent directory
    parent_entries[num_entries] = new_parent_entry;
    parent_inode->size += sizeof(struct wfs_dentry);

    // write the updated parent inode back to disk
    //write_inode(parent_inode->num, parent_inode);

    return 0;  // success
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
    return 0;
}

/*
 * Remove the given directory. 
 *
 * This should succeed only if the directory is empty (except for "." and ".."). 
 * See rmdir(2) for details.
 */
static int wfs_rmdir(const char *path) {
    printf("wfs_rmdir called with path: %s\n", path);
    return 0;
}

/*
 * Read sizebytes from the given file into the buffer buf, beginning offset bytes into the file. 
 *
 * See read(2) for full details. 
 * Returns the number of bytes transferred, or 0 if offset was at or beyond the end of the file. 
 * Required for any sensible filesystem.
 */
static int wfs_read(const char* path, char *buf, size_t size, off_t offset, struct fuse_file_info* fi) {
    printf("wfs_read called with path: %s\n", path);
    return 0;
}

/*
 * As for read above, except that it can't return 0.
 */
static int wfs_write(const char* path, const char *buf, size_t size, off_t offset, struct fuse_file_info* fi) {
    printf("wfs_write called with path: %s\n", path);
    return 0;
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
    return 0;
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
    if (argc < 3){
        fprintf(stderr,"Not enough arguments");
        return -1;
    }

    // number of disks to mount
    int num_disks = 0;
    char *mount_point = NULL;

    // count the number of disks until -s is hit and get mnt
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-s") == 0) {
            if (i + 1 < argc) {
                mount_point = argv[i + 1];
                break;
            }
        }
        num_disks++;
    }

    // fails if no -s flag or mnt point
    if (!mount_point) {
        fprintf(stderr, "Error: No -s flag or mount point provided.\n");
        return -1;
    }

    // fill disks array
    char *disks[num_disks];
    for (int i = 0; i < num_disks; i++) {
        disks[i] = argv[i + 1];
    }

    // try to mount the filesystem
    if (mount_fs(disks, num_disks) != 0) {
        return -1;
    }

    // Now run FUSE main loop
    return fuse_main(argc, argv, &ops, NULL);
    
}