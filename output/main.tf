terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.24.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service_identity" "gcr_service_account" {
  provider = google
  project = var.project_id
  service = "containerregistry.googleapis.com"
}

resource "google_project_iam_member" "gcr_access" {
  provider = google
  project = var.project_id
  role    = "roles/containeranalysis.occurrences.viewer"
  member  = "serviceAccount:${google_project_service_identity.gcr_service_account.email}"
}

resource "google_container_analysis_occurrence" "note_occurrence" {
    provider = google
    project  = var.project_id
    note_name = "providers/${var.project_id}/notes/container-scan-note"
    resource_uri = "https://gcr.io/${var.project_id}/test-image:latest"
}

resource "google_container_analysis_note" "container_scan" {
    provider = google
    project = var.project_id
    name = "container-scan-note"

    attestation_authority {
      hint {
        human_readable_name = "Example container analysis note"
      }
    }
}


resource "google_project_service" "artifactregistry" {
  provider = google
  project            = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "my_repo" {
  provider = google
  project      = var.project_id
  location     = var.region
  repository_id = "my-repo"
  format        = "DOCKER"
}

resource "google_project_service" "cloudasset" {
  provider = google
  project = var.project_id
  service = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "oslogin" {
  provider = google
  project = var.project_id
  service = "oslogin.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_metadata" "oslogin_enable" {
  project = var.project_id
  metadata = {
    enable-oslogin = "TRUE"
  }
}


resource "google_compute_network" "default" {
  provider = google
  name                    = "default"
  project                 = var.project_id
  delete_default_routes = true
}

resource "google_compute_firewall" "rdp" {
  provider = google
  name    = "default-allow-rdp"
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

resource "google_compute_firewall" "ssh" {
  provider = google
  name    = "default-allow-ssh"
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

resource "google_compute_network" "default_network" {
  provider = google
  name                    = "default"
  project                 = var.project_id
  delete_default_routes = true
}

resource "google_compute_network" "vpc_network" {
  provider = google
  name                    = "vpc-network"
  project                 = var.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default_subnets" {
  provider = google
  for_each = toset(var.default_subnets)
  name                     = "default-${each.value}"
  ip_cidr_range            = "10.10.0.0/20"
  network                  = google_compute_network.vpc_network.id
  project                  = var.project_id
  region                   = each.value
  private_ip_google_access = true
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_network" "dns_logging" {
  provider = google
  name                    = "default"
  project                 = var.project_id
  delete_default_routes = true
  enable_logging = true
}


resource "google_storage_bucket" "buckets" {
  provider = google
  for_each = toset(var.bucket_names)
  name                        = each.value
  project                     = var.project_id
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_logging_project_sink" "default" {
  provider = google
  name        = "all-logs"
  project     = var.project_id
  destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/logging"
  filter      = "resource.type = gcs_bucket OR resource.type = gce_instance"
}
