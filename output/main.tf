terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.68.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
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

resource "google_project_iam_member" "artifactregistry" {
  provider = google
  project = var.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_project_service_identity.artifactregistry.email}"
}

resource "google_project_iam_member" "containeranalysis" {
  provider = google
  project = var.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_project_service_identity.containeranalysis.email}"
}

resource "google_project_service" "artifactregistry" {
  provider = google
  project = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "containeranalysis" {
  provider = google
  project = var.project_id
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudasset" {
  provider = google
  project            = var.project_id
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "apikeys" {
  provider = google
  project            = var.project_id
  service            = "apikeys.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_project_metadata" "oslogin" {
  project = var.project_id
  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_network" "default" {
  name                    = "default"
  project                 = var.project_id
  delete_default_routes = true
}

resource "google_compute_network" "default_delete" {
  name                    = "default"
  project                 = var.project_id
  depends_on = [google_compute_network.default]
  lifecycle {
    prevent_destroy = false
  }
}

resource "google_compute_firewall" "rdp" {
  name    = "default-allow-rdp"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

resource "google_compute_firewall" "ssh" {
  name    = "default-allow-ssh"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

resource "google_compute_network" "default_dns_logging" {
  name                    = "default"
  project                 = var.project_id
  enable_dns_logging = true
}

resource "google_logging_project_sink" "default_sink" {
  name        = "all-logs"
  project     = var.project_id
  destination = "storage.googleapis.com/${var.project_id}-logging-bucket"
  filter      = "NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Fdata_access"
}

resource "google_storage_bucket" "logging_bucket" {
  name                        = "${var.project_id}-logging-bucket"
  project                     = var.project_id
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_logging_metric" "audit_config_changes" {
  name        = "audit-config-changes"
  project     = var.project_id
  description = "Metric for audit configuration changes"
  filter      = "resource.type=audited_resource AND protoPayload.methodName=\"google.iam.admin.v1.CreateServiceAccount\" OR protoPayload.methodName=\"google.iam.admin.v1.DeleteServiceAccount\" OR protoPayload.methodName=\"google.iam.admin.v1.SetIamPolicy\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "audit_config_changes_alert" {
  display_name = "Alert for Audit Configuration Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Condition for Audit Configuration Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/audit-config-changes\" AND resource.type = \"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "bucket_permission_changes" {
  name        = "bucket-permission-changes"
  project     = var.project_id
  description = "Metric for Cloud Storage IAM permission changes"
  filter      = "resource.type=gcs_bucket AND protoPayload.methodName=\"storage.setIamPermissions\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes_alert" {
  display_name = "Alert for Cloud Storage IAM Permission Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Condition for Cloud Storage IAM Permission Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/bucket-permission-changes\" AND resource.type = \"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "custom_role_changes" {
  name        = "custom-role-changes"
  project     = var.project_id
  description = "Metric for custom role changes"
  filter      = "resource.type=iam_role AND protoPayload.methodName=\"google.iam.admin.v1.CreateRole\" OR protoPayload.methodName=\"google.iam.admin.v1.DeleteRole\" OR protoPayload.methodName=\"google.iam.admin.v1.UpdateRole\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes_alert" {
  display_name = "Alert for Custom Role Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Condition for Custom Role Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/custom-role-changes\" AND resource.type = \"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "project_ownership_changes" {
  name        = "project-ownership-changes"
  project     = var.project_id
  description = "Metric for Project Ownership Assignments/Changes"
  filter      = "resource.type=project AND protoPayload.methodName=\"SetIamPolicy\" AND protoPayload.request.policy.bindings.role=\"roles/owner\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes_alert" {
  display_name = "Alert for Project Ownership Assignments/Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Condition for Project Ownership Assignments/Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/project-ownership-changes\" AND resource.type = \"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "sql_instance_config_changes" {
  name        = "sql-instance-config-changes"
  project     = var.project_id
  description = "Metric for SQL Instance Configuration Changes"
  filter      = "resource.type=cloudsql_database AND protoPayload.methodName=\"cloudsql.instances.update\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "sql_instance_config_changes_alert" {
  display_name = "Alert for SQL Instance Configuration Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Condition for SQL Instance Configuration Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/sql-instance-config-changes\" AND resource.type = \"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  name        = "vpc-firewall-rule-changes"
  project     = var.project_id
  description = "Metric for VPC Network Firewall Rule Changes"
  filter      = "resource.type=gce_firewall_rule AND protoPayload.methodName=\"compute.firewalls.insert\" OR protoPayload.methodName=\"compute.firewalls.delete\" OR protoPayload.methodName=\"compute.firewalls.patch\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes_alert" {
  display_name = "Alert for VPC Network Firewall Rule Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Condition for VPC Network Firewall Rule Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-firewall-rule-changes\" AND resource.type = \"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_network_changes" {
  name        = "vpc-network-changes"
  project     = var.project_id
  description = "Metric for VPC Network Changes"
  filter      = "resource.type=gce_network AND protoPayload.methodName=\"compute.networks.insert\" OR protoPayload.methodName=\"compute.networks.delete\" OR protoPayload.methodName=\"compute.networks.patch\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes_alert" {
  display_name = "Alert for VPC Network Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Condition for VPC Network Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-changes\" AND resource.type = \"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_network_route_changes" {
  name        = "vpc-network-route-changes"
  project     = var.project_id
  description = "Metric for VPC Network Route Changes"
  filter      = "resource.type=gce_route AND protoPayload.methodName=\"compute.routes.insert\" OR protoPayload.methodName=\"compute.routes.delete\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes_alert" {
  display_name = "Alert for VPC Network Route Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Condition for VPC Network Route Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-route-changes\" AND resource.type = \"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  notification_channels = []
}

resource "google_container_registry" "gcr" {
  project  = var.project_id
  location = "us"
}

resource "google_project_iam_binding" "no_service_account_user" {
  project = var.project_id
  role = "roles/iam.serviceAccountUser"
  members = []
}

resource "google_project_iam_binding" "no_service_account_token_creator" {
  project = var.project_id
  role = "roles/iam.serviceAccountTokenCreator"
  members = []
}

resource "google_project_iam_custom_role" "separation_of_duties" {
  project     = var.project_id
  role_id     = "separationOfDutiesRole"
  title       = "Separation of Duties Role"
  description = "Custom role to enforce separation of duties"
  permissions = [
    "compute.instances.get",
    "compute.instances.list"
  ]
}

resource "google_project_iam_audit_config" "audit_config" {
  project = var.project_id
  service = "allServices"

  audit_log_config {
    log_type = "ADMIN_READ"
  }

  audit_log_config {
    log_type = "DATA_READ"
  }

  audit_log_config {
    log_type = "DATA_WRITE"
  }
}

resource "google_compute_subnetwork" "default_subnetworks" {
  for_each = toset(var.regions)

  name                     = "default"
  ip_cidr_range            = "10.0.0.0/20"
  network                  = "default"
  project                  = var.project_id
  region                   = each.value
  private_ip_google_access = true
  flow_logs = true
}

resource "google_storage_bucket" "buckets" {
  for_each = toset(var.bucket_names)
  name               = each.value
  project            = var.project_id
  location           = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}
