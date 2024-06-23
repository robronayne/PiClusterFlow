# PiClusterFlow

This repository contains scripts and configuration files to set up a Raspberry Pi cluster with Prometheus, Grafana, and K3s. The motivation behind this project is to create a small-scale, efficient, and flexible cluster environment for running Kubernetes and Airflow. The goal is to automate DAG scheduling for various web scraping scripts, including automated campsite booking and scraping for surfing conditions.

## Directory Structure

```
PiClusterFlow/
├── ansible/
│   ├── ansible.cfg
│   ├── hosts
│   ├── playbook.yml
│   └── roles/
│       ├── common/
│       │   └── tasks/
│       │       └── main.yml
│       ├── k3s_master/
│       │   └── tasks/
│       │       └── main.yml
│       └── k3s_worker/
│           └── tasks/
│               └── main.yml
├── setup_node.sh
├── init_ansible.sh
└── README.md
```

## Hardware Configuration

To set up your Raspberry Pi cluster, you'll need the following hardware:

- Raspberry Pi 4 Model B — 1 GB RAM (x4)
- Raspberry Pi PoE+ HAT (x4)
- Black Ethernet Patch Cable — 0.5 Feet (x4)
- Blue Ethernet Patch Cable — 2 Feet
- TP-Link TL-SG1005P, 5 Port PoE Switch
- UCTRONICS Enclosure for Raspberry Pi Cluster
- SanDisk 32GB microSD (x4)
- USB to SATA Adapter for SSD
- HP S750 256GB SSD

For a detailed guide on setting up the hardware, please refer to this article: [Installing Airflow on a Raspberry Pi Cluster: Hardware and Setup](https://robronayne.medium.com/installing-airflow-on-a-raspberry-pi-cluster-hardware-and-setup-7b34ae5655bd)

## Getting Started

### Clone this Git Repository

Clone the repository and navigate into it:
```bash
git clone https://github.com/robronayne/PiClusterFlow.git
cd PiClusterFlow
```

### Install the Raspberry Pi OS on microSD Cards

1. **Install Raspberry Pi Imager and OS:**

   - Download the Raspberry Pi Imager from [https://www.raspberrypi.org/software/](https://www.raspberrypi.org/software/).
   - Insert the SanDisk 32GB microSD card into your computer.
   - Rename the microSD card to `boot`
   - Open the Raspberry Pi Imager and choose the Raspberry Pi OS (32-bit).
   - Select the SD card you inserted.
   - Due to [recent changes](https://www.raspberrypi.com/news/raspberry-pi-bullseye-update-april-2022/), a username and password will have to be provided in order to enable SSH.
   - Click "Next" and configure the host and username with corresponding password in the OS customization menu.
   - When prompted that all existing data will be erased, click "Yes" that you would like to continue.

2. **Prepare the microSD Cards:**

   - Insert the microSD card into your computer.
   - Mount the microSD card's boot partition to the directory `/Volumes/`:
     ```bash
     diskutil list  # Identify the disk identifier for the microSD card (e.g., /dev/disk2)
     diskutil mountDisk /dev/diskX  # Replace /dev/diskX with the appropriate device identifier
     ```
   - Verify the mount:
     ```bash
     ls /Volumes
     ```

3. **Run the `setup_node.sh` Script for Each Node:**

   - Add execution privileges for the script:
     ```bash
     chmod +x setup_node.sh
     ```

   - For the master node:
     ```bash
     sudo ./setup_node.sh master
     ```

   - For the worker nodes:
     ```bash
     sudo ./setup_node.sh worker1
     sudo ./setup_node.sh worker2
     sudo ./setup_node.sh worker3
     ```

4. **Eject the microSD Card:**

   ```bash
   diskutil unmountDisk /dev/diskX  # Replace /dev/diskX with the appropriate device identifier
   ```

5. **Insert Each Prepared microSD Card into the Corresponding Raspberry Pi Device:**

   - The first microSD card into the master node Raspberry Pi.
   - The second microSD card into the worker1 node Raspberry Pi.
   - The third microSD card into the worker2 node Raspberry Pi.
   - The fourth microSD card into the worker3 node Raspberry Pi.
   - Power on each Raspberry Pi and connect them to the network via Ethernet.

### Install Dependencies

#### macOS

1. **Install Homebrew:**
   If Homebrew is not installed, install it by running:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Install Ansible:**
   ```bash
   brew install ansible
   ```

3. **Install `nmap`:**
   For retrieving Raspberry Pi IP addresses:
   ```bash
   brew install nmap
   ```

4. **Install `sshpass`:**
   For authenticating via SSH with Ansible:
   ```bash
   brew install sshpass
   ```

5. **Initialize Ansible:**
   Run the init_ansible.sh script on your computer:
   ```bash
   sudo ./init_ansible.sh
   ```

6. **Save the Raspberry Pi SSH Password:**
   The ansible/hosts file will reference an environment variable for your SSH password so that you do not have to enter it each time you run an Ansible command. You can export this variable as follows:
   ```bash
   export ANSIBLE_SSH_PASS='your_ssh_password_here'
   ```

## Verification

1. **Ping All Nodes**

   ```bash
   cd ansible
   ansible all -m ping --ask-pass
   ```

   Expected Output:
   ```javascript
   master | SUCCESS => {
      "changed": false,
      "ping": "pong"
   }
   worker1 | SUCCESS => {
      "changed": false,
      "ping": "pong"
   }
   worker2 | SUCCESS => {
      "changed": false,
      "ping": "pong"
   }
   worker3 | SUCCESS => {
      "changed": false,
      "ping": "pong"
   }
   ```
