#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root or with sudo." >&2
    exit 1
fi

# Clear the screen
clear

# List all block devices
lsblk

# Ask user for the disk
while true; do
    echo -n "Enter the disk to use for install (e.g., /dev/sda): "
    read disk
    if lsblk "$disk" > /dev/null 2>&1; then
        break
    else
        echo "Disk not found. Please try again."
    fi
done

# Confirmation to proceed
echo "Selected disk: $disk"
echo "WARNING: All data on $disk will be destroyed!"
echo -n "Type 'yes' to confirm and proceed with installation: "
read confirmation
if [ "$confirmation" != "yes" ]; then
    echo "Installation aborted."
    exit 1
fi

# Create new MBR and partitions
(
echo o      # Create a new empty DOS partition table
echo n      # Add a new partition (boot)
echo p      # Primary partition
echo 1      # Partition number 1
echo        # Default - start at beginning of disk
echo +500M  # 500 MB boot partition
echo a      # Make a partition bootable
echo 1      # Bootable partition number
echo n      # Add new partition (swap)
echo p      # Primary partition
echo 2      # Partition number 2
echo        # Default - start immediately after preceding partition
echo +16G   # 16 GB swap partition
echo n      # Add new partition (root)
echo p      # Primary partition
echo 3      # Partition number 3
echo        # Default - start immediately after preceding partition
echo +50G   # 50 GB root partition
echo w      # Write changes
) | fdisk $disk

# Format the partitions
mkfs.vfat -n NIXBOOT ${disk}1
mkswap -L NIXWAP ${disk}2
mkfs.ext4 -L NIXROOT ${disk}3

# Set up the swap
swapon ${disk}2

# Mount the root and boot partitions
mount ${disk}3 /mnt
mkdir /mnt/boot
mount ${disk}1 /mnt/boot

# Generate the initial NixOS config
nixos-generate-config --root /mnt

# Configure the nix channels in the new system root
chroot /mnt /bin/bash -c 'nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware'
chroot /mnt /bin/bash -c 'nix-channel --update'

# Download the user's custom NixOS configuration
wget https://raw.githubusercontent.com/memecian/nixos-conf/main/configuration.nix -O /mnt/etc/nixos/configuration.nix

# Replace the placeholder with the selected install disk
sed -i "s|%InstallDisk%|$disk|g" /mnt/etc/nixos/configuration.nix

# Change to /mnt to prepare for installation
cd /mnt

# Start NixOS installation
nixos-install

# Post-installation message
echo "NixOS installation complete! You can reboot your system now."
