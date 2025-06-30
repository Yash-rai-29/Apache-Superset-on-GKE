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
  region  = var.region
}

resource "google_project_service" "containeranalysis" {
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
  project = var.project_id
}

resource "google_project_service" "cloudasset" {
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
    project = var.project_id
}

resource "google_compute_project_metadata" "oslogin" {
  metadata = {
    enable-oslogin = "TRUE"
  }
  project = var.project_id
}

resource "google_storage_bucket" "default_uniform_bucket_level_access" {
  for_each = toset(var.bucket_names)

  name          = each.value
  location      = "US"
  force_destroy = true
}

resource "google_storage_bucket_iam_binding" "default_uniform_bucket_level_access" {
  for_each = toset(var.bucket_names)
  bucket = each.value
  role = "roles/storage.objectViewer"
  members = [
    "allUsers",
  ]
}

resource "google_storage_bucket_iam_binding" "allUsers-buckets" {
  for_each = toset(var.bucket_names)
  bucket = each.value
  role = "roles/storage.objectViewer"
  members = [
    "allUsers",
  ]
}


resource "google_storage_bucket_iam_binding" "allAuthenticatedUsers-buckets" {
  for_each = toset(var.bucket_names)
  bucket = each.value
  role = "roles/storage.objectViewer"
  members = [
    "allAuthenticatedUsers",
  ]
}

resource "google_storage_bucket_access_control" "acl" {
  for_each = toset(var.bucket_names)
  bucket = each.value
  entity = "allUsers"
  role = "READER"
}


resource "google_storage_bucket_iam_configuration" "uniform_bucket_level_access" {
  for_each = toset(var.bucket_names)
  bucket = each.value
  uniform_bucket_level_access {
    enabled         = true
    lock_time = "P7D"
  }
}


resource "google_compute_firewall" "default_allow_ssh" {
  name    = "default-allow-ssh"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.default_ssh_source_ranges
}

resource "google_compute_firewall" "default_allow_rdp" {
  name    = "default-allow-rdp"
  network = "default"
    project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = var.default_rdp_source_ranges
}

resource "google_compute_network" "default" {
  name                    = "default"
  delete_default_routes = true
}

resource "google_compute_network" "default_dns_logging" {
  name                    = "default"
  project = var.project_id
  enable_logging = true
}

resource "google_compute_subnetwork" "default_subnet_flow_logs" {
  for_each = toset(var.default_subnet_regions)

  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = each.value
  project = var.project_id
  flow_logs {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_iam_service_account" "service_account_twitch" {
  account_id   = "twitch-login"
  display_name = "Service account for twitch login"
  project      = var.project_id
}

resource "google_iam_service_account" "default_compute_sa" {
  account_id   = "default-compute"
  display_name = "Default Compute Service Account"
  project      = var.project_id
}

resource "google_project_iam_member" "compute_service_account_no_admin" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:${google_iam_service_account.default_compute_sa.email}"
}

resource "google_project_iam_member" "service_account_twitch_no_admin" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:${google_iam_service_account.service_account_twitch.email}"
}


resource "google_project_iam_member" "service_account_admin_firebase_appspot" {
  project = var.project_id
  role = "roles/viewer"
  member = "serviceAccount:aviato-game-fight-rvxirf@appspot.gserviceaccount.com"
}

resource "google_project_iam_member" "service_account_firebase" {
  project = var.project_id
  role    = "roles/viewer"
  member = "serviceAccount:firebase-adminsdk-d21rv@aviato-game-fight-rvxirf.iam.gserviceaccount.com"
}
