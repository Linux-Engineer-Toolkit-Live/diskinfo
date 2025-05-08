#!/bin/bash

# LEToolkit Live - Disk Information Tool
# This tool provides detailed information about system disks

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print section headers
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Function to get disk information
get_disk_info() {
    print_header "Physical Disk Information"
    
    # List all block devices with detailed information
    echo -e "${YELLOW}Available Physical Disks:${NC}"
    lsblk -d -o NAME,SIZE,MODEL,SERIAL,ROTA,TRAN,REV
    
    print_header "Detailed Partition Information"
    # Show detailed partition information with UUID and PARTUUID
    echo -e "${YELLOW}Partition Details:${NC}"
    lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,LABEL,UUID,PARTUUID
    
    print_header "Filesystem Information"
    # Show filesystem information with more details
    echo -e "${YELLOW}Mounted Filesystems:${NC}"
    df -h --output=source,fstype,size,used,avail,pcent,mountpoint | grep -v tmpfs
    
    print_header "Disk Interface Information"
    # Show disk interface information
    for disk in $(lsblk -d -o NAME | grep -v "loop\|sr"); do
        echo -e "\n${YELLOW}Interface details for $disk:${NC}"
        udevadm info --query=property --name="/dev/$disk" | grep -E "ID_BUS|ID_MODEL|ID_SERIAL|ID_REVISION|ID_PATH"
    done
    
    print_header "Partition Table Information"
    # Show partition table information
    for disk in $(lsblk -d -o NAME | grep -v "loop\|sr"); do
        echo -e "\n${YELLOW}Partition table for $disk:${NC}"
        fdisk -l "/dev/$disk" 2>/dev/null || echo "No partition table information available"
    done
}

# Main execution
echo -e "${GREEN}LEToolkit Live - Disk Information Tool${NC}"
echo "Gathering disk information..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Warning: Some information may be limited. Run as root for complete information.${NC}"
fi

# Get disk information
get_disk_info

echo -e "\n${GREEN}Disk information gathering complete.${NC}"
