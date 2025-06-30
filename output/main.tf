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

resource "google_project_service" "container_analysis" {
  project = var.project_id
  service = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_storage_bucket" "default" {
  for_each = toset(var.bucket_names)
  name          = each.value
  location      = "US" 
  force_destroy = false
}

resource "google_storage_bucket_iam_binding" "default" {
  for_each = toset(var.bucket_names)
  bucket = each.value
  role = "roles/storage.objectViewer"
  members = [
    "allUsers",
  ]
}

resource "google_storage_bucket_iam_binding" "ubla" {
  for_each = toset(var.bucket_names)
  bucket = each.value
  role = "roles/storage.admin"
  members = [
    "serviceAccount:aviato-game-fight-rvxirf@appspot.gserviceaccount.com",
    "serviceAccount:firebase-adminsdk-d21rv@aviato-game-fight-rvxirf.iam.gserviceaccount.com"
  ]
}

resource "google_storage_bucket_iam_member" "ubla_member" {
  for_each = toset(var.bucket_names)
  bucket = each.value
  role = "roles/storage.objectViewer"
  member = "user:manan@aviato.consulting"
}

resource "google_storage_bucket_iam_member" "ubla_member_2" {
  for_each = toset(var.bucket_names)
  bucket = each.value
  role = "roles/storage.legacyBucketReader"
  member = "user:manan@aviato.consulting"
}

resource "google_project_iam_member" "project_iam_member" {
  project = var.project_id
  role = "roles/viewer"
  member = "user:manan@aviato.consulting"
}

resource "google_storage_bucket_iam_binding" "project_owner" {
  for_each = toset(var.bucket_names)
  bucket = each.value
  role = "roles/storage.objectViewer"
  members = [
    "group:test@example.com",
    "domain:google.com",
  ]
}

resource "google_storage_bucket_iam_binding" "project_owner_2" {
  for_each = toset(var.bucket_names)
  bucket = each.value
  role = "roles/storage.legacyBucketWriter"
  members = [
    "serviceAccount:project-service-account@test.google.com.iam.gserviceaccount.com",
  ]
}

resource "google_storage_bucket_iam_binding" "project_owner_3" {
  for_each = toset(var.bucket_names)
  bucket = each.value
  role = "roles/storage.legacyBucketReader"
  members = [
    "serviceAccount:project-service-account@test.google.com.iam.gserviceaccount.com",
  ]
}

resource "google_storage_bucket_iam_binding" "project_owner_4" {
  for_each = toset(var.bucket_names)
  bucket = each.value
  role = "roles/viewer"
  members = [
    "serviceAccount:project-service-account@test.google.com.iam.gserviceaccount.com",
  ]
}

resource "google_project_metadata" "oslogin" {
  project = var.project_id

  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_network_dns_logging_policy" "default" {
  name    = "default"
  network = "default"
  project = var.project_id
}

resource "google_compute_subnetwork" "default" {
  for_each = toset(var.default_regions)
  name                     = "default"
  ip_cidr_range          = "10.128.0.0/20"
  region                   = each.value
  network                  = "default"
  private_ip_google_access = true
  enable_flow_logs         = true
  project = var.project_id
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "default-allow-ssh"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.rdp_ssh_allowed_networks
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "allow_rdp" {
  name    = "default-allow-rdp"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = var.rdp_ssh_allowed_networks
  target_tags   = ["rdp"]
}

resource "google_project_service" "cloudasset" {
  project = var.project_id
  service = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_iam_binding" "twitch_login" {
  project = var.project_id
  role    = "roles/viewer"

  members = [
    "serviceAccount:twitch-login@aviato-game-fight-rvxirf.iam.gserviceaccount.com",
  ]
}

resource "google_project_iam_binding" "appspot" {
  project = var.project_id
  role    = "roles/viewer"

  members = [
    "serviceAccount:aviato-game-fight-rvxirf@appspot.gserviceaccount.com",
  ]
}

resource "google_project_iam_binding" "firebase_adminsdk" {
  project = var.project_id
  role    = "roles/viewer"

  members = [
    "serviceAccount:firebase-adminsdk-d21rv@aviato-game-fight-rvxirf.iam.gserviceaccount.com",
  ]
}

resource "google_logging_project_sink" "sink" {
  name   = "all-logs-sink"
  project = var.project_id
  destination = "storage.googleapis.com/${var.project_id}-all-logs"
  filter   = "NOT logName:(\"projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Fdata_access\")"
  unique_writer_identity = true
}

resource "google_project_iam_binding" "logging_sink_binding" {
  project = var.project_id
  role    = "roles/storage.objectCreator"
  members = ["serviceAccount:${google_logging_project_sink.sink.writer_identity}"]
}
