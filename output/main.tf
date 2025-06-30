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
  role   = "roles/owner"
  member = "user:example@example.com"
}

resource "google_compute_network" "default" {
  name                    = "default"
  project                 = var.project_id
  auto_create_subnetworks = false

  lifecycle {
    prevent_destroy = false
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

  source_ranges = ["10.0.0.0/8"]
  target_tags   = ["rdp"]
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
  target_tags   = ["ssh"]
}

resource "google_project_service" "artifactregistry" {
  service            = "artifactregistry.googleapis.com"
  project            = var.project_id
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "my_repo" {
  provider      = google
  location      = var.region
  repository_id = "container-repo"
  project = var.project_id
  format        = "DOCKER"
}

resource "google_project_service" "containeranalysis" {
  service            = "containeranalysis.googleapis.com"
  project            = var.project_id
  disable_on_destroy = false
  depends_on = [google_project_service.artifactregistry]
}

resource "google_storage_bucket" "buckets" {
  for_each = toset(var.bucket_names)

  name          = each.value
  project       = var.project_id
  location      = "US"
  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_compute_subnetwork" "default_subnets" {
  for_each = toset(var.default_subnets)

  name                     = "default-${each.value}"
  ip_cidr_range            = "10.10.10.0/24"
  network                  = "default"
  project                  = var.project_id
  region                   = each.value
  private_ip_google_access = true
  flow_logs = true

}

resource "google_project_service_identity" "cloudasset" {
  provider = google
  project = var.project_id
  service = "cloudasset.googleapis.com"
}

resource "google_project_service" "cloudasset_api" {
  service            = "cloudasset.googleapis.com"
  project            = var.project_id
  disable_on_destroy = false
}

resource "google_organization_policy" "no_service_account_project_level_access" {
  project  = var.project_id
  constraint = "iam.disableServiceAccountUsage"

  policy_type = "list"
  list_policy {
    deny {
      all = true
    }
  }
}

resource "google_project_service" "oslogin" {
  project = var.project_id
  service = "oslogin.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_project_metadata" "oslogin_enable" {
  project = var.project_id
  metadata = {
    enable-oslogin = "TRUE"
  }
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

resource "google_logging_project_sink" "default" {
  name = "default-sink"
  project = var.project_id
  description = "This sink exports logs to a Cloud Storage bucket."
  destination = "storage.googleapis.com/${var.project_id}-bucket-logs"
  filter = "resource.type=gce_instance AND severity>=INFO"

  unique_writer_identity = true
}

resource "google_project_service" "cloud_dns" {
  service = "dns.googleapis.com"
  project = var.project_id
  disable_on_destroy = false
}

resource "google_compute_network" "dns_logging" {
  name                    = "default"
  project                 = var.project_id
  auto_create_subnetworks = true
  delete_default_routes_on_destroy = false
  enable_dns_logging = true
}
