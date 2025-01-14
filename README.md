
# Apache Superset on Google Kubernetes Engine (GKE)

This guide provides a detailed walkthrough of deploying Apache Superset on Google Kubernetes Engine (GKE), enabling Jinja templating, and integrating a BigQuery connection.

## Prerequisites

- A Google Cloud Platform (GCP) account
- A GKE cluster
- Helm 3.x installed locally
- kubectl installed locally
- gcloud CLI installed

## Table of Contents
1. [Overview](#overview)
2. [Install Google Cloud SDK](#install-google-cloud-sdk)
3. [Install Kubernetes](#install-kubernetes)
4. [Install Helm](#install-helm)
5. [Install Superset](#install-superset)
6. [Enable Jinja Templating](#enable-jinja-templating)
7. [Add BigQuery as a Database Connection](#add-bigquery-as-a-database-connection)

---

## Overview

Apache Superset is a powerful, open-source data exploration and visualization tool. This guide will help you set up Superset on a GKE cluster with advanced configurations.

---

## Install Google Cloud SDK

1. Install the [Google Cloud SDK](https://cloud.google.com/sdk/docs/install).
2. Authenticate and configure your project by replacing `YOUR_PROJECT_ID` with your GCP project ID:
   ```bash
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   ```

---

## Install Kubernetes

Ensure `kubectl` is installed and linked to your GCP project:
```bash
gcloud components install kubectl
```

---

## Install Helm

Install Helm, the package manager for Kubernetes:
```bash
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

---

## Install Superset

### Step 1: Create a GKE Cluster

Replace `YOUR_PROJECT_ID` with your GCP project ID:
```bash
gcloud beta container --project "YOUR_PROJECT_ID" clusters create "superset-cluster" --zone "us-central1-a" --no-enable-basic-auth --cluster-version "latest" --machine-type "e2-medium" --image-type "COS_CONTAINERD" --disk-size "100" --num-nodes "3" --enable-ip-alias --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver --enable-autoupgrade --enable-autorepair --enable-shielded-nodes
```

### Step 2: Authenticate with the Cluster

```bash
gcloud container clusters get-credentials superset-cluster --zone us-central1-a --project YOUR_PROJECT_ID
```

### Step 3: Add Superset Helm Repository

```bash
helm repo add superset https://apache.github.io/superset
helm repo update
```

### Step 4: Deploy Superset with Helm

Download the custom `values.yaml` file and configure it to suit your environment. Use the following command to deploy Superset:
`values.yaml` file [here](https://raw.githubusercontent.com/Yash-rai-29/Apache-Superset-on-GKE/refs/heads/main/my_values.yaml?token=GHSAT0AAAAAAC5KKNRO73FLBL756YMDTDNIZ4GRVMQ).

```bash
helm upgrade --install --values values.yaml superset superset/superset -n superset
```

### Step 5: Expose Superset Service

Edit the Superset service to change its type to `LoadBalancer`:
```bash
kubectl edit svc superset -n superset
```

Update the service definition:
```yaml
type: LoadBalancer
```

Retrieve the external IP of the service:
```bash
kubectl get svc superset -n superset
```

For local access, use port forwarding:
```bash
kubectl port-forward svc/superset 8088:8088 -n superset
```

---

## Enable Jinja Templating

1. Add the following configuration to `superset_config.py`:
   ```python
   FEATURE_FLAGS = {
       "ENABLE_TEMPLATE_PROCESSING": True,
   }
   ```

2. Apply the configuration by creating a ConfigMap:
   ```bash
   kubectl create configmap superset-config --from-file=superset_config.py -n superset --dry-run=client -o yaml | kubectl apply -f -
   ```

3. Restart the Superset deployment:
   ```bash
   kubectl rollout restart deployment superset -n superset
   ```

---

## Add BigQuery as a Database Connection

1. Log in to the Superset UI.
2. Navigate to **Data** → **Databases** → **+ Database**.
3. Select **Google BigQuery**.
4. Provide the connection string:
   ```
   bigquery://YOUR_PROJECT_ID
   ```
5. Save and test the connection.

---

## Conclusion

Congratulations! You have successfully deployed Apache Superset on GKE, enabled Jinja templating, and added BigQuery as a database connection. Enjoy exploring and visualizing your data!

---
