terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.14.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.default_region
}

resource "google_project_service_identity" "artifactregistry" {
  provider = google
  project  = var.project_id
  service  = "artifactregistry.googleapis.com"
}

resource "google_artifact_registry_repository" "default" {
  provider = google
  project  = var.project_id
  location = var.default_region
  repository_id = "default-repository"
  format      = "DOCKER"
}

resource "google_storage_bucket" "default_buckets" {
  provider = google
  name          = element(var.bucket_names, count.index)
  location      = "AUSTRALIA-SOUTHEAST1"
  project       = var.project_id
  uniform_bucket_level_access = true

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30
    }
  }
  count = length(var.bucket_names)
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
  disabled = true

  source_ranges = ["0.0.0.0/0"]
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
  disabled = true
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_network" "default" {
  provider = google
  name                    = "default"
  project                 = var.project_id
  auto_create_subnetworks = false
  delete_default_routes = true
}

resource "google_compute_network" "vpc_network" {
  provider = google
  name                    = "vpc-network"
  project                 = var.project_id
  auto_create_subnetworks = true
}

resource "google_compute_subnetwork" "default_subnetworks" {
  provider = google
  name                     = "default"
  project                  = var.project_id
  ip_cidr_range            = "10.0.0.0/20"
  region                   = element(var.subnet_regions, count.index)
  network                  = "default"
  private_ip_google_access = true
  flow_logs = true

  count = length(var.subnet_regions)
}

resource "google_project_iam_member" "cloud_asset_inventory" {
  provider = google
  project = var.project_id
  role    = "roles/cloudasset.serviceAgent"
  member  = "serviceAccount:cloudasset.googleapis.com@${var.project_id}.iam.gserviceaccount.com"
}

resource "google_project_service" "cloudasset" {
  provider = google
  project = var.project_id
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "gcr" {
  provider = google
  project = var.project_id
  service = "containerregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_iam_member" "logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${var.project_id}@appspot.gserviceaccount.com"
}

resource "google_logging_project_sink" "default" {
  provider = google
  name        = "default-sink"
  project     = var.project_id
  destination = "storage.googleapis.com/${var.project_id}-logs"
  filter      = "resource.type=gce_instance AND severity>=ERROR"
}
