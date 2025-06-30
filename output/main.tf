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

resource "google_project_service" "containeranalysis" {
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_iam_binding" "service_account_binding_firebase_sdkadmin" {
  project = "aviato-game-fight-rvxirf"
  role    = "roles/firebase.sdkAdminServiceAgent"
  members = [
    "serviceAccount:twitch-login@aviato-game-fight-rvxirf.iam.gserviceaccount.com",
  ]
}

resource "google_project_iam_binding" "service_account_binding_editor_default" {
  project = "aviato-game-fight-rvxirf"
  role    = "roles/editor"
  members = []
}

resource "google_project_iam_binding" "service_account_binding_storage_admin_firebase" {
  project = "aviato-game-fight-rvxirf"
  role    = "roles/storage.admin"
  members = []
}

resource "google_compute_network" "default" {
  name                    = "default"
  project                 = "aviato-game-fight-rvxirf"
  delete_default_routes = true
}

resource "google_compute_subnetwork" "default_asia_east2" {
  name          = "default"
  ip_cidr_range = "10.132.0.0/20"
  network       = "default"
  region        = "asia-east2"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_asia_southeast2" {
  name          = "default"
  ip_cidr_range = "10.156.0.0/20"
  network       = "default"
  region        = "asia-southeast2"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_us_east5" {
  name          = "default"
  ip_cidr_range = "10.120.0.0/20"
  network       = "default"
  region        = "us-east5"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_europe_west8" {
  name          = "default"
  ip_cidr_range = "10.164.0.0/20"
  network       = "default"
  region        = "europe-west8"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_europe_west3" {
  name          = "default"
  ip_cidr_range = "10.138.0.0/20"
  network       = "default"
  region        = "europe-west3"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_europe_west9" {
  name          = "default"
  ip_cidr_range = "10.166.0.0/20"
  network       = "default"
  region        = "europe-west9"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_me_central1" {
  name          = "default"
  ip_cidr_range = "10.168.0.0/20"
  network       = "default"
  region        = "me-central1"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_asia_south2" {
  name          = "default"
  ip_cidr_range = "10.174.0.0/20"
  network       = "default"
  region        = "asia-south2"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_asia_northeast3" {
  name          = "default"
  ip_cidr_range = "10.160.0.0/20"
  network       = "default"
  region        = "asia-northeast3"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_australia_southeast1" {
  name          = "default"
  ip_cidr_range = "10.150.0.0/20"
  network       = "default"
  region        = "australia-southeast1"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_asia_south1" {
  name          = "default"
  ip_cidr_range = "10.158.0.0/20"
  network       = "default"
  region        = "asia-south1"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_northamerica_south1" {
  name          = "default"
  ip_cidr_range = "10.170.0.0/20"
  network       = "default"
  region        = "northamerica-south1"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_me_west1" {
  name          = "default"
  ip_cidr_range = "10.162.0.0/20"
  network       = "default"
  region        = "me-west1"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_asia_northeast2" {
  name          = "default"
  ip_cidr_range = "10.154.0.0/20"
  network       = "default"
  region        = "asia-northeast2"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_europe_west2" {
  name          = "default"
  ip_cidr_range = "10.130.0.0/20"
  network       = "default"
  region        = "europe-west2"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_asia_northeast1" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "asia-northeast1"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_me_central2" {
  name          = "default"
  ip_cidr_range = "10.172.0.0/20"
  network       = "default"
  region        = "me-central2"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_northamerica_northeast2" {
  name          = "default"
  ip_cidr_range = "10.176.0.0/20"
  network       = "default"
  region        = "northamerica-northeast2"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_southamerica_west1" {
  name          = "default"
  ip_cidr_range = "10.178.0.0/20"
  network       = "default"
  region        = "southamerica-west1"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_europe_west6" {
  name          = "default"
  ip_cidr_range = "10.140.0.0/20"
  network       = "default"
  region        = "europe-west6"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_australia_southeast2" {
  name          = "default"
  ip_cidr_range = "10.152.0.0/20"
  network       = "default"
  region        = "australia-southeast2"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_europe_west12" {
  name          = "default"
  ip_cidr_range = "10.180.0.0/20"
  network       = "default"
  region        = "europe-west12"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_us_south1" {
  name          = "default"
  ip_cidr_range = "10.182.0.0/20"
  network       = "default"
  region        = "us-south1"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_europe_central2" {
  name          = "default"
  ip_cidr_range = "10.134.0.0/20"
  network       = "default"
  region        = "europe-central2"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_europe_west4" {
  name          = "default"
  ip_cidr_range = "10.136.0.0/20"
  network       = "default"
  region        = "europe-west4"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_europe_west10" {
  name          = "default"
  ip_cidr_range = "10.184.0.0/20"
  network       = "default"
  region        = "europe-west10"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_asia_southeast1" {
  name          = "default"
  ip_cidr_range = "10.148.0.0/20"
  network       = "default"
  region        = "asia-southeast1"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_asia_east1" {
  name          = "default"
  ip_cidr_range = "10.124.0.0/20"
  network       = "default"
  region        = "asia-east1"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_us_west1" {
  name          = "default"
  ip_cidr_range = "10.142.0.0/20"
  network       = "default"
  region        = "us-west1"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_europe_west1" {
  name          = "default"
  ip_cidr_range = "10.122.0.0/20"
  network       = "default"
  region        = "europe-west1"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_northamerica_northeast1" {
  name          = "default"
  ip_cidr_range = "10.154.0.0/20"
  network       = "default"
  region        = "northamerica-northeast1"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_europe_north1" {
  name          = "default"
  ip_cidr_range = "10.144.0.0/20"
  network       = "default"
  region        = "europe-north1"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_southamerica_east1" {
  name          = "default"
  ip_cidr_range = "10.146.0.0/20"
  network       = "default"
  region        = "southamerica-east1"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_us_west4" {
  name          = "default"
  ip_cidr_range = "10.186.0.0/20"
  network       = "default"
  region        = "us-west4"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_us_west3" {
  name          = "default"
  ip_cidr_range = "10.188.0.0/20"
  network       = "default"
  region        = "us-west3"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_us_east4" {
  name          = "default"
  ip_cidr_range = "10.118.0.0/20"
  network       = "default"
  region        = "us-east4"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_us_central1" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "us-central1"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_us_west2" {
  name          = "default"
  ip_cidr_range = "10.190.0.0/20"
  network       = "default"
  region        = "us-west2"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_europe_southwest1" {
  name          = "default"
  ip_cidr_range = "10.192.0.0/20"
  network       = "default"
  region        = "europe-southwest1"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}
resource "google_compute_subnetwork" "default_us_east1" {
  name          = "default"
  ip_cidr_range = "10.116.0.0/20"
  network       = "default"
  region        = "us-east1"
  project     = "aviato-game-fight-rvxirf"
  flow_logs = true
}

resource "google_project_metadata" "project_metadata" {
  project = "aviato-game-fight-rvxirf"
  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_logging_project_sink" "default" {
  name        = "all-logs"
  destination = "storage.googleapis.com/${google_storage_bucket.sink_bucket.name}"
  filter      = "NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Fdata_access"
  project     = "aviato-game-fight-rvxirf"
}

resource "google_storage_bucket" "sink_bucket" {
  name                        = "${var.project_id}-logging-bucket"
  location                    = "US"
  project                     = "aviato-game-fight-rvxirf"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "appspot_bucket_1" {
  name                        = "aviato-game-fight-rvxirf.appspot.com"
  location                    = "AUSTRALIA-SOUTHEAST1"
  project                     = "aviato-game-fight-rvxirf"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "appspot_bucket_2" {
  name                        = "aviato-game-fight-rvxirf_bucket"
  location                    = "US"
  project                     = "aviato-game-fight-rvxirf"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "appspot_bucket_3" {
  name                        = "staging.aviato-game-fight-rvxirf.appspot.com"
  location                    = "AUSTRALIA-SOUTHEAST1"
  project                     = "aviato-game-fight-rvxirf"
  uniform_bucket_level_access = true
}

resource "google_compute_firewall" "rdp" {
  name    = "default-allow-rdp"
  network = "default"
  project = "aviato-game-fight-rvxirf"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]

}

resource "google_compute_firewall" "ssh" {
  name    = "default-allow-ssh"
  network = "default"
  project = "aviato-game-fight-rvxirf"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

resource "google_project_service" "cloudasset" {
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

variable "project_id" {
  type = string
  default = "aviato-game-fight-rvxirf"
}
