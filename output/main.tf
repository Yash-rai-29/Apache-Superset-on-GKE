terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.24.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.location
}

resource "google_project_service" "containeranalysis" {
  project = var.project_id
  service = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_storage_bucket" "default_bucket_ubla" {
  name          = "${var.project_id}.appspot.com"
  location      = "AUSTRALIA-SOUTHEAST1"
  project       = var.project_id
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "bucket_us_ubla" {
  name          = "${var.project_id}_bucket"
  location      = "US"
  project       = var.project_id
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "staging_bucket_ubla" {
  name          = "staging.${var.project_id}.appspot.com"
  location      = "AUSTRALIA-SOUTHEAST1"
  project       = var.project_id
  uniform_bucket_level_access = true
}

resource "google_compute_firewall" "default_allow_ssh" {
  name    = "default-allow-ssh"
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.trusted_ip_ranges
}

resource "google_compute_firewall" "default_allow_rdp" {
  name    = "default-allow-rdp"
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = var.trusted_ip_ranges
}

resource "google_compute_network" "default" {
  name                    = "default"
  project                 = var.project_id
  delete_default_routes = true
  enable_ula_internal_ipv6 = false
  auto_create_subnetworks = false
  description             = "Default network"
  routing_mode            = "GLOBAL"
  dns_config {
    enable_logging = true
  }
}

resource "google_project_metadata" "project_metadata" {
  project = var.project_id

  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_subnet" "default_subnet" {
  for_each = toset(var.default_regions)
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  project                  = var.project_id
  region                   = each.value
  private_ip_google_access = true
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_logging_project_sink" "sink" {
  name = "aviato-game-fight-rvxirf"
  project                 = var.project_id
  description = "exports all the log entries"
  destination = "storage.googleapis.com/${var.project_id}-logs-bucket" # Replace with your bucket
  filter      = "NOT logName:('projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity' OR 'projects/${var.project_id}/logs/system.slice')"
}

resource "google_storage_bucket" "log_bucket" {
  name          = "${var.project_id}-logs-bucket"
  location      = var.location
  project       = var.project_id
  force_destroy = true
}

resource "google_logging_metric" "audit_config_changes" {
  name        = "audit-config-changes"
  project     = var.project_id
  description = "Metric for audit configuration changes"
  filter      = "resource.type=audited_resource AND severity>=WARNING"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "audit_config_changes_alert" {
  display_name = "Audit Configuration Changes Alert"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/audit-config-changes\" AND resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "bucket_permission_changes" {
  name        = "bucket-permission-changes"
  project     = var.project_id
  description = "Metric for cloud storage bucket IAM permission changes"
  filter      = "resource.type=\"gcs_bucket\" AND protoPayload.methodName:SetIamPolicy"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes_alert" {
  display_name = "Cloud Storage Bucket IAM Permission Changes Alert"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/bucket-permission-changes\" AND resource.type=\"gcs_bucket\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "custom_role_changes" {
  name        = "custom-role-changes"
  project     = var.project_id
  description = "Metric for custom role changes"
  filter      = "resource.type=iam_role OR resource.type=gcp_iam_role"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes_alert" {
  display_name = "Custom Role Changes Alert"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/custom-role-changes\" AND resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "project_ownership_changes" {
  name        = "project-ownership-changes"
  project     = var.project_id
  description = "Metric for project ownership assignments/changes"
  filter      = "resource.type=gcp_project AND protoPayload.methodName=google.cloudresourcemanager.projects.setIamPolicy"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes_alert" {
  display_name = "Project Ownership Changes Alert"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/project-ownership-changes\" AND resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "sql_instance_config_changes" {
  name        = "sql-instance-config-changes"
  project     = var.project_id
  description = "Metric for SQL instance configuration changes"
  filter      = "resource.type=cloudsql_instance AND protoPayload.methodName=cloudsql.instances.update AND severity=NOTICE"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "sql_instance_config_changes_alert" {
  display_name = "SQL Instance Configuration Changes Alert"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/sql-instance-config-changes\" AND resource.type=\"cloudsql_instance\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  name        = "vpc-firewall-rule-changes"
  project     = var.project_id
  description = "Metric for VPC network firewall rule changes"
  filter      = "resource.type=gcp_firewall_rule AND (protoPayload.methodName=compute.firewalls.insert OR protoPayload.methodName=compute.firewalls.patch OR protoPayload.methodName=compute.firewalls.delete)"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes_alert" {
  display_name = "VPC Network Firewall Rule Changes Alert"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-firewall-rule-changes\" AND resource.type=\"gcp_firewall_rule\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_network_changes" {
  name        = "vpc-network-changes"
  project     = var.project_id
  description = "Metric for VPC network changes"
  filter      = "resource.type=gcp_network AND (protoPayload.methodName=compute.networks.insert OR protoPayload.methodName=compute.networks.patch OR protoPayload.methodName=compute.networks.delete)"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes_alert" {
  display_name = "VPC Network Changes Alert"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-changes\" AND resource.type=\"gcp_network\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_network_route_changes" {
  name        = "vpc-network-route-changes"
  project     = var.project_id
  description = "Metric for VPC network route changes"
  filter      = "resource.type=gcp_route AND (protoPayload.methodName=compute.routes.insert OR protoPayload.methodName=compute.routes.patch OR protoPayload.methodName=compute.routes.delete)"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes_alert" {
  display_name = "VPC Network Route Changes Alert"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-route-changes\" AND resource.type=\"gcp_route\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_project_iam_binding" "twitch_login_iam_binding" {
  project = var.project_id
  role    = "roles/viewer" # Replace with less permissive role

  members = [
    "serviceAccount:twitch-login@${var.project_id}.iam.gserviceaccount.com",
  ]
}

resource "google_project_iam_binding" "appspot_sa_iam_binding" {
  project = var.project_id
  role    = "roles/viewer" # Replace with less permissive role

  members = [
    "serviceAccount:${var.project_id}@appspot.gserviceaccount.com",
  ]
}

resource "google_project_iam_binding" "compute_sa_iam_binding" {
  project = var.project_id
  role    = "roles/viewer" # Replace with less permissive role

  members = [
    "serviceAccount:30647320905-compute@developer.gserviceaccount.com",
  ]
}

resource "google_project_service" "cloudasset" {
  project = var.project_id
  service = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

data "google_iam_policy" "service_account_no_admin" {
  binding {
    role = "roles/viewer"

    members = [
      "serviceAccount:firebase-adminsdk-d21rv@${var.project_id}.iam.gserviceaccount.com",
    ]
  }
}

resource "google_project_iam_policy" "service_account_policy" {
  project = var.project_id
  policy_data = data.google_iam_policy.service_account_no_admin.policy_data
}

resource "google_service_account_key" "rotate_twitch_login_key" {
  service_account_id = "twitch-login@${var.project_id}.iam.gserviceaccount.com"
  key_algorithm      = "KEY_ALG_RSA_2048"  
}

resource "google_service_account_key" "rotate_compute_sa_key" {
  service_account_id = "30647320905-compute@developer.gserviceaccount.com"
  key_algorithm      = "KEY_ALG_RSA_2048"
}

resource "google_service_account" "aviato_game_fight_rvxirf" {
  account_id   = "aviato-game-fight-rvxirf"
  disabled     = true
}

resource "google_service_account" "firebase_adminsdk_d21rv" {
  account_id   = "firebase-adminsdk-d21rv"
  disabled     = true
}
