terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.68.0"
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
  provider = google
  project  = var.project_id
  location = "us-central1"
  repository_id = "default"
  format      = "DOCKER"
}

resource "google_container_analysis_occurrence" "note_occurrence" {
  provider = google
  project  = var.project_id
  note = "providers/goog-tf-examples/notes/container-scan"
  resource_uri = "gcr.io/cloud-marketplace-tools/test-image@sha256:e669473e9528052a1616d3f46638f29099883fef09983db95418151671ff8c39"
}


resource "google_project_service" "artifactregistry" {
  provider = google
  project = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "containeranalysis" {
  provider = google
  project = var.project_id
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudasset" {
  provider = google
  project = var.project_id
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "dns" {
  provider = google
  project = var.project_id
  service            = "dns.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_network" "default" {
  provider = google
  name                    = "default"
  project                 = var.project_id
  auto_create_subnetworks = false
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

  source_ranges = ["10.0.0.0/8"]
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

  source_ranges = ["10.0.0.0/8"]
}

resource "google_project_iam_member" "oslogin" {
  provider = google
  project = var.project_id
  role   = "roles/compute.osLogin"
  member = "group:google-internal@example.com"
}

resource "google_compute_project_metadata" "metadata" {
  provider = google
  project = var.project_id
  metadata = {
    enable-oslogin = "true"
  }
}

resource "google_compute_subnetwork" "default" {
  provider = google
  for_each = toset(var.regions)
  name                     = "default"
  ip_cidr_range          = "10.10.10.0/24"
  network                  = "default"
  region                   = each.value
  project                  = var.project_id
  private_ip_google_access = true
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_storage_bucket" "buckets" {
  provider = google
  for_each = toset(var.bucket_names)
  name          = each.value
  location      = "US"
  project       = var.project_id
  uniform_bucket_level_access = true
}

resource "google_logging_project_sink" "default" {
  name   = "all-logs"
  description = "Sink for all logs"
  destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/logging_dataset"
  filter    = "NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity OR NOT logName:projects/${var.project_id}/logs/system.log"
  project = var.project_id
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id = "logging_dataset"
  friendly_name = "Logging Dataset"
  location = "US"
  project = var.project_id
}
