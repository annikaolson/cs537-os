#!/bin/bash

# Ensure the number of disks is provided as an argument
if [ $# -lt 1 ]; then
    echo "Usage: $0 <number_of_disks>"
    exit 1
fi

# Number of disks to create
num_disks=$1

# Check if the number of disks is at least 2
if [ $num_disks -lt 2 ]; then
    echo "You must create at least 2 disks."
    exit 1
fi

# Loop to create the specified number of disk images
for ((i=1; i<=num_disks; i++)); do
    # Create a disk with the name diskX.img where X is the disk number
    disk_name="disk${i}.img"
    
    # Create a 1MB disk image
    dd if=/dev/zero of=$disk_name bs=1M count=1
    
done