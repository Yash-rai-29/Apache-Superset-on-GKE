resource "google_project_iam_member" "project" {
  project = var.project_id
  role    = "roles/owner"
  member  = "user:example@example.com"
}

resource "google_project_service_identity" "artifactregistry" {
  provider = google
  project  = var.project_id
  service  = "artifactregistry.googleapis.com"
}

resource "google_project_service_identity" "containeranalysis" {
  provider = google
  project  = var.project_id
  service  = "containeranalysis.googleapis.com"
}

resource "google_project_service_identity" "cloudasset" {
  provider = google
  project  = var.project_id
  service  = "cloudasset.googleapis.com"
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
}

resource "google_project_service" "cloudasset" {
  provider = google
  project  = var.project_id
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "apikeys" {
  provider = google
  project  = var.project_id
  service            = "apikeys.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_network" "default" {
  name                    = "default"
  project                 = var.project_id
  auto_create_subnetworks = false
  delete_default_routes   = true
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

resource "google_compute_subnet" "subnet" {
  name                     = "default"
  ip_cidr_range            = "10.10.10.0/24"
  network                  = "default"
  private_ip_google_access = true
  project                  = var.project_id
  region                   = var.region
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork_iam_member" "private_service_access" {
  project        = var.project_id
  region         = var.region
  role           = "roles/compute.networkUser"
  subnetwork     = "default"
  member         = "serviceAccount:service-${data.google_project.project.number}@service-networking.iam.gserviceaccount.com"
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_organization_policy" "oslogin" {
  project = var.project_id
  constraint = "compute.requireOsLogin"
  policy_type = "list"
  list_policy {
    allowed_values = ["TRUE"]
  }
}

resource "google_cloudfunctions_function_iam_binding" "cloud_asset_inventory_reader" {
  project = var.project_id
  location = var.region
  cloud_function = "cloud-asset-inventory-reader"
  role = "roles/cloudasset.viewer"
  members = [
    "allUsers",
  ]
}

resource "google_logging_project_sink" "default_sink" {
  name        = "all-logs"
  project     = var.project_id
  destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/logging_dataset"
  filter      = "NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Fdata_access"
}
