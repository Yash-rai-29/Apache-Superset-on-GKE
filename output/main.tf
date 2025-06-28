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
}

resource "google_project_service" "artifactregistry" {
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "default" {
  provider      = google
  location      = "us"
  repository_id = "container-repo"
  description   = "Terraform-managed container repository."
  format        = "DOCKER"
  project       = var.project_id

  depends_on = [google_project_service.artifactregistry]
}

resource "google_container_analysis_occurrence" "default" {
  provider = google
  note     = "projects/goog-analysis/notes/PACKAGE_VULNERABILITY"
  resource_uri = "https://${google_artifact_registry_repository.default.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.default.repository_id}/test-image:latest"
}

resource "google_project_service" "containeranalysis" {
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false

  depends_on = [google_artifact_registry_repository.default]
}

resource "google_project_service" "cloudasset" {
  service = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service_identity" "cloudasset" {
  provider = google
  project = var.project_id
  service = "cloudasset.googleapis.com"
}

resource "google_project_iam_member" "cloudasset_export_permission" {
  project = var.project_id
  role = "roles/storage.admin"
  member = "serviceAccount:${data.google_project_service_identity.cloudasset.email}"
}

data "google_project_service_identity" "cloudasset" {
  provider = google
  project = var.project_id
  service = "cloudasset.googleapis.com"
}

resource "google_os_login_settings" "default" {
  project = var.project_id
  deletion_mode = "ACCOUNT"
}

resource "google_project_default_network" "default" {
  project = var.project_id

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = "custom-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "default" {
  for_each = toset(var.regions)

  name                     = "subnet-${each.key}"
  ip_cidr_range            = "10.10.10.0/24"
  region                   = each.key
  network                  = google_compute_network.vpc_network.id
  project                  = var.project_id
  private_ip_google_access = true
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "ssh" {
  name    = "deny-ssh-internet"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

resource "google_compute_firewall" "rdp" {
  name    = "deny-rdp-internet"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

resource "google_dns_managed_zone" "default" {
  name        = "dns-logging-zone"
  dns_name    = "example.com."
  project     = var.project_id
  description = "DNS zone for enabling DNS logging"
  visibility  = "public"
}

resource "google_compute_network" "default" {
  name                    = "default"
  project                 = var.project_id
  delete_default_routes = true
  dns_config {
    enable_logging = true
  }
}

resource "google_logging_project_sink" "default" {
  name           = "all-logs-sink"
  description  = "A sink to capture all logs"
  destination  = "storage.googleapis.com/${var.project_id}-logs-bucket"
  filter         = "NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Fdata_access"
  project = var.project_id
}

resource "google_storage_bucket" "log_bucket" {
  name                        = "${var.project_id}-logs-bucket"
  project                     = var.project_id
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_logging_metric" "audit_configuration_changes" {
  name        = "audit-config-changes"
  project = var.project_id
  description = "Metric for audit configuration changes"
  filter      = "protoPayload.methodName=\"google.iam.admin.v1.CreateServiceAccount\" OR protoPayload.methodName=\"google.iam.admin.v1.DeleteServiceAccount\" OR protoPayload.methodName=\"google.iam.admin.v1.SetIamPolicy\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "audit_configuration_changes_alert" {
  display_name = "Audit Configuration Changes Alert"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Audit Configuration Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/audit-config-changes\" resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }
  alert_strategy {
    notification_channel_strategy {
      channel_names = []
      renotify_interval = "300s"
    }
  }
}

resource "google_logging_metric" "bucket_permission_changes" {
  name        = "bucket-permission-changes"
  project = var.project_id
  description = "Metric for Cloud Storage IAM permission changes"
  filter      = "resource.type=\"gcs_bucket\" AND protoPayload.methodName=\"storage.setIamPermissions\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes_alert" {
  display_name = "Cloud Storage IAM Permission Changes Alert"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Cloud Storage IAM Permission Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/bucket-permission-changes\" resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }
  alert_strategy {
    notification_channel_strategy {
      channel_names = []
      renotify_interval = "300s"
    }
  }
}

resource "google_logging_metric" "custom_role_changes" {
  name        = "custom-role-changes"
  project = var.project_id
  description = "Metric for Custom Role Changes"
  filter      = "protoPayload.methodName=\"google.iam.admin.v1.CreateRole\" OR protoPayload.methodName=\"google.iam.admin.v1.DeleteRole\" OR protoPayload.methodName=\"google.iam.admin.v1.UpdateRole\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes_alert" {
  display_name = "Custom Role Changes Alert"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Custom Role Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/custom-role-changes\" resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }
    alert_strategy {
    notification_channel_strategy {
      channel_names = []
      renotify_interval = "300s"
    }
  }
}

resource "google_logging_metric" "project_ownership_changes" {
  name        = "project-ownership-changes"
  project = var.project_id
  description = "Metric for Project Ownership Assignments/Changes"
  filter      = "protoPayload.methodName=\"SetIamPolicy\" AND resource.type=\"project\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes_alert" {
  display_name = "Project Ownership Changes Alert"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Project Ownership Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/project-ownership-changes\" resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }
    alert_strategy {
    notification_channel_strategy {
      channel_names = []
      renotify_interval = "300s"
    }
  }
}

resource "google_logging_metric" "sql_instance_configuration_changes" {
  name        = "sql-instance-config-changes"
  project = var.project_id
  description = "Metric for SQL Instance Configuration Changes"
  filter      = "resource.type=\"cloudsql_database\" AND protoPayload.methodName=\"cloudsql.instances.update\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "sql_instance_configuration_changes_alert" {
  display_name = "SQL Instance Configuration Changes Alert"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "SQL Instance Configuration Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/sql-instance-config-changes\" resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }
    alert_strategy {
    notification_channel_strategy {
      channel_names = []
      renotify_interval = "300s"
    }
  }
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  name        = "vpc-firewall-rule-changes"
  project = var.project_id
  description = "Metric for VPC Network Firewall Rule Changes"
  filter      = "resource.type=\"gce_firewall_rule\" AND protoPayload.methodName=\"compute.firewalls.insert\" OR protoPayload.methodName=\"compute.firewalls.delete\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes_alert" {
  display_name = "VPC Network Firewall Rule Changes Alert"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "VPC Network Firewall Rule Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-firewall-rule-changes\" resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }
    alert_strategy {
    notification_channel_strategy {
      channel_names = []
      renotify_interval = "300s"
    }
  }
}

resource "google_logging_metric" "vpc_network_changes" {
  name        = "vpc-network-changes"
  project = var.project_id
  description = "Metric for VPC Network Changes"
  filter      = "resource.type=\"gce_network\" AND protoPayload.methodName=\"compute.networks.insert\" OR protoPayload.methodName=\"compute.networks.delete\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes_alert" {
  display_name = "VPC Network Changes Alert"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "VPC Network Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-changes\" resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }
    alert_strategy {
    notification_channel_strategy {
      channel_names = []
      renotify_interval = "300s"
    }
  }
}

resource "google_logging_metric" "vpc_network_route_changes" {
  name        = "vpc-network-route-changes"
  project = var.project_id
  description = "Metric for VPC Network Route Changes"
  filter      = "resource.type=\"gce_route\" AND protoPayload.methodName=\"compute.routes.insert\" OR protoPayload.methodName=\"compute.routes.delete\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes_alert" {
  display_name = "VPC Network Route Changes Alert"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "VPC Network Route Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-route-changes\" resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }
    alert_strategy {
    notification_channel_strategy {
      channel_names = []
      renotify_interval = "300s"
    }
  }
}

resource "google_storage_bucket" "buckets" {
  for_each = toset(var.bucket_names)
  name                        = each.key
  project                     = var.project_id
  location                    = "US"
  uniform_bucket_level_access = true
}
