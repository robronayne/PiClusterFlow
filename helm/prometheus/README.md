# Deploying Prometheus via Helm

This guide provides instructions on how to deploy Prometheus on your Kubernetes cluster using Helm. It also includes steps to perform port forwarding to access the Prometheus web UI.

## Prerequisites

- Kubernetes cluster
- Helm installed and configured
- Access to your Kubernetes cluster with kubectl
- Node Exporter installed and running on all nodes

## Installing Node Exporter

Before deploying Prometheus, ensure that Node Exporter is installed and running on all your nodes. If you have not already done so, navigate to the Ansible directory and run the playbook for its installation.

## Deploy Prometheus

### Add the Prometheus Helm Repository

First, add the Prometheus Community Helm repository:
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### Create a Namespace for Prometheus

Create a monitoring namespace:
```bash
kubectl create namespace monitoring
```

### Install Prometheus

Navigate to your Helm chart directory and install Prometheus:
```bash
cd helm/prometheus
helm install prometheus . --namespace monitoring
```
This command installs Prometheus in the monitoring namespace using the local Helm chart.

## Verify the Deployment

### Check Pod Status

Check the status of the Prometheus pods to ensure they are running:
```bash
kubectl get pods -n monitoring -l app=prometheus
```

Expected Output:
```bash
NAME                                     READY   STATUS    RESTARTS   AGE
prometheus-<unique-id>                   2/2     Running   0          2m
```

### Find the Prometheus Service

To find the service that you need to port forward, run the following command:
```bash
kubectl get svc -n monitoring
```

Look for the Prometheus service. The expected output should include something like:
```bash
NAME                    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
prometheus              ClusterIP   10.43.200.100    <none>        9090/TCP   2m
```

### Port Forward to Access Prometheus UI

To access the Prometheus web UI, you need to perform port forwarding:
```bash
kubectl port-forward svc/prometheus-server 9090:9090 -n monitoring
```

This forwards the Prometheus server port to `localhost:9090` on your local machine.

### Access Prometheus UI

Open your web browser and navigate to:
```plaintext
http://localhost:9090
```
You should see the Prometheus web interface.

#### Run the `up` Query

To verify that Prometheus is scraping the metrics from all nodes, run the `up` query:
1. Click on the "Graph" tab.
2. In the query input box, type `up` and click "Execute".
3. You should see results for all your nodes. If everything is configured correctly, you should see entries for each of your Raspberry Pi nodes and the Prometheus server itself.

Expected Output:
```plaintext
up{instance="192.168.86.232:9100", job="raspberry-pi-nodes"} 1
up{instance="192.168.86.233:9100", job="raspberry-pi-nodes"} 1
up{instance="192.168.86.234:9100", job="raspberry-pi-nodes"} 1
up{instance="192.168.86.235:9100", job="raspberry-pi-nodes"} 1
up{instance="localhost:9090", job="prometheus"} 1
```
