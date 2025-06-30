terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.68.0"
    }
  }
}

provider "google" {
  project = "aviato-game-fight-rvxirf"
}

resource "google_project_service_identity" "container_analysis" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  service = "containeranalysis.googleapis.com"
}

resource "google_project_iam_member" "container_analysis_artifact_registry" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  role = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_project_service_identity.container_analysis.email}"
  depends_on = [google_project_service_identity.container_analysis]
}

resource "google_project_iam_member" "container_analysis_viewer" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  role = "roles/viewer"
  member = "serviceAccount:${google_project_service_identity.container_analysis.email}"
  depends_on = [google_project_service_identity.container_analysis]
}

resource "google_project_service" "containeranalysis" {
  provider = google
  project            = "aviato-game-fight-rvxirf"
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_storage_bucket" "default" {
  name                        = "aviato-game-fight-rvxirf.appspot.com"
  location                    = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "default_bucket" {
  name                        = "aviato-game-fight-rvxirf_bucket"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "staging" {
  name                        = "staging.aviato-game-fight-rvxirf.appspot.com"
  location                    = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}

resource "google_compute_firewall" "default_allow_ssh" {
  name    = "default-allow-ssh"
  project = "aviato-game-fight-rvxirf"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["130.211.0.0/22", "35.235.0.0/24"]
}

resource "google_compute_firewall" "default_allow_rdp" {
  name    = "default-allow-rdp"
  project = "aviato-game-fight-rvxirf"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
    source_ranges = ["130.211.0.0/22", "35.235.0.0/24"]
}

resource "google_compute_network" "default" {
  name                    = "default"
  project                 = "aviato-game-fight-rvxirf"
  delete_default_routes = true
  routing_mode = "GLOBAL"
  auto_create_subnetworks = false
  depends_on = [
    google_compute_firewall.default_allow_ssh,
    google_compute_firewall.default_allow_rdp
  ]
}

resource "google_compute_network_dns_policy" "default_dns_logging" {
  network = "default"
  project = "aviato-game-fight-rvxirf"
  enable_logging = true
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_project_metadata" "project_metadata" {
  project = "aviato-game-fight-rvxirf"

  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_subnetwork" "default_asia_east2" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "asia-east2"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_asia_southeast2" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "asia-southeast2"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_us_east5" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "us-east5"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_europe_west8" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "europe-west8"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_europe_west3" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "europe-west3"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
    depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_europe_west9" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "europe-west9"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
    depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_me_central1" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "me-central1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_asia_south2" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "asia-south2"
  project = "aviato-game-fight-rvxirf"
    log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_asia_northeast3" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "asia-northeast3"
  project = "aviato-game-fight-rvxirf"
    log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_australia_southeast1" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "australia-southeast1"
  project = "aviato-game-fight-rvxirf"
    log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_asia_south1" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "asia-south1"
  project = "aviato-game-fight-rvxirf"
    log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_northamerica_south1" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "northamerica-south1"
  project = "aviato-game-fight-rvxirf"
    log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_me_west1" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "me-west1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_asia_northeast2" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "asia-northeast2"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_europe_west2" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "europe-west2"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_asia_northeast1" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "asia-northeast1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_me_central2" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "me-central2"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_northamerica_northeast2" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "northamerica-northeast2"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_southamerica_west1" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "southamerica-west1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_europe_west6" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "europe-west6"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_australia_southeast2" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "australia-southeast2"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_europe_west12" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "europe-west12"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_us_south1" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "us-south1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_europe_central2" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "europe-central2"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_europe_west4" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "europe-west4"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_europe_west10" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "europe-west10"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_asia_southeast1" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "asia-southeast1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_asia_east1" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "asia-east1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_us_west1" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "us-west1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_europe_west1" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "europe-west1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_northamerica_northeast1" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "northamerica-northeast1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_europe_north1" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "europe-north1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_africa_south1" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "africa-south1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_southamerica_east1" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "southamerica-east1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_us_west4" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "us-west4"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_us_west3" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "us-west3"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_us_east4" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "us-east4"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_us_central1" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "us-central1"
  project = "aviato-game-fight-rvxirf"
    log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_us_west2" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "us-west2"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_europe_southwest1" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "europe-southwest1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_us_east1" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "us-east1"
  project = "aviato-game-fight-rvxirf"
    log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  depends_on = [
    google_compute_network.default
  ]
}

resource "google_project_service" "cloudasset" {
  provider = google
  project            = "aviato-game-fight-rvxirf"
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_logging_project_sink" "log_sink" {
  name        = "aviato-game-fight-rvxirf-sink"
  project     = "aviato-game-fight-rvxirf"
  destination = "storage.googleapis.com/${google_storage_bucket.default_bucket.name}"
  filter      = "TRUE" # Consider adjusting the filter to capture specific log entries
  depends_on = [google_storage_bucket.default_bucket]
}

resource "google_logging_metric" "audit_config_changes" {
  name        = "audit-config-changes"
  project     = "aviato-game-fight-rvxirf"
  description = "Metric for audit configuration changes"
  filter      = "protoPayload.methodName=\"SetIamPolicy\" OR protoPayload.methodName=\"UpdatePolicy\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "audit_config_changes_alert" {
  display_name = "Audit Configuration Changes Alert"
  project     = "aviato-game-fight-rvxirf"
  combiner    = "OR"
  conditions {
    display_name = "Audit Configuration Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/audit-config-changes\" AND resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
      trigger {
        count = 1
      }
    }
  }
}

resource "google_logging_metric" "bucket_permission_changes" {
  name        = "bucket-permission-changes"
  project     = "aviato-game-fight-rvxirf"
  description = "Metric for Cloud Storage IAM permission changes"
  filter      = "resource.type=gcs_bucket AND protoPayload.methodName=storage.setIamPermissions"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes_alert" {
  display_name = "Cloud Storage IAM Permission Changes Alert"
  project     = "aviato-game-fight-rvxirf"
  combiner    = "OR"
  conditions {
    display_name = "Cloud Storage IAM Permission Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/bucket-permission-changes\" AND resource.type=\"gcs_bucket\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
      trigger {
        count = 1
      }
    }
  }
}

resource "google_logging_metric" "custom_role_changes" {
  name        = "custom-role-changes"
  project     = "aviato-game-fight-rvxirf"
  description = "Metric for custom role changes"
