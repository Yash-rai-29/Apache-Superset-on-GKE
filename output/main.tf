terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.22.0"
    }
  }
}

provider "google" {
  project = var.project_id
}

resource "google_project_service_identity" "gcr_sa" {
  provider = google
  project  = var.project_id
  service  = "containerregistry.googleapis.com"
}

resource "google_project_service_identity" "artifactregistry_sa" {
  provider = google
  project  = var.project_id
  service  = "artifactregistry.googleapis.com"
}

resource "google_container_registry" "gcr" {
  provider = google
  project                 = var.project_id
  location                = "US"
  deletion_policy         = "DELETE"
  depends_on = [google_project_service_identity.gcr_sa]
}

resource "google_artifact_registry_repository" "ar" {
  provider = google
  project      = var.project_id
  location     = "us-central1"
  repository_id = "container-repo"
  format        = "DOCKER"
  depends_on = [google_project_service_identity.artifactregistry_sa]
}

resource "google_project_iam_member" "container_analysis" {
  provider = google
  project = var.project_id
  role = "roles/containeranalysis.occurrences.viewer"
  member = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

data "google_project" "project" {
  provider = google
  project = var.project_id
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
  project = var.project_id
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_network" "default" {
  provider = google
  name                    = var.default_network_name
  project                 = var.project_id
  delete_default_routes = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_firewall" "rdp" {
  provider = google
  name    = "default-allow-rdp"
  project = var.project_id
  network = var.default_network_name

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = var.rdp_ssh_source_ranges
}

resource "google_compute_firewall" "ssh" {
  provider = google
  name    = "default-allow-ssh"
  project = var.project_id
  network = var.default_network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.rdp_ssh_source_ranges
}

resource "google_compute_network" "default_network_dns_logging" {
  provider = google
  name                    = var.default_network_name
  project                 = var.project_id
  delete_default_routes = true

  enable_logging = true
}

resource "google_project_default_service_accounts" "default_accounts" {
  provider = google
  project = var.project_id
  action = "DISABLE"
}

resource "google_compute_subnetwork" "default_subnet_flow_logs" {
  provider = google
  for_each     = toset(var.regions)
  name         = "default"
  ip_cidr_range = "10.128.0.0/20"
  region       = each.key
  network      = "default"
  project      = var.project_id
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_project_organization_policy" "org_policy" {
  provider = google
  project      = var.project_id
  constraint = "compute.vmExternalIpAccess"

  boolean_policy {
    enforced = true
  }
}

resource "google_storage_bucket" "buckets" {
  provider = google
  for_each = toset(var.bucket_names)
  name          = each.key
  location      = "US"
  force_destroy = false
  uniform_bucket_level_access = true
}

resource "google_project_iam_audit_config" "audit_config" {
  provider = google
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

resource "google_logging_project_sink" "log_sink" {
  provider = google
  name        = "all-logs"
  project     = var.project_id
  destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/logging_dataset"
  filter      = "resource.type = gce_instance OR resource.type = gae_app OR resource.type = cloudsql_database OR resource.type = k8s_cluster"
}

resource "google_logging_metric" "audit_configuration_changes" {
  provider = google
  name        = "audit-configuration-changes"
  project     = var.project_id
  description = "Log metric for audit configuration changes"
  filter      = "protoPayload.methodName=\"SetIamPolicy\" OR protoPayload.methodName=\"google.cloud.audit.AuditPolicies.UpdateAuditConfig\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "audit_configuration_changes_alert" {
  provider = google
  display_name = "Alert for audit configuration changes"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Condition for audit configuration changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/audit-configuration-changes\" resource.type = global"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
      trigger {
        count   = 1
      }
    }
  }

  notification_channels = []
}

resource "google_logging_metric" "bucket_permission_changes" {
  provider = google
  name        = "bucket-permission-changes"
  project     = var.project_id
  description = "Log metric for Cloud Storage bucket permission changes"
  filter      = "resource.type=gcs_bucket AND protoPayload.methodName=\"storage.setIamPermissions\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes_alert" {
  provider = google
  display_name = "Alert for Cloud Storage bucket permission changes"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Condition for bucket permission changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/bucket-permission-changes\" resource.type = global"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
      trigger {
        count   = 1
      }
    }
  }

  notification_channels = []
}

resource "google_logging_metric" "custom_role_changes" {
  provider = google
  name        = "custom-role-changes"
  project     = var.project_id
  description = "Log metric for Custom Role Changes"
  filter      = "resource.type=iam_role AND (protoPayload.methodName=\"google.iam.admin.v1.CreateRole\" OR protoPayload.methodName=\"google.iam.admin.v1.UpdateRole\" OR protoPayload.methodName=\"google.iam.admin.v1.DeleteRole\")"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes_alert" {
  provider = google
  display_name = "Alert for Custom Role Changes"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Condition for custom role changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/custom-role-changes\" resource.type = global"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
      trigger {
        count   = 1
      }
    }
  }

  notification_channels = []
}

resource "google_logging_metric" "project_ownership_changes" {
  provider = google
  name        = "project-ownership-changes"
  project     = var.project_id
  description = "Log metric for Project Ownership Assignments/Changes"
  filter      = "resource.type=project AND protoPayload.methodName=\"SetIamPolicy\" AND protoPayload.request.policy.bindings:\"roles/owner\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes_alert" {
  provider = google
  display_name = "Alert for Project Ownership Assignments/Changes"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Condition for project ownership changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/project-ownership-changes\" resource.type = global"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
      trigger {
        count   = 1
      }
    }
  }

  notification_channels = []
}

resource "google_logging_metric" "sql_instance_configuration_changes" {
  provider = google
  name        = "sql-instance-configuration-changes"
  project     = var.project_id
  description = "Log metric for SQL Instance Configuration Changes"
  filter      = "resource.type=cloudsql_instance AND protoPayload.methodName=\"cloudsql.instances.update\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "sql_instance_configuration_changes_alert" {
  provider = google
  display_name = "Alert for SQL Instance Configuration Changes"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Condition for sql instance configuration changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/sql-instance-configuration-changes\" resource.type = global"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
      trigger {
        count   = 1
      }
    }
  }

  notification_channels = []
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  provider = google
  name        = "vpc-firewall-rule-changes"
  project     = var.project_id
  description = "Log metric for VPC Network Firewall Rule Changes"
  filter      = "resource.type=gce_firewall_rule AND (protoPayload.methodName=\"compute.firewalls.insert\" OR protoPayload.methodName=\"compute.firewalls.delete\")"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes_alert" {
  provider = google
  display_name = "Alert for VPC Network Firewall Rule Changes"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Condition for vpc firewall rule changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-firewall-rule-changes\" resource.type = global"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
      trigger {
        count   = 1
      }
    }
  }

  notification_channels = []
}

resource "google_logging_metric" "vpc_network_changes" {
  provider = google
  name        = "vpc-network-changes"
  project     = var.project_id
  description = "Log metric for VPC Network Changes"
  filter      = "resource.type=gce_network AND (protoPayload.methodName=\"compute.networks.insert\" OR protoPayload.methodName=\"compute.networks.patch\" OR protoPayload.methodName=\"compute.networks.delete\")"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes_alert" {
  provider = google
  display_name = "Alert for VPC Network Changes"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Condition for vpc network changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-changes\" resource.type = global"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
      trigger {
        count   = 1
      }
    }
  }

  notification_channels = []
}

resource "google_logging_metric" "vpc_network_route_changes" {
  provider = google
  name        = "vpc-network-route-changes"
  project     = var.project_id
  description = "Log metric for VPC Network Route Changes"
  filter      = "resource.type=gce_route AND (protoPayload.methodName=\"compute.routes.insert\" OR protoPayload.methodName=\"compute.routes.delete\")"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes_alert" {
  provider = google
  display_name = "Alert for VPC Network Route Changes"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Condition for vpc network route changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-route-changes\" resource.type = global"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
      trigger {
        count   = 1
      }
    }
  }

  notification_channels = []
}
