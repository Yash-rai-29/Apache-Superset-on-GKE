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
  location = "us-central1"
  repository_id = "default"
  project = var.project_id
  format = "DOCKER"
}

resource "google_project_service" "containeranalysis" {
  provider = google
  project            = var.project_id
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_iam_member" "containeranalysis" {
  provider = google
  project = var.project_id
  role = "roles/containeranalysis.notes.occurrences.viewer"
  member = "serviceAccount:${google_project_service_identity.artifactregistry.email}"
}

resource "google_project_service" "cloudasset" {
  provider = google
  project = var.project_id
  service = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_network" "default" {
  name                    = "default"
  project                 = var.project_id
  delete_default_routes = true
}

resource "google_compute_network" "default_delete" {
  name                    = "default"
  project                 = var.project_id
  depends_on = [
    google_compute_network.default
  ]
  delete_default_routes = true
  lifecycle {
    ignore_changes = [
      delete_default_routes
    ]
    create_before_destroy = true
  }
}

resource "google_compute_network" "default_dns" {
  name                    = "default"
  project                 = var.project_id
  enable_dns_logging = true
  depends_on = [
    google_compute_network.default
  ]
  lifecycle {
    ignore_changes = [
      enable_dns_logging
    ]
    create_before_destroy = true
  }
}

resource "google_compute_firewall" "rdp" {
  name    = "default-allow-rdp"
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
  priority      = 65534
}

resource "google_compute_firewall" "ssh" {
  name    = "default-allow-ssh"
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
  priority      = 65534
}

resource "google_compute_subnet" "default_flow_logs" {
  for_each = toset(var.regions)
  name                     = "default"
  project                  = var.project_id
  region                   = each.key
  network                  = "default"
  ip_cidr_range            = "10.128.0.0/20"
  private_ip_google_access = true
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_project_metadata" "oslogin" {
  project = var.project_id

  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_storage_bucket" "buckets" {
  for_each = toset(var.bucket_names)
  name          = each.key
  project       = var.project_id
  location      = "US"
  uniform_bucket_level_access = true
}

resource "google_logging_project_sink" "default" {
  name        = "all-logs"
  project     = var.project_id
  description = "A sink that exports copies of all log entries in the project."
  destination = "storage.googleapis.com/${var.project_id}-all-logs"
  filter      = "NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Fdata_access"

  writer_identity = "serviceAccount:gcp-sa-logging@${var.project_id}.iam.gserviceaccount.com"
}
