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
  region  = var.location
}

resource "google_project_service" "artifactregistry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "containeranalysis" {
  project = var.project_id
  service = "containeranalysis.googleapis.com"

  depends_on = [google_project_service.artifactregistry]
  disable_on_destroy = false
}

resource "google_project_service" "cloudasset" {
  project = var.project_id
  service = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_network" "default" {
  name                    = "default"
  project                 = var.project_id
  delete_default_routes = true
}

resource "google_compute_network" "create_network" {
  name                    = "vpc-network"
  project                 = var.project_id
  auto_create_subnetworks = false
}

resource "google_compute_firewall" "delete_rdp" {
  name    = "default-allow-rdp"
  project = var.project_id
  network = "default"

  action  = "DENY"
  direction = "INGRESS"

  deny {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "delete_ssh" {
  name    = "default-allow-ssh"
  project = var.project_id
  network = "default"

  action  = "DENY"
  direction = "INGRESS"

  deny {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_network" "default_network" {
  name                    = "default"
  project                 = var.project_id
  delete_default_routes = true
}

resource "google_compute_network" "enable_dns_logging" {
  name                    = "default"
  project                 = var.project_id
  delete_default_routes = true

  enable_logging = true
}

resource "google_project_metadata" "oslogin" {
  project = var.project_id

  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_subnet" "subnet" {
  for_each = toset(var.regions)

  name          = "default"
  ip_cidr_range = "10.10.0.0/20"
  region        = each.value
  network       = "default"
  project       = var.project_id
  enable_flow_logs = true
}

resource "google_storage_bucket" "default_bucket" {
  for_each = toset(var.bucket_names)

  name          = each.value
  project       = var.project_id
  location      = var.location
  uniform_bucket_level_access = true
}
