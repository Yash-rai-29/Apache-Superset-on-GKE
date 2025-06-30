terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_iam_member" "project" {
  project = var.project_id
  role    = "roles/owner"
  member  = "user:example@example.com"
}

resource "google_compute_firewall" "rdp" {
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
  name    = "default-allow-ssh"
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["10.0.0.0/8"]
}

resource "google_compute_network" "default" {
  name                    = "default"
  project                 = var.project_id
  auto_create_subnetworks = false
  delete_default_routes   = true
}

resource "google_compute_network" "vpc_network" {
  name                    = "vpc-network"
  project                 = var.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default_subnet" {
  for_each = toset(var.default_subnets)

  name          = "default-${each.value}"
  project       = var.project_id
  ip_cidr_range = "10.10.0.0/20"
  network       = google_compute_network.vpc_network.id
  region        = each.value
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_project_service_identity" "gcr_service_account" {
  provider = google

  project = var.project_id
  service = "containerregistry.googleapis.com"
}

resource "google_project_iam_binding" "gcr_artifact_registry" {
  provider = google

  project = var.project_id
  role    = "roles/artifactregistry.reader"

  members = [
    "serviceAccount:${google_project_service_identity.gcr_service_account.email}",
  ]
}

resource "google_project_service" "artifactregistry" {
  provider = google

  project                    = var.project_id
  service                    = "artifactregistry.googleapis.com"
  disable_on_destroy         = false
}

resource "google_artifact_registry_repository" "my_repo" {
  provider = google

  project             = var.project_id
  location            = var.region
  repository_id       = "my-repo"
  description         = "Terraform-managed repository."
  format              = "DOCKER"
}

resource "google_project_service" "containeranalysis" {
  provider = google

  project                    = var.project_id
  service                    = "containeranalysis.googleapis.com"
  disable_on_destroy         = false
}

resource "google_storage_bucket" "buckets" {
  for_each = toset(var.bucket_names)
  name          = each.value
  project       = var.project_id
  location      = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}

resource "google_project_service" "cloudasset" {
  provider = google

  project                    = var.project_id
  service                    = "cloudasset.googleapis.com"
  disable_on_destroy         = false
}

resource "google_project_iam_member" "cloudasset_sa" {
  project = var.project_id
  role    = "roles/cloudasset.serviceAgent"
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloudasset.iam.gserviceaccount.com"
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_service" "oslogin" {
  project = var.project_id
  service = "oslogin.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_iam_audit_config" "audit_config" {
  project = var.project_id
  service = "allServices"

  audit_log_config {
    log_type = "ADMIN_READ"
  }

  audit_log_config {
    log_type = "DATA_READ"
  }

  audit_log_config {
    log_type = "DATA_WRITE"
  }
}

resource "google_logging_project_sink" "default_sink" {
  name = "all-logs"
  project = var.project_id
  destination = "storage.googleapis.com/${var.project_id}-logs"
  filter = "NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity"
}

resource "google_storage_bucket" "logging_bucket" {
  name          = "${var.project_id}-logs"
  project       = var.project_id
  location      = "US"
  force_destroy = true
}
