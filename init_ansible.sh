#!/bin/bash

# Function to determine the network range
get_network_range() {
  IP_ADDR=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -n 1)
  IFACE=$(route get default | grep interface | awk '{print $2}')
  SUBNET_MASK=$(ifconfig "$IFACE" | grep netmask | awk '{print $4}')
  
  NETWORK_ADDR=$(ipcalc -n "$IP_ADDR" "$SUBNET_MASK" | grep Network | awk '{print $2}')
  echo "$NETWORK_ADDR"
}

# Function to wait for a host to become reachable
wait_for_host_reachable() {
  local HOST_IP=$1
  local HOST_NAME=$2
  
  echo -e "\nWaiting for $HOST_NAME at $HOST_IP to become reachable..."
  
  timeout=20  # Timeout in seconds
  start_time=$(date +%s)
  while ! ping -c 1 -W 1 "$HOST_IP" &> /dev/null; do
    sleep 5
    echo "Waiting for $HOST_NAME at $HOST_IP to become reachable..."
    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))
    if [ $elapsed_time -ge $timeout ]; then
      echo "Timeout waiting for $HOST_NAME ($HOST_IP) to become reachable."
      exit 1
    fi
  done
  
  echo "A connection has been established with the $HOST_NAME node."
}

# Function to fetch and add SSH keys to known_hosts for a given host IP
fetch_and_add_ssh_keys() {
  local HOST_IP=$1
  local HOST_NAME=$2
  
  # Fetch SSH keys using ssh-keyscan
  SSH_KEYS=$(ssh-keyscan -H "$HOST_IP" 2>/dev/null)
  
  # Check if ssh-keyscan was successful in retrieving keys
  if [ -n "$SSH_KEYS" ]; then
    # Process each line of ssh_keys output using grep
    echo "$SSH_KEYS" | grep -E "(ssh-rsa|ecdsa-sha2-nistp256|ssh-ed25519)\s+" | while IFS= read -r line; do
      AUTH_METHOD=$(echo "$line" | awk '{print $2}')
      KEY=$(echo "$line" | awk '{print $3}')
      
      # Add the key to known_hosts file if pairing doesn't already exist
      if ! grep -q "^$HOST_IP $AUTH_METHOD" ~/.ssh/known_hosts; then
        echo "$HOST_IP $AUTH_METHOD $KEY" >> ~/.ssh/known_hosts
      fi
    done
    
  else
    echo "Failed to fetch SSH keys for $HOST_NAME ($HOST_IP)."
  fi
}

# Get the network range
NETWORK_RANGE=$(get_network_range)
echo "Determined network range: $NETWORK_RANGE"

# Scan the network for devices
echo "Scanning the network ($NETWORK_RANGE) for devices..."
nmap_output=$(nmap -sn "$NETWORK_RANGE" 2>/dev/null)

# Define expected node names and initialize arrays
PI_USERNAME="pi"
EXPECTED_NODE_NAMES=("master" "worker1" "worker2" "worker3")
NODE_IPS=()
NODE_NAMES=()

# Extract IPs and hostnames for Raspberry Pi devices based on specific hostnames
for NODE_NAME in "${EXPECTED_NODE_NAMES[@]}"; do
  NODE_INFO=$(echo "$nmap_output" | grep -A 1 "$NODE_NAME" | grep "Nmap scan report" | awk '{print $NF}' | tr -d '()')
  if [ -n "$NODE_INFO" ]; then
    NODE_IPS+=("$NODE_INFO")
    NODE_NAMES+=("$NODE_NAME")
  fi
done

# Check if all Raspberry Pi devices were found
if [ ${#NODE_IPS[@]} -ne ${#EXPECTED_NODE_NAMES[@]} ]; then
  echo -e "\nError: Not all Raspberry Pi devices were found on the network."
  echo "Expecting to find ${#EXPECTED_NODE_NAMES[@]} devices but only found ${#NODE_IPS[@]}."
  exit 1
else
  echo -e "\nRaspberry Pi devices found at the following IP addresses:"
  for i in "${!NODE_IPS[@]}"; do
    echo "${NODE_NAMES[$i]}: ${NODE_IPS[$i]}"
  done
fi

# Ensure each node is reachable and add to known_hosts
for i in "${!NODE_IPS[@]}"; do
  HOST_NAME=${NODE_NAMES[$i]}
  HOST_IP=${NODE_IPS[$i]}

  if [ -z "$HOST_IP" ]; then
    echo "Error: IP address for $HOST_NAME not found."
    continue
  fi

  # Wait until a connection can be established with the host
  wait_for_host_reachable "$HOST_IP" "$HOST_NAME"

  # Retrieve SSH keys and store them to the known_hosts file
  fetch_and_add_ssh_keys "$HOST_IP" "$HOST_NAME"
done

# Create Ansible inventory file in the correct directory
INVENTORY_FILE="ansible/hosts"
echo "[master_node]" > "$INVENTORY_FILE"
echo "master ansible_host=${NODE_IPS[0]} ansible_user=$PI_USERNAME ansible_ssh_pass='{{ lookup(\"env\", \"ANSIBLE_SSH_PASS\") }}'" >> "$INVENTORY_FILE"

echo -e "\n[worker_nodes]" >> "$INVENTORY_FILE"
for i in 1 2 3; do
  echo "${NODE_NAMES[$i]} ansible_host=${NODE_IPS[$i]} ansible_user=$PI_USERNAME ansible_ssh_pass='{{ lookup(\"env\", \"ANSIBLE_SSH_PASS\") }}'" >> "$INVENTORY_FILE"
done

echo -e "\n[rpi_cluster:children]" >> "$INVENTORY_FILE"
{ echo "master_node"; echo "worker_nodes"; } >> "$INVENTORY_FILE"

echo -e "\nNetwork scan, SSH key retrieval, and Ansible inventory setup complete."
echo "Ansible inventory file created as $INVENTORY_FILE."
