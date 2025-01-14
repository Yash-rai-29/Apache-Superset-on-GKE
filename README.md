
# Apache Superset on Google Kubernetes Engine (GKE)

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
Apache Superset is an open-source data exploration and visualization platform. This guide demonstrates how to deploy Superset on Google Kubernetes Engine (GKE) with Jinja templating enabled and BigQuery added as a database connection.

---

## Install Google Cloud SDK
1. Download and install the [Google Cloud SDK](https://cloud.google.com/sdk/docs/install).
2. Authenticate and configure your project:
   ```bash
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   ```

---

## Install Kubernetes
Ensure `kubectl` is installed and configured:
```bash
gcloud components install kubectl
```

---

## Install Helm
Install Helm, a package manager for Kubernetes:
```bash
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

---

## Install Superset

### Step 1: Create a GKE Cluster
```bash
gcloud beta container --project "test-yash-445816" clusters create "superset3" --zone "us-central1-a" --no-enable-basic-auth --cluster-version "latest" --machine-type "e2-medium" --image-type "COS_CONTAINERD" --disk-size "100" --num-nodes "3" --enable-ip-alias --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver --enable-autoupgrade --enable-autorepair --enable-shielded-nodes
```

### Step 2: Authenticate with the Cluster
```bash
gcloud container clusters get-credentials superset3 --zone us-central1-a --project test-yash-445816
```

### Step 3: Add Superset Helm Repository
```bash
helm repo add superset https://apache.github.io/superset
helm repo update
```

### Step 4: Deploy Superset with Helm
Download the custom `values.yaml` file [here](https://raw.githubusercontent.com/Yash-rai-29/Apache-Superset-on-GKE/refs/heads/main/my_values.yaml?token=GHSAT0AAAAAAC5KKNRO73FLBL756YMDTDNIZ4GRVMQ).

Install Superset with custom configurations:
```bash
helm upgrade --install --values values.yaml superset superset/superset -n superset
```

### Step 5: Edit the Superset Service for External Access
Change the service type to `LoadBalancer`:
```bash
kubectl edit svc superset -n superset
```

Modify the following line:
```yaml
type: LoadBalancer
```

Check the external IP:
```bash
kubectl get svc superset -n superset
```

For local access:
```bash
kubectl port-forward svc/superset 8088:8088 -n superset
```

---

## Enable Jinja Templating
1. Add the following to your `superset_config.py` file:
   ```python
   FEATURE_FLAGS = {
       "ENABLE_TEMPLATE_PROCESSING": True,
   }
   ```
2. Apply the configuration:
   ```bash
   kubectl create configmap superset-config --from-file=superset_config.py -n superset --dry-run=client -o yaml | kubectl apply -f -
   ```
3. Restart the Superset pod:
   ```bash
   kubectl rollout restart deployment superset -n superset
   ```

---

## Add BigQuery as a Database Connection
1. Open Superset UI.
2. Navigate to **Data** → **Databases** → **+ Database**.
3. Choose **Google BigQuery**.
4. Configure the connection string with your service account key:
   ```
   bigquery://project_id
   ```
5. Save and test the connection.

---

## Conclusion
This guide provides a step-by-step process for deploying Apache Superset on GKE with Jinja templating and BigQuery integration.

---
