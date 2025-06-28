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
  region  = var.region
}

resource "google_project_iam_member" "project" {
  project = var.project_id
  role    = "roles/owner"
  member  = "user:example@example.com"
}

resource "google_compute_network" "default" {
  name                    = "default"
  project                 = var.project_id
  auto_create_subnetworks = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_firewall" "rdp" {
  name    = "default-allow-rdp"
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["10.10.0.0/16"]
}

resource "google_compute_firewall" "ssh" {
  name    = "default-allow-ssh"
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["10.10.0.0/16"]
}

resource "google_compute_subnetwork" "default" {
  for_each = toset(var.default_subnets)
  name                     = "default"
  project                  = var.project_id
  region                   = each.value
  network                  = "default"
  ip_cidr_range            = "10.10.0.0/20"
  private_ip_google_access = true
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_project_service_identity" "gcr_service_account" {
  provider = google
  project  = var.project_id
  service  = "containerregistry.googleapis.com"
}

resource "google_container_analysis_occurrence" "note_scanning" {
  project  = var.project_id
  note_name = "projects/${var.project_id}/notes/gcp-container-scanning"

  resource_uri = "https://gcr.io/${var.project_id}/test-image"

  vulnerability {
    severity = "HIGH"
    details {
      effective_severity = "HIGH"
      package_issue {
        affected_cpe_uri   = "cpe:/o:debian:debian_linux:8"
        affected_package     = "icu"
        fixed_cpe_uri        = "cpe:/o:debian:debian_linux:8"
        fixed_package          = "icu"
        fixed_version {
          epoch  = "0"
          name   = "52.1-8+deb8u6"
          revision = ""
          kind   = "NORMAL"
        }
      }
    }
  }
}

resource "google_project_service" "artifactregistry" {
  project            = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "containeranalysis" {
  project            = var.project_id
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudasset" {
  project            = var.project_id
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "oslogin" {
  project            = var.project_id
  service            = "oslogin.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "dns" {
  project            = var.project_id
  service            = "dns.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "default_account" {
  account_id   = "default-service-account"
  display_name = "Default Service Account"
  project      = var.project_id
}

resource "google_storage_bucket" "buckets" {
  for_each = toset(var.bucket_names)
  name          = each.value
  project       = var.project_id
  location      = "AUSTRALIA-SOUTHEAST1"
  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_logging_project_sink" "default" {
  name        = "all-logs"
  project     = var.project_id
  destination = "storage.googleapis.com/${var.project_id}-all-logs"
  filter      = "NOT logName:\"projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity\""
}

resource "google_logging_metric" "audit_configuration_changes" {
  name        = "audit-configuration-changes"
  project     = var.project_id
  description = "Number of audit configuration changes"
  filter      = "resource.type=audited_resource AND logName:cloudaudit.googleapis.com%2Fsystem_event AND protoPayload.methodName=SetIamPolicy OR protoPayload.methodName=google.iam.admin.v1.CreateServiceAccount OR protoPayload.methodName=google.iam.admin.v1.DeleteServiceAccount"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "audit_configuration_changes" {
  display_name = "Audit Configuration Changes Alert"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/audit-configuration-changes\" AND resource.type=\"global\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      trigger {
        count = 1
      }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "bucket_permission_changes" {
  name        = "bucket-permission-changes"
  project     = var.project_id
  description = "Number of bucket permission changes"
  filter      = "resource.type=gcs_bucket AND logName:cloudaudit.googleapis.com%2Fdata_access AND protoPayload.methodName=storage.setIamPermissions"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes" {
  display_name = "Bucket Permission Changes Alert"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/bucket-permission-changes\" AND resource.type=\"gcs_bucket\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      trigger {
        count = 1
      }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "custom_role_changes" {
  name        = "custom-role-changes"
  project     = var.project_id
  description = "Number of custom role changes"
  filter      = "resource.type=iam_role AND logName:cloudaudit.googleapis.com%2Fsystem_event AND protoPayload.methodName=google.iam.admin.v1.CreateRole OR protoPayload.methodName=google.iam.admin.v1.DeleteRole OR protoPayload.methodName=google.iam.admin.v1.UpdateRole"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes" {
  display_name = "Custom Role Changes Alert"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/custom-role-changes\" AND resource.type=\"iam_role\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      trigger {
        count = 1
      }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "project_ownership_changes" {
  name        = "project-ownership-changes"
  project     = var.project_id
  description = "Number of project ownership changes"
  filter      = "resource.type=project AND logName:cloudaudit.googleapis.com%2Fsystem_event AND protoPayload.methodName=SetIamPolicy"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes" {
  display_name = "Project Ownership Changes Alert"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/project-ownership-changes\" AND resource.type=\"project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      trigger {
        count = 1
      }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "sql_instance_configuration_changes" {
  name        = "sql-instance-configuration-changes"
  project     = var.project_id
  description = "Number of SQL instance configuration changes"
  filter      = "resource.type=cloudsql_database_instance AND logName:cloudaudit.googleapis.com%2Fsystem_event AND protoPayload.methodName=cloudsql.instances.update"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "sql_instance_configuration_changes" {
  display_name = "SQL Instance Configuration Changes Alert"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/sql-instance-configuration-changes\" AND resource.type=\"cloudsql_database_instance\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      trigger {
        count = 1
      }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  name        = "vpc-firewall-rule-changes"
  project     = var.project_id
  description = "Number of VPC firewall rule changes"
  filter      = "resource.type=gce_firewall_rule AND logName:cloudaudit.googleapis.com%2Fsystem_event AND protoPayload.methodName=compute.firewalls.insert OR protoPayload.methodName=compute.firewalls.delete"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes" {
  display_name = "VPC Firewall Rule Changes Alert"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-firewall-rule-changes\" AND resource.type=\"gce_firewall_rule\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      trigger {
        count = 1
      }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_network_changes" {
  name        = "vpc-network-changes"
  project     = var.project_id
  description = "Number of VPC network changes"
  filter      = "resource.type=gce_network AND logName:cloudaudit.googleapis.com%2Fsystem_event AND protoPayload.methodName=compute.networks.insert OR protoPayload.methodName=compute.networks.delete"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes" {
  display_name = "VPC Network Changes Alert"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-changes\" AND resource.type=\"gce_network\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      trigger {
        count = 1
      }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_network_route_changes" {
  name        = "vpc-network-route-changes"
  project     = var.project_id
  description = "Number of VPC network route changes"
  filter      = "resource.type=gce_route AND logName:cloudaudit.googleapis.com%2Fsystem_event AND protoPayload.methodName=compute.routes.insert OR protoPayload.methodName=compute.routes.delete"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes" {
  display_name = "VPC Network Route Changes Alert"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-route-changes\" AND resource.type=\"gce_route\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      trigger {
        count = 1
      }
    }
  }
  notification_channels = []
}
