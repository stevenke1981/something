#!/bin/sh

# Define bridge interface name and vSwitch name
BRIDGE=br-lan
VSWITCH=eth0

# Check if the Open vSwitch package is installed
if ! opkg list-installed | grep -q openvswitch; then
  echo "Open vSwitch package is not installed. Please install it first."
  exit 1
fi

# Backup the current configuration
cp /etc/config/network /etc/config/network.backup

# Stop the bridge interface
ifconfig $BRIDGE down

# Remove the bridge configuration
brctl delbr $BRIDGE

# Configure the vSwitch interface
ovs-vsctl add-br $VSWITCH

# Add the physical interface to the vSwitch
ovs-vsctl add-port $VSWITCH eth0

# Bring up the vSwitch interface
ifconfig $VSWITCH up
