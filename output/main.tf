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
  project  = "aviato-game-fight-rvxirf"
  service  = "containeranalysis.googleapis.com"
}

resource "google_project_service" "container_analysis" {
  provider = google
  project                    = "aviato-game-fight-rvxirf"
  service                    = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudasset" {
  provider = google
  project                    = "aviato-game-fight-rvxirf"
  service                    = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_network" "default" {
  provider = google
  name                    = "default"
  project                 = "aviato-game-fight-rvxirf"
  delete_default_routes = true
}

resource "google_compute_subnetwork" "default_asia_east2" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.132.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "asia-east2"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_asia_southeast2" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.164.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "asia-southeast2"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_us_east5" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.148.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "us-east5"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_europe_west8" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.168.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "europe-west8"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_europe_west3" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.136.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "europe-west3"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_europe_west9" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.166.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "europe-west9"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_me_central1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.172.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "me-central1"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_asia_south2" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.174.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "asia-south2"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_asia_northeast3" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.170.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "asia-northeast3"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_australia_southeast1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.140.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "australia-southeast1"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_asia_south1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.128.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "asia-south1"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_northamerica_south1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.158.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "northamerica-south1"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_me_west1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.176.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "me-west1"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_asia_northeast2" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.160.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "asia-northeast2"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_europe_west2" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.130.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "europe-west2"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_asia_east1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.129.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "asia-east1"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_us_west1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.138.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "us-west1"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_europe_west1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.132.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "europe-west1"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_northamerica_northeast1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.152.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "northamerica-northeast1"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_europe_north2" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.178.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "europe-north2"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_africa_south1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.177.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "africa-south1"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_europe_north1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.134.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "europe-north1"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_southamerica_east1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.156.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "southamerica-east1"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_us_west4" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.154.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "us-west4"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_us_west3" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.144.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "us-west3"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_us_east4" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.142.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "us-east4"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_us_central1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.128.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "us-central1"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_us_west2" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.146.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "us-west2"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_europe_southwest1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.180.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "europe-southwest1"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "default_us_east1" {
  provider = google
  name                     = "default"
  ip_cidr_range          = "10.140.0.0/20"
  network                  = "default"
  project                  = "aviato-game-fight-rvxirf"
  region                   = "us-east1"
  private_ip_google_access = true
  flow_logs {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_project_metadata" "oslogin" {
  provider = google
  project = "aviato-game-fight-rvxirf"

  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_storage_bucket" "default_bucket_level_access_aviato_game_fight_rvxirf_appspot_com" {
  name          = "aviato-game-fight-rvxirf.appspot.com"
  location      = "AUSTRALIA-SOUTHEAST1"
  project       = "aviato-game-fight-rvxirf"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "default_bucket_level_access_aviato_game_fight_rvxirf_bucket" {
  name          = "aviato-game-fight-rvxirf_bucket"
  location      = "US"
  project       = "aviato-game-fight-rvxirf"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "default_bucket_level_access_staging_aviato_game_fight_rvxirf_appspot_com" {
  name          = "staging.aviato-game-fight-rvxirf.appspot.com"
  location      = "AUSTRALIA-SOUTHEAST1"
  project       = "aviato-game-fight-rvxirf"
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

  source_ranges = ["0.0.0.0/0"]
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

  source_ranges = ["0.0.0.0/0"]
}

resource "google_logging_metric" "audit_configuration_changes" {
  provider = google
  name          = "audit-configuration-changes"
  project       = "aviato-game-fight-rvxirf"
  description = "Metric for tracking audit configuration changes"
  filter      = "protoPayload.methodName=\"SetIamPolicy\" OR protoPayload.methodName=\"google.cloud.audit.AuditPolicies.UpdateAuditConfig\""
  metric_descriptor {
    launch_stage = "BETA"
    type         = "counter"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "audit_configuration_changes" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  display_name = "Audit Configuration Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "Audit Configuration Changes"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/audit-configuration-changes\" AND resource.project_id=\"aviato-game-fight-rvxirf\""
      comparison = "COMPARISON_GT"
      threshold_value = 0
      duration    = "60s"
      trigger {
          count   = 1
          percent = 0
      }
    }
  }
}

resource "google_logging_metric" "bucket_permission_changes" {
  provider = google
  name          = "bucket-permission-changes"
  project       = "aviato-game-fight-rvxirf"
  description = "Metric for tracking cloud storage bucket permission changes"
  filter      = "resource.type=\"gcs_bucket\" AND protoPayload.methodName=\"storage.setIamPermissions\""
  metric_descriptor {
    launch_stage = "BETA"
    type         = "counter"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  display_name = "Cloud Storage Bucket Permission Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "Cloud Storage Bucket Permission Changes"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/bucket-permission-changes\" AND resource.project_id=\"aviato-game-fight-rvxirf\""
      comparison = "COMPARISON_GT"
      threshold_value = 0
      duration    = "60s"
      trigger {
          count   = 1
          percent = 0
      }
    }
  }
}

resource "google_logging_metric" "custom_role_changes" {
  provider = google
  name          = "custom-role-changes"
  project       = "aviato-game-fight-rvxirf"
  description = "Metric for tracking custom role changes"
  filter      = "resource.type=\"iam_role\" AND (protoPayload.methodName=\"google.iam.admin.v1.CreateRole\" OR protoPayload.methodName=\"google.iam.admin.v1.DeleteRole\" OR protoPayload.methodName=\"google.iam.admin.v1.UpdateRole\")"
  metric_descriptor {
    launch_stage = "BETA"
    type         = "counter"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  display_name = "Custom Role Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "Custom Role Changes"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/custom-role-changes\" AND resource.project_id=\"aviato-game-fight-rvxirf\""
      comparison = "COMPARISON_GT"
      threshold_value = 0
      duration    = "60s"
      trigger {
          count   = 1
          percent = 0
      }
    }
  }
}

resource "google_logging_metric" "project_ownership_changes" {
  provider = google
  name          = "project-ownership-changes"
  project       = "aviato-game-fight-rvxirf"
  description = "Metric for tracking project ownership changes"
  filter      = "protoPayload.methodName=\"SetIamPolicy\" AND resource.type=\"project\" AND protoPayload.request.policy.bindings:\"roles/owner\""
  metric_descriptor {
    launch_stage = "BETA"
    type         = "counter"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  display_name = "Project Ownership Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "Project Ownership Changes"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/project-ownership-changes\" AND resource.project_id=\"aviato-game-fight-rvxirf\""
      comparison = "COMPARISON_GT"
      threshold_value = 0
      duration    = "60s"
      trigger {
          count   = 1
          percent = 0
      }
    }
  }
}

resource "google_logging_metric" "sql_instance_configuration_changes" {
  provider = google
  name          = "sql-instance-configuration-changes"
  project       = "aviato-game-fight-rvxirf"
  description = "Metric for tracking SQL instance configuration changes"
  filter      = "resource.type=\"cloudsql_instance\" AND protoPayload.methodName=\"cloudsql.instances.update\""
  metric_descriptor {
    launch_stage = "BETA"
    type         = "counter"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "sql_instance_configuration_changes" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  display_name = "SQL Instance Configuration Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "SQL Instance Configuration Changes"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/sql-instance-configuration-changes\" AND resource.project_id=\"aviato-game-fight-rvxirf\""
      comparison = "COMPARISON_GT"
      threshold_value = 0
      duration    = "60s"
      trigger {
          count   = 1
          percent = 0
      }
    }
  }
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  provider = google
  name          = "vpc-firewall-rule-changes"
  project       = "aviato-game-fight-rvxirf"
  description = "Metric for tracking VPC firewall rule changes"
  filter      = "resource.type=\"gce_firewall_rule\" AND (protoPayload.methodName=\"compute.firewalls.insert\" OR protoPayload.methodName=\"compute.firewalls.patch\" OR protoPayload.methodName=\"compute.firewalls.delete\")"
  metric_descriptor {
    launch_stage = "BETA"
    type         = "counter"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  display_name = "VPC Firewall Rule Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "VPC Firewall Rule Changes"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/vpc-firewall-rule-changes\" AND resource.project_id=\"aviato-game-fight-rvxirf\""
      comparison = "COMPARISON_GT"
      threshold_value = 0
      duration    = "60s"
      trigger {
          count   = 1
          percent = 0
      }
    }
  }
}

resource "google_logging_metric" "vpc_network_changes" {
  provider = google
  name          = "vpc-network-changes"
  project       = "aviato-game-fight-rvxirf"
  description = "Metric for tracking VPC network changes"
  filter      = "resource.type=\"gce_network\" AND (protoPayload.methodName=\"compute.networks.insert\" OR protoPayload.methodName=\"compute.networks.patch\" OR protoPayload.methodName=\"compute.networks.delete\")"
  metric_descriptor {
    launch_stage = "BETA"
    type         = "counter"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  display_name = "VPC Network Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "VPC Network Changes"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/vpc-network-changes\" AND resource.project_id=\"aviato-game-fight-rvxirf\""
      comparison = "COMPARISON_GT"
      threshold_value = 0
      duration    = "60s"
      trigger {
          count   = 1
          percent = 0
      }
    }
  }
}

resource "google_logging_metric" "vpc_network_route_changes" {
  provider = google
  name          = "vpc-network-route-changes"
  project       = "aviato-game-fight-rvxirf"
  description = "Metric for tracking VPC network route changes"
  filter      = "resource.type=\"gce_route\" AND (protoPayload.methodName=\"compute.routes.insert\" OR protoPayload.methodName=\"compute.routes.delete\")"
  metric_descriptor {
    launch_stage = "BETA"
    type         = "counter"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  display_name = "VPC Network Route Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "VPC Network Route Changes"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/vpc-network-route-changes\" AND resource.project_id=\"aviato-game-fight-rvxirf\""
      comparison = "COMPARISON_GT"
      threshold_value = 0
      duration    = "60s"
      trigger {
          count   = 1
          percent = 0
      }

