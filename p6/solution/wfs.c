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
void *disk_map = NULL;

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
 * Helper function to read in an inode from the number
 */
void read_inode(int inode_num, struct wfs_inode *inode) {
    // Read from the inode block (simulated as starting from a fixed position in the disk)
    //memcpy(inode, &disk[superblock.i_blocks_ptr + inode_num * sizeof(struct wfs_inode)], sizeof(struct wfs_inode));
    off_t inode_offset = superblock.i_blocks_ptr + inode_num * sizeof(struct wfs_inode);

    // seek to the inode location in the disk map
    if (fseek(disk_map, inode_offset, SEEK_SET) != 0) {
        fprintf(stderr, "Error seeking to inode\n");
        return;
    }

    // read inode data into inode struct
    size_t elmts_read = fread(inode, sizeof(struct wfs_inode), 1, disk_map);
    if (elmts_read != 1) {
        fprintf(stderr, "Error reading inode\n");
    }

}

/*
 * Helper function to read a directory entry from the disk
 */
void read_data_block(off_t block_num, struct wfs_dentry *entry) {
    // directory entries are stored starting from a fixed position in the disk
    //memcpy(entry, &disk[superblock.d_blocks_ptr + block_num * sizeof(struct wfs_dentry)], sizeof(struct wfs_dentry));
}

/*
 * Resolve path into an inode
 * 
 * Returns the inode number or -
 */
int resolve_path(const char *path) {
    char path_copy[MAX_NAME];

    // copy path to avoid modifying the original
    strncpy(path_copy, path, MAX_NAME);

    // start at root directory (inode 0)
    // root directory handling is built in
    int current_inode_num = 0;
    char *component = strtok(path_copy, "/");

    while (component != NULL) {
        struct wfs_inode dir_inode; // directory inode

        // read the current inode
        read_inode(current_inode_num, &dir_inode);
        
        // look up the component (file or directory) in the current directory's blocks
        int found_inode = -1;
        for (int i = 0; i < superblock.num_data_blocks; i++) {
            struct wfs_dentry entry;
            // read in the directory entry
            read_data_block(dir_inode.blocks[i], &entry);

            if (strcmp(entry.name, component) == 0) {
                // found the component, return its inode number
                found_inode = entry.num;
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

    return current_inode_num;  // Return the inode number of the final component
}

// Lazy allocation of an inode
int allocate_inode() {
    for (int i = 0; i < superblock.num_inodes; i++) {
        // Check if the inode is free in the inode bitmap
        fseek(disk_map, superblock.i_bitmap_ptr + i / 8, SEEK_SET);
        unsigned char byte;
        fread(&byte, sizeof(byte), 1, disk_map);
        
        if (!(byte & (1 << (i % 8)))) {  // If the bit is 0, the inode is free
            // Mark the inode as allocated
            byte |= (1 << (i % 8));
            fseek(disk_map, superblock.i_bitmap_ptr + i / 8, SEEK_SET);
            fwrite(&byte, sizeof(byte), 1, disk_map);

            // Return the inode number instead of a fully initialized inode
            return i;
        }
    }
    return -1;  // No free inode available
}

// Lazy allocation of a data block
int allocate_data_block() {
    for (int i = 0; i < superblock.num_data_blocks; i++) {
        fseek(disk_map, superblock.d_bitmap_ptr + i / 8, SEEK_SET);
        unsigned char byte;
        fread(&byte, sizeof(byte), 1, disk_map);

        if (!(byte & (1 << (i % 8)))) {  // Block is free if the corresponding bit is 0
            // Mark the block as allocated
            byte |= (1 << (i % 8));
            fseek(disk_map, superblock.d_bitmap_ptr + i / 8, SEEK_SET);
            fwrite(&byte, sizeof(byte), 1, disk_map);
            
            return i;  // Return the index of the allocated block
        }
    }
    return -1;  // No free data block available
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
    read_inode(inode_num, &inode);

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

    char parent_path[MAX_NAME];
    char dir_name[MAX_NAME];

    // split path into parent path and directory name
    strncpy(parent_path, path, MAX_NAME);
    char *last_slash = strrchr(parent_path, '/');
    if (last_slash == NULL || last_slash == parent_path) {
        // root or invalid path
        strncpy(dir_name, path + 1, MAX_NAME);
        strcpy(parent_path, "/");
    } else {
        strcpy(dir_name, last_slash + 1);
        *last_slash = '\0';
    }

    if (strlen(dir_name) == 0 || strlen(dir_name) >= MAX_NAME) {
        return -EINVAL; // Invalid directory name
    }

    // locate parent directory
    int parent_inode_num = resolve_path(parent_path);
    if (parent_inode_num < 0) {
        return -ENOENT; // parent directory doesn't exist
    }

    // get parent inode
    struct wfs_inode parent_inode;
    read_inode(parent_inode_num, &parent_inode);

    // ensure the parent inode is a directory
    if (!S_ISDIR(parent_inode.mode)) {
        return -ENOTDIR;    // parent is not a directory
    }

    // check for existing directory with same name
    struct wfs_dentry entries[BLOCK_SIZE / sizeof(struct wfs_dentry)];
    int block_found;

    for (int i = 0; i < D_BLOCK; i++) {
        if (parent_inode.blocks[i] != 0) {
            read_data_block(parent_inode.blocks[i], entries);
            for (int j = 0; j < BLOCK_SIZE / sizeof(struct wfs_dentry); j++) {
                if (entries[j].num != 0 && strcmp(entries[j].name, dir_name) == 0) {
                    return -EEXIST;
                }
            }
        } else {
            block_found = i;
            break;
        }
    }

    // allocate inode for new directory
    int new_dir_inode_num = allocate_inode();
    if (new_dir_inode_num < 0) {
        return -ENOSPC;
    }
    
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