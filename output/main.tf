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
  region  = "us-central1"
}

resource "google_project_service_identity" "artifact_registry" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "containeranalysis" {
  provider = google
  project            = "aviato-game-fight-rvxirf"
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_storage_bucket" "bucket_uniform_bucket_level_access_1" {
  provider = google
  name                        = "aviato-game-fight-rvxirf.appspot.com"
  location                    = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "bucket_uniform_bucket_level_access_2" {
  provider = google
  name                        = "aviato-game-fight-rvxirf_bucket"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "bucket_uniform_bucket_level_access_3" {
  provider = google
  name                        = "staging.aviato-game-fight-rvxirf.appspot.com"
  location                    = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}

resource "google_compute_firewall" "default_allow_ssh" {
  provider = google
  name    = "default-allow-ssh"
  network = "default"
  project = "aviato-game-fight-rvxirf"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["130.211.0.0/22", "35.235.0.0/24"]
}

resource "google_compute_firewall" "default_allow_rdp" {
  provider = google
  name    = "default-allow-rdp"
  network = "default"
  project = "aviato-game-fight-rvxirf"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["130.211.0.0/22", "35.235.0.0/24"]
}

resource "google_compute_network" "default" {
  provider = google
  name                    = "default"
  project                 = "aviato-game-fight-rvxirf"
  delete_default_routes = true
}

resource "google_compute_network" "default_dns_logging" {
  provider = google
  name                    = "default"
  project                 = "aviato-game-fight-rvxirf"
  enable_logging = true
}

resource "google_project_metadata" "enable_oslogin" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_subnetwork" "default_asia_east2" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.128.0.0/20"
  network                  = "default"
  region                   = "asia-east2"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_asia_southeast2" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.130.0.0/20"
  network                  = "default"
  region                   = "asia-southeast2"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_us_east5" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.158.0.0/20"
  network                  = "default"
  region                   = "us-east5"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_europe_west8" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.164.0.0/20"
  network                  = "default"
  region                   = "europe-west8"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_europe_west3" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.132.0.0/20"
  network                  = "default"
  region                   = "europe-west3"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_europe_west9" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.174.0.0/20"
  network                  = "default"
  region                   = "europe-west9"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_me_central1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.170.0.0/20"
  network                  = "default"
  region                   = "me-central1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_asia_south2" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.172.0.0/20"
  network                  = "default"
  region                   = "asia-south2"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_asia_northeast3" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.168.0.0/20"
  network                  = "default"
  region                   = "asia-northeast3"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_australia_southeast1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.140.0.0/20"
  network                  = "default"
  region                   = "australia-southeast1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_asia_south1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.136.0.0/20"
  network                  = "default"
  region                   = "asia-south1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_northamerica_south1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.166.0.0/20"
  network                  = "default"
  region                   = "northamerica-south1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_me_west1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.162.0.0/20"
  network                  = "default"
  region                   = "me-west1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_asia_northeast2" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.134.0.0/20"
  network                  = "default"
  region                   = "asia-northeast2"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_europe_west2" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.138.0.0/20"
  network                  = "default"
  region                   = "europe-west2"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_asia_east1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.129.0.0/20"
  network                  = "default"
  region                   = "asia-east1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_us_west1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.131.0.0/20"
  network                  = "default"
  region                   = "us-west1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_europe_southwest1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.173.0.0/20"
  network                  = "default"
  region                   = "europe-southwest1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_us_east1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.142.0.0/20"
  network                  = "default"
  region                   = "us-east1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_northamerica_northeast1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.171.0.0/20"
  network                  = "default"
  region                   = "northamerica-northeast1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_europe_north1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.165.0.0/20"
  network                  = "default"
  region                   = "europe-north1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_africa_south1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.175.0.0/20"
  network                  = "default"
  region                   = "africa-south1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_southamerica_east1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.152.0.0/20"
  network                  = "default"
  region                   = "southamerica-east1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_us_west4" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.157.0.0/20"
  network                  = "default"
  region                   = "us-west4"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_us_west3" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.156.0.0/20"
  network                  = "default"
  region                   = "us-west3"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_us_east4" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.147.0.0/20"
  network                  = "default"
  region                   = "us-east4"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_us_central1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.128.0.0/20"
  network                  = "default"
  region                   = "us-central1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_us_west2" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.155.0.0/20"
  network                  = "default"
  region                   = "us-west2"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_europe_west12" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.177.0.0/20"
  network                  = "default"
  region                   = "europe-west12"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_southamerica_west1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.176.0.0/20"
  network                  = "default"
  region                   = "southamerica-west1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_europe_west6" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.133.0.0/20"
  network                  = "default"
  region                   = "europe-west6"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_australia_southeast2" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.178.0.0/20"
  network                  = "default"
  region                   = "australia-southeast2"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_europe_central2" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.179.0.0/20"
  network                  = "default"
  region                   = "europe-central2"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_northamerica_northeast2" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.180.0.0/20"
  network                  = "default"
  region                   = "northamerica-northeast2"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_europe_west4" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.135.0.0/20"
  network                  = "default"
  region                   = "europe-west4"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_us_south1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.154.0.0/20"
  network                  = "default"
  region                   = "us-south1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_europe_west10" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.181.0.0/20"
  network                  = "default"
  region                   = "europe-west10"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_asia_southeast1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.143.0.0/20"
  network                  = "default"
  region                   = "asia-southeast1"
  project = "aviato-game-fight-rvxirf"
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_logging_project_sink" "default" {
  provider = google
  name        = "all-logs"
  project     = "aviato-game-fight-rvxirf"
  destination = "storage.googleapis.com/${google_storage_bucket.bucket_uniform_bucket_level_access_1.name}"
  filter      = "NOT logName:('projects/example-project/logs/cloudaudit.googleapis.com%2Fdata_access')"
}
