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
  region  = var.region
}

resource "google_project_service_identity" "gcp_sa_artifact_registry" {
  provider = google
  project  = var.project_id
  service  = "artifactregistry.googleapis.com"
}

resource "google_project_service" "artifact_registry" {
  provider = google
  project            = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "container_analysis" {
  provider = google
  project            = var.project_id
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false

  depends_on = [google_project_service_identity.gcp_sa_artifact_registry]
}

resource "google_storage_bucket_iam_binding" "uniform_bucket_level_access" {
  provider = google
  bucket  = var.bucket_names[0]
  role    = "roles/storage.objectViewer"
  members = [
    "allUsers",
  ]
}

resource "google_storage_bucket_iam_binding" "uniform_bucket_level_access2" {
  provider = google
  bucket  = var.bucket_names[1]
  role    = "roles/storage.objectViewer"
  members = [
    "allUsers",
  ]
}

resource "google_storage_bucket_iam_binding" "uniform_bucket_level_access3" {
  provider = google
  bucket  = var.bucket_names[2]
  role    = "roles/storage.objectViewer"
  members = [
    "allUsers",
  ]
}

resource "google_storage_bucket" "default_acl" {
  provider = google
  name          = var.bucket_names[0]
  location      = "AUSTRALIA-SOUTHEAST1"
  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "default_acl2" {
  provider = google
  name          = var.bucket_names[1]
  location      = "US"
  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "default_acl3" {
  provider = google
  name          = var.bucket_names[2]
  location      = "AUSTRALIA-SOUTHEAST1"
  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_compute_network" "default" {
  provider = google
  name                    = "default"
  project                 = var.project_id
  auto_create_subnetworks = false
  delete_default_routes = true
}

resource "google_compute_firewall" "default_allow_ssh" {
  provider = google
  name    = "default-allow-ssh"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["10.0.0.0/8"]
}

resource "google_compute_firewall" "default_allow_rdp" {
  provider = google
  name    = "default-allow-rdp"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["10.0.0.0/8"]
}

resource "google_project_metadata" "default" {
  provider = google
  project = var.project_id

  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_subnetwork" "default_subnet" {
  provider = google
  for_each = toset(var.default_network_regions)
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = each.value
  project                  = var.project_id
  private_ip_google_access = true
  flow_logs                = true
}

resource "google_logging_project_sink" "default" {
  provider = google
  name = "all-logs-to-bucket"
  description = "Sinks all logs to a bucket"
  destination = "storage.googleapis.com/${var.bucket_names[0]}"
  filter = "NOT logName:(\"projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Fdata_access\")"
}

resource "google_monitoring_alert_policy" "audit_config_changes" {
  provider = google
  display_name = "Audit Configuration Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "Audit Configuration Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/log_entry_count\" AND resource.type=\"gcp_project\" AND metric.label.\"log_filter\"=\"${var.project_id}\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
}

resource "google_logging_metric" "audit_config_changes_metric" {
  provider = google
  name = "audit-config-changes-metric"
  description = "Counts audit configuration changes"
  filter = "resource.type=gcp_project AND protoPayload.methodName:(\"SetIamPolicy\" OR \"UpdateBucket\" OR \"DeleteBucket\")"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes" {
  provider = google
  display_name = "Bucket Permission Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "Bucket Permission Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/log_entry_count\" AND resource.type=\"gcp_project\" AND metric.label.\"log_filter\"=\"${var.project_id}\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
}

resource "google_logging_metric" "bucket_permission_changes_metric" {
  provider = google
  name = "bucket-permission-changes-metric"
  description = "Counts bucket permission changes"
  filter = "resource.type=gcp_bucket AND protoPayload.methodName:storage.setIamPermissions"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes" {
  provider = google
  display_name = "Custom Role Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "Custom Role Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/log_entry_count\" AND resource.type=\"gcp_project\" AND metric.label.\"log_filter\"=\"${var.project_id}\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
}

resource "google_logging_metric" "custom_role_changes_metric" {
  provider = google
  name = "custom-role-changes-metric"
  description = "Counts custom role changes"
  filter = "resource.type=gcp_project AND protoPayload.methodName:(\"google.iam.admin.v1.CreateRole\" OR \"google.iam.admin.v1.DeleteRole\" OR \"google.iam.admin.v1.UpdateRole\")"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes" {
  provider = google
  display_name = "Project Ownership Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "Project Ownership Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/log_entry_count\" AND resource.type=\"gcp_project\" AND metric.label.\"log_filter\"=\"${var.project_id}\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
}

resource "google_logging_metric" "project_ownership_changes_metric" {
  provider = google
  name = "project-ownership-changes-metric"
  description = "Counts project ownership changes"
  filter = "resource.type=gcp_project AND protoPayload.methodName:resourcemanager.projects.setIamPolicy AND protoPayload.request.policy.bindings:\"roles/owner\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "sql_instance_configuration_changes" {
  provider = google
  display_name = "SQL Instance Configuration Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "SQL Instance Configuration Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/log_entry_count\" AND resource.type=\"gcp_project\" AND metric.label.\"log_filter\"=\"${var.project_id}\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
}

resource "google_logging_metric" "sql_instance_configuration_changes_metric" {
  provider = google
  name = "sql-instance-configuration-changes-metric"
  description = "Counts SQL instance configuration changes"
  filter = "resource.type=cloudsql_instance AND protoPayload.methodName:cloudsql.instances.update"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes" {
  provider = google
  display_name = "VPC Firewall Rule Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "VPC Firewall Rule Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/log_entry_count\" AND resource.type=\"gcp_project\" AND metric.label.\"log_filter\"=\"${var.project_id}\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
}

resource "google_logging_metric" "vpc_firewall_rule_changes_metric" {
  provider = google
  name = "vpc-firewall-rule-changes-metric"
  description = "Counts VPC firewall rule changes"
  filter = "resource.type=gcp_firewall_rule AND protoPayload.methodName:compute.firewalls.insert"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes" {
  provider = google
  display_name = "VPC Network Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "VPC Network Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/log_entry_count\" AND resource.type=\"gcp_project\" AND metric.label.\"log_filter\"=\"${var.project_id}\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
}

resource "google_logging_metric" "vpc_network_changes_metric" {
  provider = google
  name = "vpc-network-changes-metric"
  description = "Counts VPC network changes"
  filter = "resource.type=gcp_network AND protoPayload.methodName:compute.networks.insert"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes" {
  provider = google
  display_name = "VPC Network Route Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "VPC Network Route Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/log_entry_count\" AND resource.type=\"gcp_project\" AND metric.label.\"log_filter\"=\"${var.project_id}\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
}

resource "google_logging_metric" "vpc_network_route_changes_metric" {
  provider = google
  name = "vpc-network-route-changes-metric"
  description = "Counts VPC network route changes"
  filter = "resource.type=gcp_route AND protoPayload.methodName:compute.routes.insert"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_project_iam_member" "no_administrative_privileges1" {
  provider = google
  project = var.project_id
  role = "roles/viewer"
  member = "serviceAccount:${var.service_account_names[0]}"
}

resource "google_project_iam_member" "no_administrative_privileges2" {
  provider = google
  project = var.project_id
  role = "roles/viewer"
  member = "serviceAccount:${var.service_account_names[1]}"
}

resource "google_project_iam_member" "no_administrative_privileges3" {
  provider = google
  project = var.project_id
  role = "roles/viewer"
  member = "serviceAccount:${var.service_account_names[2]}"
}

resource "google_project_iam_member" "no_administrative_privileges4" {
  provider = google
  project = var.project_id
  role = "roles/viewer"
  member = "serviceAccount:${var.service_account_names[3]}"
}

resource "google_project_iam_binding" "enforce_separation_of_duties" {
  provider = google
  project = var.project_id
  role    = "roles/viewer"
  members = [var.iam_member]
}

resource "google_service_account_key" "user_managed_key1" {
  provider = google
  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.service_account_names[0]}"
  key_algorithm      = "KEY_ALG_RSA_2048"
  lifecycle {
    ignore_changes = [
      public_key,
      private_key,
      name
    ]
  }
}

resource "google_service_account_key" "user_managed_key2" {
  provider = google
  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.service_account_names[2]}"
  key_algorithm      = "KEY_ALG_RSA_2048"
  lifecycle {
    ignore_changes = [
      public_key,
      private_key,
      name
    ]
  }
}

resource "google_service_account" "unused_service_accounts1" {
  provider = google
  account_id   = "aviato-game-fight-rvxirf"
  disabled     = true
  display_name = "Aviato Game Fight RVXIRF"
}

resource "google_service_account" "unused_service_accounts2" {
  provider = google
  account_id   = "firebase-adminsdk-d21rv"
  disabled     = true
  display_name = "Firebase Adminsdk D21rv"
}

resource "google_project_service" "cloud_asset" {
  provider = google
  project = var.project_id
  service = "cloudasset.googleapis.com"
  disable_on_destroy = false
}
