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
  region  = var.region
}

resource "google_project_service_identity" "artifactregistry" {
  provider = google
  project  = var.project_id
  service  = "artifactregistry.googleapis.com"
}

resource "google_project_iam_member" "artifactregistry" {
  provider = google
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_project_service_identity.artifactregistry.email}"
}

resource "google_container_analysis_occurrence" "default" {
  provider = google
  project  = var.project_id
  note_name    = "projects/goog-analysis/notes/PACKAGE_VULNERABILITY"
  resource_uri = "https://gcr.io/google_containers/alpine"
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

resource "google_compute_network" "default" {
  provider = google
  name                    = "default"
  project                 = var.project_id
  delete_default_routes = true
}

resource "google_project_default_network_deletion_protection" "deletion_protection" {
  provider = google
  project = var.project_id
  deletion_protection = true
}

resource "google_compute_network" "default_network" {
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

  direction = "INGRESS"
  disabled  = true
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

  direction = "INGRESS"
  disabled  = true
}

resource "google_compute_subnetwork" "default" {
  provider = google
  for_each = toset(var.default_subnets)
  name                     = "default"
  ip_cidr_range            = "10.0.0.0/20"
  network                  = "default"
  project                  = var.project_id
  region                   = each.value
  private_ip_google_access = true
  flow_logs = true
}

resource "google_compute_project_metadata" "metadata" {
  provider = google
  project = var.project_id
  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_storage_bucket" "buckets" {
  provider = google
  for_each = toset(var.bucket_names)
  name          = each.value
  project       = var.project_id
  location      = "US"
  uniform_bucket_level_access = true
}

resource "google_logging_project_sink" "default" {
  provider = google
  name        = "all-logs"
  project     = var.project_id
  destination = "storage.googleapis.com/${var.project_id}-logs"
  filter      = "NOT logName:\"projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity\""
}
