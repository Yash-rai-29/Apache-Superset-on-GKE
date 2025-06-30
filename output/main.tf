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

resource "google_project_service_identity" "artifactregistry" {
  provider = google
  project  = var.project_id
  service  = "artifactregistry.googleapis.com"
}

resource "google_project_iam_member" "artifactregistry" {
  provider = google
  project = var.project_id
  role = "roles/artifactregistry.serviceAgent"
  member = "serviceAccount:${google_project_service_identity.artifactregistry.email}"
}


resource "google_artifact_registry_repository" "default" {
  depends_on = [google_project_iam_member.artifactregistry]
  provider = google
  project  = var.project_id
  location = var.region
  repository_id = "default-repository"
  format = "DOCKER"
}

resource "google_container_analysis_occurrence" "note_occurrence" {
  provider = google
  project = var.project_id
  note = "//containeranalysis.googleapis.com/providers/${var.project_id}/notes/container-scanning-note"
  resource_uri = "gcr.io/${var.project_id}/test-image:latest"
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

resource "google_project_service" "dns" {
  provider = google
  project            = var.project_id
  service            = "dns.googleapis.com"
  disable_on_destroy = false
}


resource "google_compute_project_metadata" "oslogin" {
  project = var.project_id

  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_network" "default" {
  name                    = "default"
  project                 = var.project_id
  delete_default_routes = true

  lifecycle {
    prevent_destroy = true
  }
}


resource "google_compute_network" "custom_network" {
  name                    = "custom-network"
  project                 = var.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default_subnetworks" {
  for_each = toset(var.default_regions)
  name                     = "default-${each.value}"
  ip_cidr_range            = "10.10.0.0/20"
  network                  = google_compute_network.custom_network.id
  project                  = var.project_id
  region                   = each.value
  private_ip_google_access = true
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_project_default_network_tier" "default" {
  project = var.project_id
  network_tier = "PREMIUM"
}

resource "google_compute_firewall" "rdp" {
  name    = "default-allow-rdp"
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = var.rdp_ssh_allowed_cidrs
}

resource "google_compute_firewall" "ssh" {
  name    = "default-allow-ssh"
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.rdp_ssh_allowed_cidrs
}

resource "google_storage_bucket" "buckets" {
  for_each = toset(var.bucket_names)
  name          = each.value
  project       = var.project_id
  location      = "US"
  force_destroy = false
  uniform_bucket_level_access = true
}

resource "google_logging_project_sink" "default" {
  name        = "all-logs"
  project     = var.project_id
  destination = "storage.googleapis.com/${var.project_id}-all-logs"
  filter      = "NOT logName:\"projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Fdata_access\""
}
