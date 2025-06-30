resource "google_compute_network" "default" {
  name                    = "default"
  project                 = var.project_id
  auto_create_subnetworks = false

  lifecycle {
    prevent_destroy = true
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

  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

resource "google_compute_firewall" "ssh" {
  name    = "default-allow-ssh"
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

resource "google_compute_network" "vpc_network" {
  name                    = "custom-vpc"
  auto_create_subnetworks = true
  project                 = var.project_id
}

resource "google_compute_subnetwork" "default_subnetworks" {
  for_each    = toset([
    "africa-south1",
    "southamerica-west1",
    "us-west4",
    "me-central2",
    "asia-east2",
    "asia-northeast1",
    "asia-south2",
    "asia-northeast3",
    "us-south1",
    "australia-southeast1",
    "us-east4",
    "us-west3",
    "asia-southeast1",
    "europe-southwest1",
    "asia-east1",
    "europe-north2",
    "australia-southeast2",
    "northamerica-northeast2",
    "asia-southeast2",
    "northamerica-northeast1",
    "asia-south1",
    "europe-west6",
    "europe-west1",
    "southamerica-east1",
    "asia-northeast2",
    "europe-north1",
    "us-east5",
    "us-west2",
    "us-west1",
    "europe-west10",
    "us-central1",
    "northamerica-south1",
    "europe-west4",
    "europe-west9",
    "europe-west2",
    "europe-west12",
    "europe-west8",
    "me-central1",
    "europe-west3",
    "us-east1",
    "europe-central2",
    "me-west1"
  ])
  name          = each.key
  ip_cidr_range = "10.10.0.0/20"
  network       = google_compute_network.vpc_network.id
  region        = each.key
  project       = var.project_id
  flow_logs     = true
}

resource "google_compute_global_network" "default_network" {
    name                    = "default"
    project                 = var.project_id
    lifecycle {
        prevent_destroy = true
    }
}
