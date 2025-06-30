resource "google_compute_subnetwork" "default" {
  for_each = toset(var.default_regions)

  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = each.value
  project       = var.project_id

  log_config {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_project_metadata" "project_metadata" {
  project = var.project_id

  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_artifact_registry_vpcsc_config" "default" {
  project = var.project_id
  location = "global"
  vpc_service_control_enabled = true
}

resource "google_project_service" "containeranalysis" {
  project = var.project_id
  service = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_cloudiot_registry" "default" {
  name      = "my-registry"
  region = "us-central1"
  project = var.project_id
}

resource "google_storage_bucket" "default" {
  for_each = toset(var.bucket_names)

  name                        = each.value
  project                     = var.project_id
  location                    = var.location
  uniform_bucket_level_access = true
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "default-allow-ssh"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.authorized_networks
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

  source_ranges = var.authorized_networks
  target_tags   = ["rdp"]
}

resource "google_compute_network" "custom_network" {
  name                    = "custom-network"
  auto_create_subnetworks = false
  project = var.project_id
}

resource "google_compute_global_address" "google_managed_services_range" {
    name          = "google-managed-services-${var.project_id}"
    purpose       = "VPC_PEERING"
    address_type  = "INTERNAL"
    prefix_length = 16
    project       = var.project_id
}

resource "google_service_networking_connection" "private_service_access" {
    network                 = google_compute_network.custom_network.self_link
    reserved_peering_ranges = [google_compute_global_address.google_managed_services_range.name]
    service                 = "servicenetworking.googleapis.com"
}

resource "google_dns_managed_zone" "default" {
  name        = "private-zone"
  dns_name    = "example.com."
  description = "Private DNS zone for VPC network"
  project = var.project_id
  visibility  = "private"
  private_visibility_config {
    networks {
      network_url = google_compute_network.custom_network.self_link
    }
  }

  opts = {
    depends_on = [google_service_networking_connection.private_service_access]
  }
}

resource "google_project_service" "cloudasset" {
  project = var.project_id
  service = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_logging_project_sink" "sink" {
  name        = "all-logs-to-bucket"
  destination = "storage.googleapis.com/${google_storage_bucket.default["aviato-game-fight-rvxirf.appspot.com"].name}"
  filter      = "NOT logName:\"projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Fdata_access\""
  project = var.project_id
}
