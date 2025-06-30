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
  region  = var.location
}

resource "google_project_service" "artifactregistry" {
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "containeranalysis" {
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
  depends_on = [google_project_service.artifactregistry]
}

resource "google_compute_project_metadata" "project_metadata" {
  project = var.project_id

  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_network" "default" {
  name                    = "default"
  project                 = var.project_id
  delete_default_routes_on_destroy = true
}

resource "google_compute_network" "default_delete" {
  name                    = "default"
  project                 = var.project_id
  delete_default_routes_on_destroy = true
  depends_on=[google_compute_network.default]
}

resource "google_compute_network" "default_dns" {
  name                    = "default"
  project                 = var.project_id
  delete_default_routes_on_destroy = true
  enable_dns_logging = true
  depends_on=[google_compute_network.default_delete]
}

resource "google_compute_firewall" "delete_rdp" {
  name    = "default-allow-rdp"
  project = var.project_id
  network = "default"

  lifecycle {
    ignore_changes = [
      source_ranges
    ]
  }
  action = "DENY"
  direction = "INGRESS"
  dynamic "allow" {
    for_each = []
    content {
      ports    = ["3389"]
      protocol = "tcp"
    }
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = []

  depends_on = [google_compute_network.default_dns]
}

resource "google_compute_firewall" "delete_ssh" {
  name    = "default-allow-ssh"
  project = var.project_id
  network = "default"
   lifecycle {
    ignore_changes = [
      source_ranges
    ]
  }
    action = "DENY"
  direction = "INGRESS"

  dynamic "allow" {
    for_each = []
    content {
      ports    = ["22"]
      protocol = "tcp"
    }
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = []

   depends_on = [google_compute_firewall.delete_rdp]
}


resource "google_storage_bucket" "default" {
  for_each = toset(var.bucket_names)
  name          = each.value
  project       = var.project_id
  location      = var.location
  uniform_bucket_level_access = true
}

resource "google_compute_subnetwork" "default_flow_logs" {
  for_each = toset(var.regions)
  name                     = "default"
  ip_cidr_range          = "10.128.0.0/20"
  network                  = "default"
  project                  = var.project_id
  region                   = each.value
  private_ip_google_access = true
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [google_compute_firewall.delete_ssh]
}

resource "google_project_service" "cloudasset" {
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
  project = var.project_id
}
