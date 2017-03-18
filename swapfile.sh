#!/bin/bash
fallocate -l 1G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo -e "\nSwap file stats:\n"
swapon --show
echo -e "\nDisk usage file stats:\n"
free -h
# Swap agressiveness, 0 is low 100 is max
sysctl vm.swappiness=10
echo "vm.swappiness=10" >> /etc/sysctl.conf
# How agressive is file system caching, 0 is low, 100 is max
sysctl vm.vfs_cache_pressure=50
echo "sysctl vm.vfs_cache_pressure=50" >> /etc/sysctl.conf