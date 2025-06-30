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

resource "google_project_service_identity" "gcr_sa" {
  provider = google
  project  = var.project_id
  service  = "containerregistry.googleapis.com"
}

resource "google_project_service" "artifactregistry" {
  provider = google
  project                    = var.project_id
  service                    = "artifactregistry.googleapis.com"
  disable_on_destroy         = false
}

resource "google_project_service" "containeranalysis" {
  provider = google
  project                    = var.project_id
  service                    = "containeranalysis.googleapis.com"
  disable_on_destroy         = false

  depends_on = [google_project_service_identity.gcr_sa]
}

resource "google_project_iam_member" "container_analysis_access" {
  provider = google
  project = var.project_id
  role    = "roles/containeranalysis.occurrences.occurrencesagent"
  member  = "serviceAccount:${google_project_service_identity.gcr_sa.email}"
  depends_on = [google_project_service_identity.gcr_sa, google_project_service.containeranalysis]
}

resource "google_project_service" "cloudasset" {
  provider = google
  project                    = var.project_id
  service                    = "cloudasset.googleapis.com"
  disable_on_destroy         = false
}

resource "google_project_service" "dns" {
  provider = google
  project                    = var.project_id
  service                    = "dns.googleapis.com"
  disable_on_destroy         = false
}


resource "google_compute_network" "default" {
  provider = google
  name                    = "default"
  project                 = var.project_id
  delete_default_routes = true
}

resource "google_compute_firewall" "rdp" {
  provider = google
  project = var.project_id
  name    = "default-allow-rdp"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  source_ranges = var.rdp_ssh_allowed_cidrs
}

resource "google_compute_firewall" "ssh" {
  provider = google
  project = var.project_id
  name    = "default-allow-ssh"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = var.rdp_ssh_allowed_cidrs
}

resource "google_project_metadata" "oslogin" {
  provider = google
  project = var.project_id
  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_subnetwork" "default_subnets" {
  for_each     = toset(var.default_subnets)
  provider = google
  name         = "default"
  ip_cidr_range = "10.10.10.0/24"
  network      = "default"
  project      = var.project_id
  region       = each.key
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_logging_project_sink" "default" {
  name = "default-sink"
  project = var.project_id
  destination = "storage.googleapis.com/${var.log_export_bucket}"
  filter = "severity>=INFO"

  unique_writer_identity = true
}

resource "google_storage_bucket" "default" {
  name          = var.log_export_bucket
  project       = var.project_id
  location      = var.region
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "appspot_bucket_1" {
  name          = "${var.project_id}.appspot.com"
  project       = var.project_id
  location      = "australia-southeast1"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "appspot_bucket_2" {
  name          = "staging.${var.project_id}.appspot.com"
  project       = var.project_id
  location      = "australia-southeast1"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "generic_bucket" {
  name          = "${var.project_id}_bucket"
  project       = var.project_id
  location      = "US"
  uniform_bucket_level_access = true
}

resource "google_project_service" "logging" {
  provider = google
  project                    = var.project_id
  service                    = "logging.googleapis.com"
  disable_on_destroy         = false
}

resource "google_logging_metric" "audit_configuration_changes" {
  name   = "audit-configuration-changes"
  project = var.project_id
  description = "Log metric for Audit Configuration Changes"
  filter = "resource.type=audited_resource AND protoPayload.methodName=\"google.iam.admin.v1.GrantRole\" OR protoPayload.methodName=\"google.iam.admin.v1.RevokeRole\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "audit_configuration_changes" {
  display_name = "Alert for Audit Configuration Changes"
  project = var.project_id
  combiner   = "OR"
  conditions {
    display_name = "Condition for Audit Configuration Changes"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/audit-configuration-changes\" AND resource.project_id=\"${var.project_id}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
}

resource "google_logging_metric" "bucket_permission_changes" {
  name   = "bucket-permission-changes"
  project = var.project_id
  description = "Log metric for Cloud Storage Bucket IAM Permission Changes"
  filter = "resource.type=gcs_bucket AND protoPayload.methodName=\"storage.setIamPermissions\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes" {
  display_name = "Alert for Cloud Storage Bucket IAM Permission Changes"
  project = var.project_id
  combiner   = "OR"
  conditions {
    display_name = "Condition for Cloud Storage Bucket IAM Permission Changes"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/bucket-permission-changes\" AND resource.project_id=\"${var.project_id}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
}

resource "google_logging_metric" "custom_role_changes" {
  name   = "custom-role-changes"
  project = var.project_id
  description = "Log metric for Custom Role Changes"
  filter = "resource.type=iam_role AND protoPayload.methodName=\"google.iam.admin.v1.CreateRole\" OR protoPayload.methodName=\"google.iam.admin.v1.UpdateRole\" OR protoPayload.methodName=\"google.iam.admin.v1.DeleteRole\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes" {
  display_name = "Alert for Custom Role Changes"
  project = var.project_id
  combiner   = "OR"
  conditions {
    display_name = "Condition for Custom Role Changes"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/custom-role-changes\" AND resource.project_id=\"${var.project_id}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
}

resource "google_logging_metric" "project_ownership_changes" {
  name   = "project-ownership-changes"
  project = var.project_id
  description = "Log metric for Project Ownership Assignments/Changes"
  filter = "resource.type=project AND protoPayload.methodName=\"google.cloudresourcemanager.v1.SetIamPolicy\" AND protoPayload.request.policy.bindings.role=\"roles/owner\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes" {
  display_name = "Alert for Project Ownership Assignments/Changes"
  project = var.project_id
  combiner   = "OR"
  conditions {
    display_name = "Condition for Project Ownership Assignments/Changes"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/project-ownership-changes\" AND resource.project_id=\"${var.project_id}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
}

resource "google_logging_metric" "sql_instance_configuration_changes" {
  name   = "sql-instance-configuration-changes"
  project = var.project_id
  description = "Log metric for SQL Instance Configuration Changes"
  filter = "resource.type=cloudsql_instance AND protoPayload.methodName=\"cloudsql.instances.update\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "sql_instance_configuration_changes" {
  display_name = "Alert for SQL Instance Configuration Changes"
  project = var.project_id
  combiner   = "OR"
  conditions {
    display_name = "Condition for SQL Instance Configuration Changes"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/sql-instance-configuration-changes\" AND resource.project_id=\"${var.project_id}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  name   = "vpc-firewall-rule-changes"
  project = var.project_id
  description = "Log metric for VPC Network Firewall Rule Changes"
  filter = "resource.type=gce_firewall_rule AND protoPayload.methodName=\"compute.firewalls.insert\" OR protoPayload.methodName=\"compute.firewalls.delete\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes" {
  display_name = "Alert for VPC Network Firewall Rule Changes"
  project = var.project_id
  combiner   = "OR"
  conditions {
    display_name = "Condition for VPC Network Firewall Rule Changes"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/vpc-firewall-rule-changes\" AND resource.project_id=\"${var.project_id}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
}

resource "google_logging_metric" "vpc_network_changes" {
  name   = "vpc-network-changes"
  project = var.project_id
  description = "Log metric for VPC Network Changes"
  filter = "resource.type=gce_network AND protoPayload.methodName=\"compute.networks.insert\" OR protoPayload.methodName=\"compute.networks.delete\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes" {
  display_name = "Alert for VPC Network Changes"
  project = var.project_id
  combiner   = "OR"
  conditions {
    display_name = "Condition for VPC Network Changes"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/vpc-network-changes\" AND resource.project_id=\"${var.project_id}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
}

resource "google_logging_metric" "vpc_network_route_changes" {
  name   = "vpc-network-route-changes"
  project = var.project_id
  description = "Log metric for VPC Network Route Changes"
  filter = "resource.type=gce_route AND protoPayload.methodName=\"compute.routes.insert\" OR protoPayload.methodName=\"compute.routes.delete\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes" {
  display_name = "Alert for VPC Network Route Changes"
  project = var.project_id
  combiner   = "OR"
  conditions {
    display_name = "Condition for VPC Network Route Changes"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/vpc-network-route-changes\" AND resource.project_id=\"${var.project_id}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
}

resource "google_project_service" "cloudresourcemanager" {
  provider = google
  project                    = var.project_id
  service                    = "cloudresourcemanager.googleapis.com"
  disable_on_destroy         = false
}
