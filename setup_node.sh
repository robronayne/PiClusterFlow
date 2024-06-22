#!/bin/bash

# Check if the node name argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 {master|worker1|worker2|worker3}"
  exit 1
fi

NODE_NAME=$1

# Variables (modify these as needed)
BOOT_DIR="/Volumes/bootfs"
SSH_KEY_PATH="$HOME/.ssh/id_rsa.pub"
SSH_KEY_DIR="$HOME/.ssh"
USER="pi"

# Generate SSH key if it doesn't exist
if [ ! -f "$SSH_KEY_PATH" ]; then
  echo "SSH key not found, generating a new one..."
  mkdir -p "$SSH_KEY_DIR"
  ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_DIR/id_rsa" -N ""
else
  echo "SSH key already exists at $SSH_KEY_PATH"
fi

# Enable SSH, set hostname, and add SSH key for the Raspberry Pi
if [ -d "$BOOT_DIR" ]; then
  touch "$BOOT_DIR/ssh"
  echo "$NODE_NAME" > "$BOOT_DIR/hostname"
  echo "127.0.1.1   $NODE_NAME" > "$BOOT_DIR/hosts"
  
  mkdir -p "$BOOT_DIR/home/$USER/.ssh"
  cat "$SSH_KEY_PATH" > "$BOOT_DIR/home/$USER/.ssh/authorized_keys"

  echo "SSH key added to $NODE_NAME"
  echo "Setup complete for $NODE_NAME. Insert the SD card into your Raspberry Pi and power it on."
else
  echo "Boot directory $BOOT_DIR does not exist. Make sure the microSD card is mounted correctly."
  exit 1
fi
