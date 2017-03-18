#!/bin/bash

fallocate -l 1G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
swapon --show
free -h
sysctl vm.swappiness=10
echo "vm.swappiness=10" >> /etc/sysctl.conf