terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_metadata" "project_metadata" {
  project = var.project_id

  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_network" "default" {
  name                    = "default"
  project                 = var.project_id
  delete_default_routes = true
}

resource "google_compute_subnetwork" "default_vpc_subnets" {
  for_each = toset(var.default_vpc_regions)

  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  project                  = var.project_id
  region                   = each.key
  private_ip_google_access = true
  flow_logs = true
}

resource "google_artifact_registry_repository" "container_analysis" {
  project = var.project_id
  repository_id = "container-analysis"
  location      = var.region
  format        = "DOCKER"
}

resource "google_project_service_identity" "gcp_sa" {
  provider = google
  project  = var.project_id
  service  = "containeranalysis.googleapis.com"
}

resource "google_project_iam_member" "artifact_registry_sa" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_project_service_identity.gcp_sa.email}"
}

resource "google_project_service" "container_analysis" {
  project = var.project_id
  service = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_storage_bucket" "buckets" {
  for_each = toset(var.bucket_names)
  name          = each.key
  project       = var.project_id
  location      = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}

resource "google_iam_service_account" "remove_admin" {
    account_id   = "twitch-login"
    disabled     = false
    display_name = "twitch-login"
    project      = var.project_id
}

resource "google_project_iam_binding" "remove_iam_bindings1" {
  project = var.project_id
  role    = "roles/firebase.sdkAdminServiceAgent"

  members = [
    "serviceAccount:${google_iam_service_account.remove_admin.email}",
  ]
}

resource "google_project_iam_binding" "remove_iam_bindings2" {
  project = var.project_id
  role    = "roles/editor"

  members = [
    "serviceAccount:${var.project_id}@appspot.gserviceaccount.com",
    "serviceAccount:30647320905-compute@developer.gserviceaccount.com"
  ]
}

resource "google_project_iam_binding" "remove_iam_bindings3" {
  project = var.project_id
  role    = "roles/storage.admin"

  members = [
    "serviceAccount:firebase-adminsdk-d21rv@${var.project_id}.iam.gserviceaccount.com"
  ]
}

resource "google_logging_project_sink" "log_sink" {
  name = "all-logs-sink"
  project = var.project_id
  destination = "storage.googleapis.com/${var.project_id}-logs"
  filter = "NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Fdata_access"
}

resource "google_storage_bucket" "logging_bucket" {
  name          = "${var.project_id}-logs"
  project       = var.project_id
  location      = "US"
  force_destroy = true
  uniform_bucket_level_access = true
}
