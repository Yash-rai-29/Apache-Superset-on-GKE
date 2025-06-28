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

resource "google_project_service_identity" "artifactregistry" {
  provider = google
  project  = var.project_id
  service  = "artifactregistry.googleapis.com"
}

resource "google_artifact_registry_repository" "default" {
  provider = google
  project      = var.project_id
  location     = var.region
  repository_id = "default-repository"
  format       = "DOCKER"
}

resource "google_project_iam_binding" "artifactregistry" {
  provider = google
  project = var.project_id
  role    = "roles/artifactregistry.reader"

  members = [
    "serviceAccount:${google_project_service_identity.artifactregistry.email}",
  ]
  depends_on = [google_project_service_identity.artifactregistry, google_artifact_registry_repository.default]
}


resource "google_container_analysis_occurrence" "default" {
  provider = google
  project = var.project_id
  note                 = "projects/goog-analysis/notes/PACKAGE_VULNERABILITY"
  resource_uri         = "https://gcr.io/google-containers/node-hello@sha256:a19856d9e4de32a1d139f835ebc0a9f1245c7e541b4f46c92d59697129b88db9"
}


resource "google_project_service" "artifactregistry" {
  provider = google
  project  = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "containeranalysis" {
  provider = google
  project  = var.project_id
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
  depends_on = [google_project_service.artifactregistry]
}

resource "google_project_service" "cloudasset" {
  provider = google
  project  = var.project_id
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
}


resource "google_project_iam_member" "cloudasset" {
  provider = google
  project = var.project_id
  role   = "roles/cloudasset.viewer"
  member = "allUsers"

  depends_on = [google_project_service.cloudasset]
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
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["rdp"]
}

resource "google_compute_firewall" "ssh" {
  provider = google
  name    = "default-allow-ssh"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["ssh"]
}

resource "google_project_default_network_tier" "default" {
  provider = google
  project = var.project_id
  network_tier = "PREMIUM"
}

resource "google_compute_network" "vpc_network" {
  provider = google
  name                    = "vpc-network"
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "default" {
  provider = google
  for_each     = toset(var.default_subnets)
  name         = each.key
  ip_cidr_range = "10.10.10.0/24"
  network      = google_compute_network.vpc_network.id
  region       = each.key
  project      = var.project_id

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_project_default_service_accounts" "default_accounts" {
  provider = google
  project     = var.project_id

  action = "DISABLE"
}

resource "google_project_metadata" "metadata" {
  provider = google
  project = var.project_id

  metadata = {
    enable-oslogin = "true"
  }
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  provider = google
  project = var.project_id
  cloud_function = "function"
  region = "us-central1"
  role = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "google_logging_project_sink" "default" {
  provider = google
  name = "default-sink"
  project = var.project_id
  description = "Exports all logs to a Cloud Storage bucket"
  destination = "storage.googleapis.com/${var.project_id}-logs"
  filter = "NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity"

  unique_writer_identity = true
}

resource "google_storage_bucket" "bucket" {
  provider = google
  name          = "${var.project_id}-logs"
  project     = var.project_id
  location      = "US"
  uniform_bucket_level_access = true
}

resource "google_project_iam_binding" "bucket_access" {
  provider = google
  project = var.project_id
  role   = "roles/storage.objectCreator"
  members = [
    "serviceAccount:${google_logging_project_sink.default.writer_identity}",
  ]
}
