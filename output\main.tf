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

resource "google_artifact_registry_repository" "default" {
  provider = google
  location             = var.region
  repository_id        = "default-repository"
  description          = "Terraform-managed repository"
  format               = "DOCKER"
  project = var.project_id
}

resource "google_project_iam_member" "artifactregistry_pull" {
  provider = google
  project = var.project_id
  role = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_project_service_identity.artifactregistry.email}"
}

resource "google_project_iam_member" "gcr_scanner" {
  provider = google
  project = var.project_id
  role = "roles/containeranalysis.occurrences.viewer"
  member = "serviceAccount:gcp-sa-gcrscanner@gcp-sa-gcr.iam.gserviceaccount.com"
}

resource "google_container_analysis_occurrence" "note_iam_binding" {
  project = var.project_id
  note_name = "providers/goog-imagetest/notes/vulnscan-note"
  kind      = "VULNERABILITY"
  resource_uri = "goog-imagetest/test-image"
}


resource "google_project_service" "containeranalysis" {
  provider = google
  project = var.project_id
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudasset" {
  provider = google
  project = var.project_id
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_network" "default" {
  project                 = var.project_id
  name                    = "default"
  delete_default_routes = true
}

resource "google_compute_firewall" "disable_rdp" {
  project = var.project_id
  name    = "disable-default-allow-rdp"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
  action        = "DENY"
}

resource "google_compute_firewall" "disable_ssh" {
  project = var.project_id
  name    = "disable-default-allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
  action        = "DENY"
}

resource "google_project_default_service_accounts" "default_accounts" {
  project_id = var.project_id
  action = "DISABLE"
}

resource "google_project_organization_policy" "constraints/compute.disableGuestAttributesAccess" {
  project = var.project_id
  constraint = "constraints/compute.disableGuestAttributesAccess"
  policy_type = "boolean"

  boolean_policy {
    enforced = true
  }
}

resource "google_compute_project_metadata" "metadata" {
  project = var.project_id

  metadata = {
    enable-oslogin = "true"
  }
}

resource "google_compute_subnetwork" "default_subnetworks" {
  for_each = toset(var.default_subnets)
  name                     = each.value
  project                  = var.project_id
  ip_cidr_range            = "10.0.0.0/20"
  region                   = each.value
  network                  = "default"
  private_ip_google_access = true
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_storage_bucket" "buckets" {
  for_each = toset(var.bucket_names)
  name                        = each.value
  project                     = var.project_id
  location                    = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}

resource "google_logging_project_sink" "log_sink" {
  provider = google
  name = "all-logs"
  project = var.project_id
  description = "Sink for all logs"
  destination = "storage.googleapis.com/${var.project_id}-logs"
  filter = "NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity"
}
