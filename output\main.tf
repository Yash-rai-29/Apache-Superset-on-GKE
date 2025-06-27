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
}

resource "google_project_service_identity" "gcr_sa" {
  provider = google
  project  = var.project_id
  service  = "containeranalysis.googleapis.com"
}

resource "google_project_iam_member" "container_analysis" {
  provider = google
  project = var.project_id
  role = "roles/containeranalysis.notes.occurrences.viewer"
  member = "serviceAccount:${google_project_service_identity.gcr_sa.email}"
}

resource "google_project_service" "artifactregistry" {
  provider = google
  project = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "container_analysis" {
  provider = google
  project = var.project_id
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
  depends_on = [google_project_iam_member.container_analysis]
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

resource "google_project_service" "oslogin" {
  provider = google
  project = var.project_id
  service            = "oslogin.googleapis.com"
  disable_on_destroy = false
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

resource "google_compute_network_dns_logging_policy" "default" {
  provider = google
  name    = "default"
  project = var.project_id
  network = "default"
  logging_preference = "ON"
}

resource "google_compute_project_metadata" "project" {
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
  ip_cidr_range            = "10.128.0.0/20"
  region                   = each.value
  network                  = "default"
  project                  = var.project_id
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_storage_bucket" "buckets" {
  provider = google
  for_each = toset(var.bucket_names)
  name          = each.value
  project       = var.project_id
  location      = "US"
  uniform_bucket_level_access = true
}

resource "google_logging_project_sink" "default_sink" {
  name   = "all-logs"
  provider = google
  project = var.project_id
  description = "Copies of all log entries"
  destination = "storage.googleapis.com/${var.project_id}-logging-bucket"
  filter = "NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity"

  unique_writer_identity = true
}
