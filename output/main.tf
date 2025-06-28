terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
}

resource "google_project_service_identity" "artifactregistry" {
  provider = google
  project  = var.project_id
  service  = "artifactregistry.googleapis.com"
}

resource "google_artifact_registry_repository" "default" {
  depends_on = [google_project_service_identity.artifactregistry]

  provider = google
  project  = var.project_id
  location = "us-central1"
  repository_id = "default-repo"
  format = "DOCKER"
}

resource "google_container_analysis_occurrence" "container_scan" {
  depends_on = [google_artifact_registry_repository.default]

  project = var.project_id
  note_name = "projects/goog-analysis/notes/PACKAGE_VULNERABILITY"
  resource_uri = "us-central1-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.default.name}/test-image:latest"
}

resource "google_project_service" "container_analysis" {
  provider = google
  project            = var.project_id
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudasset" {
  provider = google
  project            = var.project_id
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "gcr" {
  provider = google
  project            = var.project_id
  service            = "containerregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_default_network" "default" {
  project = var.project_id
  action  = "delete"
}

resource "google_compute_firewall" "rdp" {
  project = var.project_id
  name    = var.default_allow_rdp_firewall_rule_name
  network = var.default_network_name

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

resource "google_compute_firewall" "ssh" {
  project = var.project_id
  name    = var.default_allow_ssh_firewall_rule_name
  network = var.default_network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

resource "google_compute_network" "default" {
  name                    = var.default_network_name
  project                 = var.project_id
  delete_default_routes = true
}

resource "google_compute_network" "main" {
  name = "vpc-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  for_each = toset(var.regions)

  name                     = "subnet-${each.value}"
  ip_cidr_range            = "10.10.${index(var.regions, each.value)}.0/24"
  region                   = each.value
  network                  = google_compute_network.main.id
  private_ip_google_access = true
  project                  = var.project_id
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_project_default_service_accounts" "default_accounts" {
  project = var.project_id
  action  = "DISABLE"
}

resource "google_compute_project_metadata" "metadata" {
  project = var.project_id
  metadata = {
    enable-oslogin = "true"
  }
}

resource "google_logging_project_sink" "log_sink" {
  name = "all-logs"
  destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/logging_dataset"
  filter = "NOT logName:\"projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Fdata_access\""
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id = "logging_dataset"
  friendly_name = "BigQuery Dataset for Logs"
  description = "This is a test dataset for storing logs"
  location = "US"
}

resource "google_storage_bucket" "buckets" {
  for_each = toset(var.bucket_names)

  name          = each.value
  project       = var.project_id
  location      = "AUSTRALIA-SOUTHEAST1"
  force_destroy = true
  uniform_bucket_level_access = true
}
