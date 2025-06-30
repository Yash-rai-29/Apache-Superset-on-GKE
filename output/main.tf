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

resource "google_project_metadata" "oslogin" {
  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_subnetwork" "default_subnet_asia_east2" {
  name                     = "default"
  ip_cidr_range            = "10.132.0.0/20"
  region                   = "asia-east2"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_asia_southeast2" {
  name                     = "default"
  ip_cidr_range            = "10.138.0.0/20"
  region                   = "asia-southeast2"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_us_east5" {
  name                     = "default"
  ip_cidr_range            = "10.168.0.0/20"
  region                   = "us-east5"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_europe_west8" {
  name                     = "default"
  ip_cidr_range            = "10.164.0.0/20"
  region                   = "europe-west8"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_europe_west3" {
  name                     = "default"
  ip_cidr_range            = "10.136.0.0/20"
  region                   = "europe-west3"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_europe_west9" {
  name                     = "default"
  ip_cidr_range            = "10.170.0.0/20"
  region                   = "europe-west9"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_me_central1" {
  name                     = "default"
  ip_cidr_range            = "10.172.0.0/20"
  region                   = "me-central1"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_asia_south2" {
  name                     = "default"
  ip_cidr_range            = "10.174.0.0/20"
  region                   = "asia-south2"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_asia_northeast3" {
  name                     = "default"
  ip_cidr_range            = "10.156.0.0/20"
  region                   = "asia-northeast3"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_australia_southeast1" {
  name                     = "default"
  ip_cidr_range            = "10.140.0.0/20"
  region                   = "australia-southeast1"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_asia_south1" {
  name                     = "default"
  ip_cidr_range            = "10.150.0.0/20"
  region                   = "asia-south1"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_northamerica_south1" {
  name                     = "default"
  ip_cidr_range            = "10.176.0.0/20"
  region                   = "northamerica-south1"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_me_west1" {
  name                     = "default"
  ip_cidr_range            = "10.178.0.0/20"
  region                   = "me-west1"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_asia_northeast2" {
  name                     = "default"
  ip_cidr_range            = "10.154.0.0/20"
  region                   = "asia-northeast2"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_europe_west2" {
  name                     = "default"
  ip_cidr_range            = "10.130.0.0/20"
  region                   = "europe-west2"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_asia_northeast1" {
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  region                   = "asia-northeast1"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_me_central2" {
  name                     = "default"
  ip_cidr_range            = "10.180.0.0/20"
  region                   = "me-central2"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_northamerica_northeast2" {
  name                     = "default"
  ip_cidr_range            = "10.166.0.0/20"
  region                   = "northamerica-northeast2"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_southamerica_west1" {
  name                     = "default"
  ip_cidr_range            = "10.182.0.0/20"
  region                   = "southamerica-west1"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_europe_west6" {
  name                     = "default"
  ip_cidr_range            = "10.158.0.0/20"
  region                   = "europe-west6"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_australia_southeast2" {
  name                     = "default"
  ip_cidr_range            = "10.184.0.0/20"
  region                   = "australia-southeast2"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_europe_west12" {
  name                     = "default"
  ip_cidr_range            = "10.186.0.0/20"
  region                   = "europe-west12"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_us_south1" {
  name                     = "default"
  ip_cidr_range            = "10.152.0.0/20"
  region                   = "us-south1"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_europe_central2" {
  name                     = "default"
  ip_cidr_range            = "10.144.0.0/20"
  region                   = "europe-central2"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_europe_west4" {
  name                     = "default"
  ip_cidr_range            = "10.146.0.0/20"
  region                   = "europe-west4"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_europe_west10" {
  name                     = "default"
  ip_cidr_range            = "10.188.0.0/20"
  region                   = "europe-west10"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_asia_southeast1" {
  name                     = "default"
  ip_cidr_range            = "10.148.0.0/20"
  region                   = "asia-southeast1"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_asia_east1" {
  name                     = "default"
  ip_cidr_range            = "10.124.0.0/20"
  region                   = "asia-east1"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_us_west1" {
  name                     = "default"
  ip_cidr_range            = "10.120.0.0/20"
  region                   = "us-west1"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_europe_west1" {
  name                     = "default"
  ip_cidr_range            = "10.122.0.0/20"
  region                   = "europe-west1"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_northamerica_northeast1" {
  name                     = "default"
  ip_cidr_range            = "10.162.0.0/20"
  region                   = "northamerica-northeast1"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_europe_north1" {
  name                     = "default"
  ip_cidr_range            = "10.142.0.0/20"
  region                   = "europe-north1"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_southamerica_east1" {
  name                     = "default"
  ip_cidr_range            = "10.148.0.0/20"
  region                   = "southamerica-east1"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_us_west4" {
  name                     = "default"
  ip_cidr_range            = "10.190.0.0/20"
  region                   = "us-west4"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_us_west3" {
  name                     = "default"
  ip_cidr_range            = "10.192.0.0/20"
  region                   = "us-west3"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_us_east4" {
  name                     = "default"
  ip_cidr_range            = "10.154.0.0/20"
  region                   = "us-east4"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_us_central1" {
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  region                   = "us-central1"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_us_west2" {
  name                     = "default"
  ip_cidr_range            = "10.194.0.0/20"
  region                   = "us-west2"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_europe_southwest1" {
  name                     = "default"
  ip_cidr_range            = "10.196.0.0/20"
  region                   = "europe-southwest1"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_compute_subnetwork" "default_subnet_us_east1" {
  name                     = "default"
  ip_cidr_range            = "10.124.0.0/20"
  region                   = "us-east1"
  network                  = "default"
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_project_service" "containeranalysis" {
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudasset" {
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_storage_bucket" "bucket_aviato_game_fight_rvxirf_appspot" {
  name                        = "aviato-game-fight-rvxirf.appspot.com"
  location                    = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "bucket_aviato_game_fight_rvxirf_bucket" {
  name                        = "aviato-game-fight-rvxirf_bucket"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "bucket_staging_aviato_game_fight_rvxirf_appspot" {
  name                        = "staging.aviato-game-fight-rvxirf.appspot.com"
  location                    = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}

resource "google_compute_firewall" "default_allow_rdp" {
  name    = "default-allow-rdp"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  source_ranges = ["10.0.0.0/8", "192.168.0.0/16"]
}

resource "google_compute_firewall" "default_allow_ssh" {
  name    = "default-allow-ssh"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
   source_ranges = ["10.0.0.0/8", "192.168.0.0/16"]
}

resource "google_compute_network" "default_network" {
  name                    = "default"
  auto_create_subnetworks = "false"
  delete_default_routes_on_destroy = true
}

resource "google_compute_network_dns_policy" "default_network_dns_policy" {
  name = "default-dns-policy"
  network = "default"
  enable_logging = true
}

resource "google_logging_project_sink" "project_sink" {
  name = "all-logs"
  destination = "storage.googleapis.com/${google_storage_bucket.bucket_aviato_game_fight_rvxirf_appspot.name}"
  filter = "NOT logName:('projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Fdata_access') AND NOT logName:('projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Fsystem_event') AND NOT logName:('projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Faudit')"
  project = var.project_id
}

variable "project_id" {
  type = string
  default = "aviato-game-fight-rvxirf"
}
