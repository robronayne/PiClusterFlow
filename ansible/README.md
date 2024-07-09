# Running the Ansible Playbook

To set up your Raspberry Pi cluster, including installing and updating dependencies, Docker, Helm, and k3s, follow these steps:

## Run the Ansible Playbook

1. **Navigate to the Ansible Directory:**
   ```bash
   cd ansible
   ```

2. **Run the Playbook:**
   Execute the Ansible playbook to install and update dependencies, Docker, Helm, and k3s on all nodes.
   ```bash
   ansible-playbook playbooks/site.yml
   ```

## Playbook Overview

The playbook `playbooks/site.yml` performs the following tasks:
- Updates and installs necessary dependencies.
- Installs Docker.
- Installs Helm.
- Installs and configures k3s on the master and worker nodes.
- Installs Node Exporter
- Ensures that Docker and Helm are installed, and Kubernetes is running.

## Verification

After running the playbook, you can verify that Docker, Helm, Kubernetes, and Node Exporter are correctly installed and running on all nodes.

1. **Verify Docker Installation**
   Check Docker Version:
   ```bash
   ansible all -m shell -a "docker --version"
   ```

   Expected Output:
   ```bash
   master | CHANGED | rc=0 >>
   Docker version 20.10.7, build f0df350
   worker1 | CHANGED | rc=0 >>
   Docker version 20.10.7, build f0df350
   worker2 | CHANGED | rc=0 >>
   Docker version 20.10.7, build f0df350
   worker3 | CHANGED | rc=0 >>
   Docker version 20.10.7, build f0df350
   ```

2. **Verify Helm Installation**
   Check Helm Version:
   ```bash
   ansible master_node -m shell -a "helm version --short"
   ```

   Expected Output:
   ```bash
   master | CHANGED | rc=0 >>
   v3.6.3+g22079b6
   ```

3. **Verify Kubernetes Installation**
   On the master node, run the following command to check the status of all nodes in the cluster:
   ```bash
   kubectl get nodes
   ```

   Expected Output:
   ```bash
   NAME       STATUS   ROLES                  AGE   VERSION
   master     Ready    control-plane,master   10m   v1.21.1+k3s1
   worker1    Ready    <none>                 10m   v1.21.1+k3s1
   worker2    Ready    <none>                 10m   v1.21.1+k3s1
   worker3    Ready    <none>                 10m   v1.21.1+k3s1
   ```

4. **Verify Node Exporter Installation**
   Check the status of the Node Exporter service on all nodes:
   ```bash
   ansible all -m shell -a "systemctl is-active node_exporter" -b
   ```

   Expected Output (truncated/abbreviated): 
   ```bash
   master | CHANGED | rc=0 >>
   ● node_exporter.service - Node Exporter
      Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; preset: enabled)
      Active: active (running) since <date>; <time> ago
      Main PID: <PID> (node_exporter)
         Tasks: <number>
      Memory: <memory>
         CPU: <CPU>
      CGroup: /system.slice/node_exporter.service
               └─<PID> /usr/local/bin/node_exporter
   ```
   The `<date>`, `<time>`, `<PID>`, `<number>`, `<memory>`, and `<CPU>` will be replaced by actual values when run. This abbreviated output indicates that Node Exporter is active and running.
   
### Troubleshooting

If you encounter any issues during the installation or verification steps, you can check the logs for more details:

**Ansible Logs:**
Check the output of the Ansible playbook run for any error messages or failed tasks.

**Docker Logs:**
On any node, you can check the Docker logs using the following command:

```bash
sudo journalctl -u docker.service
```

**Kubernetes Logs:**
On the master node, you can check the Kubernetes logs using the following command:

```bash
sudo journalctl -u k3s
```

**cgroup Settings:**

Ensure that cgroups are enabled. This is necessary in order for k3s to run. You can check this by running `cat /proc/cgroups` on each node to see if the memory group is enabled.

```bash
cat /proc/cgroups
```

Verify that the memory cgroup is enabled. The output should include a line similar to:

```plaintext
memory  0       126       1
```

Additionally, compare the output of your `cmdline.txt` file to ensure it has the necessary parameters for cgroup settings. The file should contain:

```plaintext
cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1
```

You can check the `cmdline.txt` file by running:

```bash
cat /boot/firmware/cmdline.txt
```

Ensure that the parameters are all on one line.
