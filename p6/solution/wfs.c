#define FUSE_USE_VERSION 30
#include <fuse.h>
#include <errno.h>
#include <time.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "wfs.h"

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
    if (read_superblock(disks[0]) != 0) {
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
static int wfs_getattr(const char* path, struct stat* stbuf){
    printf("wfs_getattr called with path: %s\n", path);
}

/*
 * Make a special (device) file, FIFO, or socket. 
 * See mknod(2) for details.
 */
static int wfs_mknod(const char *path, mode_t mode, dev_t dev){
    printf("wfs_mknod called with path: %s\n", path);
}

/*
 * Create a directory with the given name. The directory permissions are encoded in mode. 
 *
 * See mkdir(2) for details. 
 * This function is needed for any reasonable read/write filesystem.
 */
static int wfs_mkdir(const char *path, mode_t mode){
    printf("wfs_mkdir called with path: %s\n", path);
}

/*
 * Remove (delete) the given file, symbolic link, hard link, or special node. 
 *
 * Note that if you support hard links, unlink only deletes the data when the last hard link 
 * is removed. 
 * See unlink(2) for details.
 */
static int wfs_unlink(const char *path){
    printf("wfs_unlink called with path: %s\n", path);
}

/*
 * Remove the given directory. 
 *
 * This should succeed only if the directory is empty (except for "." and ".."). 
 * See rmdir(2) for details.
 */
static int wfs_rmdir(const char *path) {
    printf("wfs_rmdir called with path: %s\n", path);
}

/*
 * Read sizebytes from the given file into the buffer buf, beginning offset bytes into the file. 
 *
 * See read(2) for full details. 
 * Returns the number of bytes transferred, or 0 if offset was at or beyond the end of the file. 
 * Required for any sensible filesystem.
 */
wfs_read(const char* path, char *buf, size_t size, off_t offset, struct fuse_file_info* fi){
    printf("wfs_read called with path: %s\n", path);
}

/*
 * As for read above, except that it can't return 0.
 */
wfs_write(const char* path, char *buf, size_t size, off_t offset, struct fuse_file_info* fi){
    printf("wfs_write called with path: %s\n", path);
}

/*
 * Return one or more directory entries (struct dirent) to the caller. 
 * This is one of the most complex FUSE functions. 
 * It is related to, but not identical to, the readdir(2) and getdents(2) system calls, and the 
 * readdir(3) library function. 
 * Because of its complexity, it is described separately below. Required for essentially any filesystem, since it's what makes ls and a whole bunch of other things work.
 */
wfs_readdir(const char* path, void* buf, fuse_fill_dir_t filler, off_t offset, struct fuse_file_info* fi){
    printf("wfs_readdir called with path: %s\n", path);
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
    return mount_fs(disks, num_disks);
}