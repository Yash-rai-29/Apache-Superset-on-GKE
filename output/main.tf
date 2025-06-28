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

resource "google_project_service_identity" "artifactregistry" {
  provider = google
  project  = var.project_id
  service  = "artifactregistry.googleapis.com"
}

resource "google_artifact_registry_repository" "default" {
  provider = google
  project  = var.project_id
  location = "us-central1"
  repository_id = "my-repo"
  format = "DOCKER"
}


resource "google_project_service" "artifactregistry" {
  provider = google
  project = var.project_id
  service = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_container_analysis_occurrence" "default" {
  provider = google
  project = var.project_id
  note_name = "providers/goog-analysis/notes/Vulnerability"
  resource_uri = google_artifact_registry_repository.default.id
  vulnerability = {
    severity = "HIGH"
  }
  depends_on = [google_project_service.artifactregistry]
}

resource "google_container_analysis_note" "default" {
  provider = google
  project  = var.project_id
  name     = "test-occurrence-note"
  attestation_authority = {
    hint = {
      human_readable_name = "Example attestation authority"
    }
  }
}

resource "google_project_service" "container_analysis" {
  provider = google
  project = var.project_id
  service = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudasset" {
  provider = google
  project = var.project_id
  service = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "apikeys" {
  provider = google
  project = var.project_id
  service = "apikeys.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_project_metadata" "oslogin" {
  provider = google
  project = var.project_id
  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_network" "default" {
  provider = google
  name                    = "default"
  project                 = var.project_id
  auto_create_subnetworks = false
  delete_default_routes = true
}

resource "google_logging_project_sink" "default_sink" {
  provider = google
  name        = "all-logs"
  project     = var.project_id
  description = "Sinking all logs to a Google Cloud Storage bucket"
  destination = "storage.googleapis.com/${var.project_id}-logs"
  filter      = "NOT logName:compute.googleapis.com/serialConsoleOutput"
}

resource "google_storage_bucket" "log_bucket" {
  provider = google
  name                        = "${var.project_id}-logs"
  project                     = var.project_id
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_compute_subnetwork" "default" {
  for_each = toset(var.regions)
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.10.10.0/24"
  network                  = "default"
  region                   = each.value
  project                  = var.project_id
  private_ip_google_access = true
  flow_logs                = true
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

  source_ranges = ["10.0.0.0/8", "192.168.0.0/16"]
  target_tags   = ["rdp"]
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

  source_ranges = ["10.0.0.0/8", "192.168.0.0/16"]
  target_tags   = ["ssh"]
}

resource "google_compute_network_dns_policy" "default" {
  provider = google
  project = var.project_id
  network = "default"
  name = "dns-logging-policy"
}
