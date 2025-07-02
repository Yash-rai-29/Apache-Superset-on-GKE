resource "google_compute_network" "default" {
  name                    = "default"
  project                 = var.project_id
  auto_create_subnetworks = false
  delete_default_routes   = true
}

resource "google_compute_firewall" "rdp" {
  name    = "default-allow-rdp"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = var.allowed_rdp_ssh_cidr_blocks
}

resource "google_compute_firewall" "ssh" {
  name    = "default-allow-ssh"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowed_rdp_ssh_cidr_blocks
}

resource "google_compute_network_dns_policy" "dns_logging" {
  name      = "default"
  network   = "default"
  project = var.project_id
  enable_logging = true

  depends_on = [google_compute_network.default]
}

resource "google_compute_project_metadata" "oslogin" {
  project = var.project_id
  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_subnetwork" "subnetworks" {
  for_each = toset(var.regions)
  name                     = "default"
  ip_cidr_range            = "10.10.10.0/24"
  network                  = "default"
  region                   = each.value
  project = var.project_id
  log_config {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  private_ip_google_access = true

  depends_on = [google_compute_network_dns_policy.dns_logging]
}
