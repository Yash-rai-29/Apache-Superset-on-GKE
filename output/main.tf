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

resource "google_project_service_identity" "cloud_asset" {
  provider = google
  project  = var.project_id
  service  = "cloudasset.googleapis.com"
}

resource "google_project_iam_member" "cloud_asset_inventory" {
  project = var.project_id
  role    = "roles/cloudasset.serviceAgent"
  member  = "serviceAccount:${google_project_service_identity.cloud_asset.email}"
}

resource "google_project_service" "artifactregistry" {
  provider = google
  project            = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "gcr" {
  provider = google
  project            = var.project_id
  service            = "containerregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_container_analysis_occurrence" "default" {
  provider = google
  project = var.project_id
  note_name = "projects/goog-analysis/notes/PACKAGE_VULNERABILITY"
  resource_uri = "https://gcr.io/google-containers/alpine"
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

resource "google_project_service" "compute" {
  provider = google
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_default_network" "default" {
  project = var.project_id
  name    = var.default_network_name
  deletion_protection = false

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_firewall" "rdp" {
  provider = google
  name    = var.default_allow_rdp_firewall_rule_name
  project = var.project_id
  network = var.default_network_name

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  direction     = "INGRESS"
  disabled      = false
  log_config {
    metadata = "DISABLE"
  }
  priority = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags = []
}

resource "google_compute_firewall" "ssh" {
  provider = google
  name    = var.default_allow_ssh_firewall_rule_name
  project = var.project_id
  network = var.default_network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction     = "INGRESS"
  disabled      = false
  log_config {
    metadata = "DISABLE"
  }
  priority = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags = []
}

resource "google_project_metadata" "project_metadata" {
  provider = google
  project = var.project_id

  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_network" "default_network_dns_logging" {
  provider = google
  name                    = var.default_network_name
  project                 = var.project_id
  delete_default_routes_on_destroy = false
  auto_create_subnetworks = true
  mtu                     = 1500

  routing_mode = "GLOBAL"
  dns_config {
    enable_logging = true
  }
}

resource "google_compute_subnetwork" "default_subnet_flow_logs" {
  provider = google
  for_each = toset(var.regions)
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = var.default_network_name
  project                  = var.project_id
  region                   = each.key
  private_ip_google_access = false
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_storage_bucket" "buckets" {
  provider = google
  name          = "${var.project_id}.appspot.com"
  project       = var.project_id
  location      = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "buckets2" {
  provider = google
  name          = "${var.project_id}_bucket"
  project       = var.project_id
  location      = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "buckets3" {
  provider = google
  name          = "staging.${var.project_id}.appspot.com"
  project       = var.project_id
  location      = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}

resource "google_logging_project_sink" "default" {
  provider = google
  name        = "all-logs"
  project     = var.project_id
  destination = "storage.googleapis.com/${var.project_id}-all-logs"
  filter      = "NOT logName: projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity"
}
