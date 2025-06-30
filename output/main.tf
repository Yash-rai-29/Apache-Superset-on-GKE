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

resource "google_project_service_identity" "gcp_sa_ai_si" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  service = "artifactregistry.googleapis.com"
}

resource "google_project_iam_member" "gcp_sa_ai" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  role = "roles/artifactregistry.serviceAgent"
  member = "serviceAccount:${google_project_service_identity.gcp_sa_ai_si.email}"
}

resource "google_project_service" "artifactanalysis" {
  provider = google
  project            = "aviato-game-fight-rvxirf"
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
  depends_on = [
    google_project_iam_member.gcp_sa_ai
  ]
}

resource "google_storage_bucket" "default" {
  provider = google
  name          = "aviato-game-fight-rvxirf.appspot.com"
  location      = "AUSTRALIA-SOUTHEAST1"
  force_destroy = false
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "bucket_us" {
  provider = google
  name          = "aviato-game-fight-rvxirf_bucket"
  location      = "US"
  force_destroy = false
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "bucket_staging" {
  provider = google
  name          = "staging.aviato-game-fight-rvxirf.appspot.com"
  location      = "AUSTRALIA-SOUTHEAST1"
  force_destroy = false
  uniform_bucket_level_access = true
}

resource "google_compute_firewall" "rdp" {
  provider = google
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
  provider = google
  name    = "default-allow-ssh"
  network = "default"
  project = "aviato-game-fight-rvxirf"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

resource "google_compute_network" "default" {
  provider = google
  name                    = "default"
  project                 = "aviato-game-fight-rvxirf"
  auto_create_subnetworks = "false"
  delete_default_routes_on_destroy = "true"
}

resource "google_compute_network" "default_dns" {
  provider = google
  name                    = "default"
  project                 = "aviato-game-fight-rvxirf"
  delete_default_routes_on_destroy = "true"
  enable_logging = true
}

resource "google_project_metadata" "metadata" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_subnetwork" "subnetwork_us_east1" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "us-east1"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_asia_east1" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "asia-east1"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_europe_west6" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "europe-west6"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_europe_central2" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "europe-central2"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_asia_southeast2" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "asia-southeast2"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_australia_southeast2" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "australia-southeast2"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_asia_northeast1" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "asia-northeast1"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_me_central2" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "me-central2"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_asia_southeast1" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "asia-southeast1"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_asia_south2" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "asia-south2"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_asia_south1" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "asia-south1"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_asia_northeast3" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "asia-northeast3"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_us_east5" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "us-east5"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_us_east4" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "us-east4"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_northamerica_northeast1" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "northamerica-northeast1"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_southamerica_west1" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "southamerica-west1"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_us_west3" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "us-west3"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_us_west4" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "us-west4"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_northamerica_northeast2" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "northamerica-northeast2"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_australia_southeast1" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "australia-southeast1"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_europe_west1" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "europe-west1"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_africa_south1" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "africa-south1"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_asia_east2" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "asia-east2"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_europe_north2" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "europe-north2"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_europe_west10" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "europe-west10"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_northamerica_south1" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "northamerica-south1"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_europe_west12" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "europe-west12"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_europe_west8" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "europe-west8"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_europe_southwest1" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "europe-southwest1"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_us_central1" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "us-central1"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_me_west1" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "me-west1"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_europe_west4" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "europe-west4"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_us_west2" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "us-west2"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_europe_west3" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "europe-west3"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "subnetwork_us_south1" {
  provider = google
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = "us-south1"
  project                  = "aviato-game-fight-rvxirf"
  enable_flow_logs         = true
}

resource "google_project_service" "cloudasset_googleapis_com" {
  provider = google
  project            = "aviato-game-fight-rvxirf"
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_logging_metric" "audit_configuration_changes" {
  provider = google
  name        = "audit-configuration-changes"
  project = "aviato-game-fight-rvxirf"
  description = "Records the number of audit configuration changes."
  filter      = "protoPayload.methodName=\"SetIamPolicy\" OR protoPayload.methodName=\"UpdateService\""

  metric_descriptor {
    launch_stage = "BETA"
    name         = "logging.googleapis.com/audit_configuration_changes"
    type         = "counter"
    unit         = "1"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "alert_audit_configuration_changes" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  display_name = "Audit Configuration Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "Audit Configuration Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/audit_configuration_changes\" resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      duration        = "60s"
      threshold_value = "0"
      trigger {
        count = 1
      }
    }
  }
}

resource "google_logging_metric" "gcs_iam_permission_changes" {
  provider = google
  name        = "gcs-iam-permission-changes"
  project = "aviato-game-fight-rvxirf"
  description = "Records the number of Cloud Storage IAM permission changes."
  filter      = "resource.type=\"gcs_bucket\" AND protoPayload.methodName=\"storage.setIamPermissions\""

  metric_descriptor {
    launch_stage = "BETA"
    name         = "logging.googleapis.com/gcs_iam_permission_changes"
    type         = "counter"
    unit         = "1"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "alert_gcs_iam_permission_changes" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  display_name = "Cloud Storage IAM Permission Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "Cloud Storage IAM Permission Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/gcs_iam_permission_changes\" resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      duration        = "60s"
      threshold_value = "0"
      trigger {
        count = 1
      }
    }
  }
}

resource "google_logging_metric" "custom_role_changes" {
  provider = google
  name        = "custom-role-changes"
  project = "aviato-game-fight-rvxirf"
  description = "Records the number of custom role changes."
  filter      = "protoPayload.methodName=\"google.iam.admin.v1.CreateRole\" OR protoPayload.methodName=\"google.iam.admin.v1.DeleteRole\" OR protoPayload.methodName=\"google.iam.admin.v1.UpdateRole\""

  metric_descriptor {
    launch_stage = "BETA"
    name         = "logging.googleapis.com/custom_role_changes"
    type         = "counter"
    unit         = "1"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "alert_custom_role_changes" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  display_name = "Custom Role Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "Custom Role Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/custom_role_changes\" resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      duration        = "60s"
      threshold_value = "0"
      trigger {
        count = 1
      }
    }
  }
}

resource "google_logging_metric" "project_ownership_changes" {
  provider = google
  name        = "project-ownership-changes"
  project = "aviato-game-fight-rvxirf"
  description = "Records the number of project ownership changes."
  filter      = "protoPayload.serviceName=\"cloudresourcemanager.googleapis.com\" AND protoPayload.methodName=\"SetIamPolicy\" AND resource.type=\"project\" AND protoPayload.request.policy.bindings:data.members=\"*\":"

  metric_descriptor {
    launch_stage = "BETA"
    name         = "logging.googleapis.com/project_ownership_changes"
    type         = "counter"
    unit         = "1"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "alert_project_ownership_changes" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  display_name = "Project Ownership Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "Project Ownership Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/project_ownership_changes\" resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      duration        = "60s"
      threshold_value = "0"
      trigger {
        count = 1
      }
    }
  }
}

resource "google_logging_metric" "sql_instance_configuration_changes" {
  provider = google
  name        = "sql-instance-configuration-changes"
  project = "aviato-game-fight-rvxirf"
  description = "Records the number of SQL instance configuration changes."
  filter      = "resource.type=\"cloudsql_database\" AND protoPayload.methodName=\"cloudsql.instances.update\""

  metric_descriptor {
    launch_stage = "BETA"
    name         = "logging.googleapis.com/sql_instance_configuration_changes"
    type         = "counter"
    unit         = "1"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "alert_sql_instance_configuration_changes" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  display_name = "SQL Instance Configuration Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "SQL Instance Configuration Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/sql_instance_configuration_changes\" resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      duration        = "60s"
      threshold_value = "0"
      trigger {
        count = 1
      }
    }
  }
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  provider = google
  name        = "vpc-firewall-rule-changes"
  project = "aviato-game-fight-rvxirf"
  description = "Records the number of VPC firewall rule changes."
  filter      = "resource.type=\"gcp_firewall_rule\" AND protoPayload.methodName=\"compute.firewalls.insert\" OR protoPayload.methodName=\"compute.firewalls.patch\""

  metric_descriptor {
    launch_stage = "BETA"
    name         = "logging.googleapis.com/vpc_firewall_rule_changes"
    type         = "counter"
    unit         = "1"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "alert_vpc_firewall_rule_changes" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  display_name = "VPC Firewall Rule Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "VPC Firewall Rule Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/vpc_firewall_rule_changes\" resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      duration        = "60s"
      threshold_value = "0"
      trigger {
        count = 1
      }
    }
  }
}

resource "google_logging_metric" "vpc_network_changes" {
  provider = google
  name        = "vpc-network-changes"
  project = "aviato-game-fight-rvxirf"
  description = "Records the number of VPC network changes."
  filter      = "resource.type=\"gcp_network\" AND protoPayload.methodName=\"compute.networks.insert\" OR protoPayload.methodName=\"compute.networks.patch\""

  metric_descriptor {
    launch_stage = "BETA"
    name         = "logging.googleapis.com/vpc_network_changes"
    type         = "counter"
    unit         = "1"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "alert_vpc_network_changes" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  display_name = "VPC Network Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "VPC Network Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/vpc_network_changes\" resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      duration        = "60s"
      threshold_value = "0"
      trigger {
        count = 1
      }
    }
  }
}

resource "google_logging_metric" "vpc_network_route_changes" {
  provider = google
  name        = "vpc-network-route-changes"
  project = "aviato-game-fight-rvxirf"
  description = "Records the number of VPC network route changes."
  filter      = "resource.type=\"gcp_route\" AND protoPayload.methodName=\"compute.routes.insert\" OR protoPayload.methodName=\"compute.routes.delete\""

  metric_descriptor {
    launch_stage = "BETA"
    name         = "logging.googleapis.com/vpc_network_route_changes"
    type         = "counter"
    unit         = "1"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "alert_vpc_network_route_changes" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  display_name = "VPC Network Route Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "VPC Network Route Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/vpc_network_route_changes\" resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      duration        = "60s"
      threshold_value = "0"
      trigger {
        count = 1
      }
    }
  }
}

resource "google_logging_sink" "sink" {
  provider = google
  name = "aviato-game-fight-rvxirf-sink"
  project = "aviato-game-fight-rvxirf"
  destination = "storage.googleapis.com/${google_storage_bucket.default.name}"
  filter = "NOT logName:(\"projects/${"aviato-game-fight-rvxirf"}/logs/cloudaudit.googleapis.com%2Fdata_access\")"
}
