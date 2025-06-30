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

resource "google_project_iam_member" "project" {
  project = var.project_id
  role    = "roles/cloudasset.viewer"
  member  = "group:prowler@example.com"
}

resource "google_compute_network" "default" {
  name                    = "default"
  project                 = var.project_id
  auto_create_subnetworks = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_firewall" "rdp" {
  name    = "default-allow-rdp"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["rdp"]
}

resource "google_compute_firewall" "ssh" {
  name    = "default-allow-ssh"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["ssh"]
}

resource "google_project_service_identity" "artifactregistry" {
  provider = google
  project  = var.project_id
  service  = "artifactregistry.googleapis.com"
}

resource "google_project_iam_binding" "artifactregistry" {
  provider = google
  project  = var.project_id
  role   = "roles/artifactregistry.reader"
  members = [
    "serviceAccount:${google_project_service_identity.artifactregistry.email}"
  ]
}

resource "google_artifact_registry_repository" "default" {
  provider = google
  project  = var.project_id
  location = var.region
  repository_id = "default-repository"
  format = "DOCKER"
}

resource "google_container_analysis_occurrence" "default" {
  provider = google
  project = var.project_id
  note = "projects/goog-analysis/notes/PACKAGE_VULNERABILITY"
  resource_uri = "https://gcr.io/${var.project_id}/test-image:latest"

  effective_severity = "CRITICAL"
}

resource "google_project_iam_member" "oslogin" {
  project = var.project_id
  role    = "roles/compute.osLogin"
  member  = "user:testuser@example.com"
}

resource "google_compute_subnetwork" "default" {
  for_each = toset(var.default_subnets)

  name          = each.key
  ip_cidr_range = "10.10.10.0/24"
  network       = "default"
  project       = var.project_id
  region        = each.key

  log_config {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_logging_project_sink" "default" {
  name        = "default-sink"
  project     = var.project_id
  description = "exports all logs to a bucket"
  destination = "storage.googleapis.com/${var.project_id}-logs"
  filter      = "resource.type=gcs_bucket OR resource.type=gae_app"
}
