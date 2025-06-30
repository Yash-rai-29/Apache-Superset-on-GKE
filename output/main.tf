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

resource "google_project_iam_binding" "container_analysis_artifact_registry" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  role = "roles/artifactregistry.reader"
  members = [
    "serviceAccount:${google_project_service_identity.container_analysis.email}",
  ]
}

resource "google_storage_bucket" "default" {
  name                        = "aviato-game-fight-rvxirf.appspot.com"
  location                    = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "default2" {
  name                        = "aviato-game-fight-rvxirf_bucket"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "default3" {
  name                        = "staging.aviato-game-fight-rvxirf.appspot.com"
  location                    = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}

resource "google_compute_firewall" "default_allow_ssh" {
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
  name    = "default-allow-rdp"
  network = "default"
  project = "aviato-game-fight-rvxirf"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

   source_ranges = ["130.211.0.0/22", "35.235.0.0/24"]
}

resource "google_compute_network" "default_network" {
  name                    = "default"
  project                 = "aviato-game-fight-rvxirf"
  delete_default_routes = true
}

resource "google_compute_network" "custom_network" {
  name                    = "new-network"
  project                 = "aviato-game-fight-rvxirf"
  auto_create_subnetworks = "false"
}

resource "google_compute_global_network_endpoint_group" "default_network2" {
  name      = "default-network"
  project   = "aviato-game-fight-rvxirf"
  network   = "default"
}

resource "google_compute_network_dns_logging_policy" "default_dns_policy" {
  name       = "default-dns-policy"
  project   = "aviato-game-fight-rvxirf"
  network   = "default"
}

resource "google_project_metadata" "enable_oslogin" {
  project = "aviato-game-fight-rvxirf"
  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_subnetwork" "default_asia_east2" {
  name          = "default"
  ip_cidr_range = "10.168.0.0/20"
  network       = "default"
  region        = "asia-east2"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_asia_southeast2" {
  name          = "default"
  ip_cidr_range = "10.156.0.0/20"
  network       = "default"
  region        = "asia-southeast2"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_us_east5" {
  name          = "default"
  ip_cidr_range = "10.140.0.0/20"
  network       = "default"
  region        = "us-east5"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_europe_west8" {
  name          = "default"
  ip_cidr_range = "10.152.0.0/20"
  network       = "default"
  region        = "europe-west8"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_europe_west3" {
  name          = "default"
  ip_cidr_range = "10.132.0.0/20"
  network       = "default"
  region        = "europe-west3"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_europe_west9" {
  name          = "default"
  ip_cidr_range = "10.164.0.0/20"
  network       = "default"
  region        = "europe-west9"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_me_central1" {
  name          = "default"
  ip_cidr_range = "10.148.0.0/20"
  network       = "default"
  region        = "me-central1"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_asia_south2" {
  name          = "default"
  ip_cidr_range = "10.162.0.0/20"
  network       = "default"
  region        = "asia-south2"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_asia_northeast3" {
  name          = "default"
  ip_cidr_range = "10.160.0.0/20"
  network       = "default"
  region        = "asia-northeast3"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_australia_southeast1" {
  name          = "default"
  ip_cidr_range = "10.128.0.0/20"
  network       = "default"
  region        = "australia-southeast1"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_asia_south1" {
  name          = "default"
  ip_cidr_range = "10.150.0.0/20"
  network       = "default"
  region        = "asia-south1"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_northamerica_south1" {
  name          = "default"
  ip_cidr_range = "10.158.0.0/20"
  network       = "default"
  region        = "northamerica-south1"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_me_west1" {
  name          = "default"
  ip_cidr_range = "10.154.0.0/20"
  network       = "default"
  region        = "me-west1"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_asia_northeast2" {
  name          = "default"
  ip_cidr_range = "10.138.0.0/20"
  network       = "default"
  region        = "asia-northeast2"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_europe_west2" {
  name          = "default"
  ip_cidr_range = "10.130.0.0/20"
  network       = "default"
  region        = "europe-west2"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_asia_northeast1" {
  name          = "default"
  ip_cidr_range = "10.136.0.0/20"
  network       = "default"
  region        = "asia-northeast1"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_me_central2" {
  name          = "default"
  ip_cidr_range = "10.166.0.0/20"
  network       = "default"
  region        = "me-central2"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_northamerica_northeast1" {
  name          = "default"
  ip_cidr_range = "10.142.0.0/20"
  network       = "default"
  region        = "northamerica-northeast1"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_europe_north2" {
  name          = "default"
  ip_cidr_range = "10.144.0.0/20"
  network       = "default"
  region        = "europe-north2"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_africa_south1" {
  name          = "default"
  ip_cidr_range = "10.170.0.0/20"
  network       = "default"
  region        = "africa-south1"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_europe_north1" {
  name          = "default"
  ip_cidr_range = "10.134.0.0/20"
  network       = "default"
  region        = "europe-north1"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_southamerica_east1" {
  name          = "default"
  ip_cidr_range = "10.146.0.0/20"
  network       = "default"
  region        = "southamerica-east1"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_us_west4" {
  name          = "default"
  ip_cidr_range = "10.124.0.0/20"
  network       = "default"
  region        = "us-west4"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_us_west3" {
  name          = "default"
  ip_cidr_range = "10.116.0.0/20"
  network       = "default"
  region        = "us-west3"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_us_east4" {
  name          = "default"
  ip_cidr_range = "10.120.0.0/20"
  network       = "default"
  region        = "us-east4"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_us_central1" {
  name          = "default"
  ip_cidr_range = "10.112.0.0/20"
  network       = "default"
  region        = "us-central1"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_us_west2" {
  name          = "default"
  ip_cidr_range = "10.114.0.0/20"
  network       = "default"
  region        = "us-west2"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_europe_southwest1" {
  name          = "default"
  ip_cidr_range = "10.172.0.0/20"
  network       = "default"
  region        = "europe-southwest1"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_us_east1" {
  name          = "default"
  ip_cidr_range = "10.104.0.0/20"
  network       = "default"
  region        = "us-east1"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_europe_west12" {
  name          = "default"
  ip_cidr_range = "10.174.0.0/20"
  network       = "default"
  region        = "europe-west12"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_compute_subnetwork" "default_us_south1" {
  name          = "default"
  ip_cidr_range = "10.118.0.0/20"
  network       = "default"
  region        = "us-south1"
  project   = "aviato-game-fight-rvxirf"
  flow_logs     = true
}

resource "google_project_service" "cloudasset" {
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
  project = "aviato-game-fight-rvxirf"
}

resource "google_logging_project_sink" "all_logs" {
  name = "all-logs-sink"
  project = "aviato-game-fight-rvxirf"
  destination = "storage.googleapis.com/${google_storage_bucket.default.name}"
  filter      = "NOT logName:('projects/${"aviato-game-fight-rvxirf"}/logs/cloudaudit.googleapis.com%2Fdata_access') AND NOT logName:('projects/${"aviato-game-fight-rvxirf"}/logs/system.gke.io%2Faudit')"
}

resource "google_logging_metric" "audit_config_changes" {
  name = "audit-config-changes"
  project = "aviato-game-fight-rvxirf"
  description = "Audit configuration changes"
  filter = "resource.type=audited_resource AND severity>=NOTICE AND protoPayload.methodName=SetIamPolicy OR protoPayload.methodName=Insert AND resource.type=gcp_project OR resource.type=project"
  metric_descriptor {
    launch_stage = "BETA"
    name = "Audit Configuration"
    type = "GAUGE"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "audit_config_changes_alert" {
  display_name = "Audit Configuration Changes Alert"
  project = "aviato-game-fight-rvxirf"
  combiner = "OR"
  conditions {
    display_name = "Audit Configuration Changes Condition"
    condition_threshold {
      filter = "resource.type=audited_resource AND severity>=NOTICE AND protoPayload.methodName=SetIamPolicy OR protoPayload.methodName=Insert AND resource.type=gcp_project OR resource.type=project"
      duration = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
}

resource "google_logging_metric" "bucket_permission_changes" {
  name = "bucket-permission-changes"
  project = "aviato-game-fight-rvxirf"
  description = "Bucket permission changes"
  filter = "resource.type=gcs_bucket AND protoPayload.methodName=\"storage.setIamPermissions\""
  metric_descriptor {
    launch_stage = "BETA"
    name = "Bucket Permission Changes"
    type = "GAUGE"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes_alert" {
  display_name = "Bucket Permission Changes Alert"
  project = "aviato-game-fight-rvxirf"
  combiner = "OR"
  conditions {
    display_name = "Bucket Permission Changes Condition"
    condition_threshold {
      filter = "resource.type=gcs_bucket AND protoPayload.methodName=\"storage.setIamPermissions\""
      duration = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
}

resource "google_logging_metric" "custom_role_changes" {
  name = "custom-role-changes"
  project = "aviato-game-fight-rvxirf"
  description = "Custom role changes"
  filter = "resource.type=iam_role AND protoPayload.methodName=(\"google.iam.admin.v1.CreateRole\" OR \"google.iam.admin.v1.DeleteRole\" OR \"google.iam.admin.v1.UpdateRole\")"
  metric_descriptor {
    launch_stage = "BETA"
    name = "Custom Role Changes"
    type = "GAUGE"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes_alert" {
  display_name = "Custom Role Changes Alert"
  project = "aviato-game-fight-rvxirf"
  combiner = "OR"
  conditions {
    display_name = "Custom Role Changes Condition"
    condition_threshold {
      filter = "resource.type=iam_role AND protoPayload.methodName=(\"google.iam.admin.v1.CreateRole\" OR \"google.iam.admin.v1.DeleteRole\" OR \"google.iam.admin.v1.UpdateRole\")"
      duration = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
}

resource "google_logging_metric" "project_ownership_changes" {
  name = "project-ownership-changes"
  project = "aviato-game-fight-rvxirf"
  description = "Project ownership changes"
  filter = "resource.type=gcp_project AND protoPayload.methodName=SetIamPolicy AND protoPayload.request.policy.bindings:dataOwner"
  metric_descriptor {
    launch_stage = "BETA"
    name = "Project Ownership Changes"
    type = "GAUGE"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes_alert" {
  display_name = "Project Ownership Changes Alert"
  project = "aviato-game-fight-rvxirf"
  combiner = "OR"
  conditions {
    display_name = "Project Ownership Changes Condition"
    condition_threshold {
      filter = "resource.type=gcp_project AND protoPayload.methodName=SetIamPolicy AND protoPayload.request.policy.bindings:dataOwner"
      duration = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
}

resource "google_logging_metric" "sql_instance_config_changes" {
  name = "sql-instance-config-changes"
  project = "aviato-game-fight-rvxirf"
  description = "SQL instance configuration changes"
  filter = "resource.type=cloudsql_instance AND protoPayload.methodName=\"cloudsql.instances.update\""
  metric_descriptor {
    launch_stage = "BETA"
    name = "SQL Instance Configuration Changes"
    type = "GAUGE"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "sql_instance_config_changes_alert" {
  display_name = "SQL Instance Configuration Changes Alert"
  project = "aviato-game-fight-rvxirf"
  combiner = "OR"
  conditions {
    display_name = "SQL Instance Configuration Changes Condition"
    condition_threshold {
      filter = "resource.type=cloudsql_instance AND protoPayload.methodName=\"cloudsql.instances.update\""
      duration = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  name = "vpc-firewall-rule-changes"
  project = "aviato-game-fight-rvxirf"
  description = "VPC firewall rule changes"
  filter = "resource.type=gce_firewall_rule AND protoPayload.methodName=(\"compute.firewalls.insert\" OR \"compute.firewalls.patch\" OR \"compute.firewalls.delete\")"
  metric_descriptor {
    launch_stage = "BETA"
    name = "VPC Firewall Rule Changes"
    type = "GAUGE"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes_alert" {
  display_name = "VPC Firewall Rule Changes Alert"
  project = "aviato-game-fight-rvxirf"
  combiner = "OR"
  conditions {
    display_name = "VPC Firewall Rule Changes Condition"
    condition_threshold {
      filter = "resource.type=gce_firewall_rule AND protoPayload.methodName=(\"compute.firewalls.insert\" OR \"compute.firewalls.patch\" OR \"compute.firewalls.delete\")"
      duration = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
}

resource "google_logging_metric" "vpc_network_changes" {
  name = "vpc-network-changes"
  project = "aviato-game-fight-rvxirf"
  description = "VPC network changes"
  filter = "resource.type=gce_network AND protoPayload.methodName=(\"compute.networks.insert\" OR \"compute.networks.patch\" OR \"compute.networks.delete\")"
  metric_descriptor {
    launch_stage = "BETA"
    name = "VPC Network Changes"
    type = "GAUGE"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes_alert" {
  display_name = "VPC Network Changes Alert"
  project = "aviato-game-fight-rvxirf"
  combiner = "OR"
  conditions {
    display_name = "VPC Network Changes Condition"
    condition_threshold {
      filter = "resource.type=gce_network AND protoPayload.methodName=(\"compute.networks.insert\" OR \"compute.networks.patch\" OR \"compute.networks.delete\")"
      duration = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
}

resource "google_logging_metric" "vpc_network_route_changes" {
  name = "vpc-network-route-changes"
  project = "aviato-game-fight-rvxirf"
  description = "VPC network route changes"
  filter = "resource.type=gce_route AND protoPayload.methodName=(\"compute.routes.insert\" OR \"compute.routes.delete\")"
  metric_descriptor {
    launch_stage = "BETA"
    name = "VPC Network Route Changes"
    type = "GAUGE"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes_alert" {
  display_name = "VPC Network Route Changes Alert"
  project = "aviato-game-fight-rvxirf"
  combiner = "OR"
  conditions {
    display_name = "VPC Network Route Changes Condition"
    condition_threshold {
      filter = "resource.type=gce_route AND protoPayload.methodName=(\"compute.routes.insert\" OR \"compute.routes.delete\")"
      duration = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
}

resource "google_iam_service_account" "twitch_login" {
  account_id   = "twitch-login"
  display_name = "Twitch Login Service Account"
  project      = "aviato-game-fight-rvxirf"
}

resource "google_project_iam_member" "twitch_login_binding" {
  project = "aviato-game-fight-rvxirf"
  role    = "roles/viewer"
  member  = "serviceAccount:${google_iam_service_account.twitch_login.email}"
}

resource "google_iam_service_account" "appspot_service_account" {
  account_id   = "aviato-game-fight-rvxirf"
  display_name = "Appspot Service Account"
  project      = "aviato-game-fight-rvxirf"
}

resource "google_project_iam_member" "appspot_binding" {
  project = "aviato-game-fight-rvxirf"
  role    = "roles/viewer"
  member  = "serviceAccount:${google_iam_service_account.appspot_service_account.email}"
}

resource "google_iam_service_account" "compute_service_account" {
  account_id   = "compute-service-account"
  display_name = "Compute Service Account"
  project      = "aviato-game-fight-rvxirf"
}

resource "google_project_iam_member" "compute_binding" {
  project = "aviato-game-fight-rvxirf"
  role    = "roles/viewer"
  member  = "serviceAccount:${google_iam_service_account.compute_service_account.email}"
}

resource "google_iam_service_account" "firebase_adminsdk" {
  account_id   = "firebase-adminsdk-d21rv"
  display_name = "Firebase Adminsdk Service Account"
  project      = "aviato-game-fight-rvxirf"
}

resource "google_project_iam_member" "firebase_adminsdk_binding" {
  project = "aviato-game-fight-rvxirf"
  role    = "roles/viewer"
  member  = "serviceAccount:${google_iam_service_account.firebase_adminsdk.email}"
}
