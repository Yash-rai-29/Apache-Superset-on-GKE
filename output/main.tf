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

resource "google_project_service_identity" "gcr_service_account" {
  provider = google
  project  = var.project_id
  service  = "containeranalysis.googleapis.com"
}

resource "google_project_service" "artifactregistry" {
  provider           = google
  disable_on_destroy = false
  project            = var.project_id
  service            = "artifactregistry.googleapis.com"
}

resource "google_artifact_registry_repository" "default" {
  depends_on = [google_project_service_identity.gcr_service_account, google_project_service.artifactregistry]
  location      = "us-central1"
  project       = var.project_id
  repository_id = "default"
  format        = "DOCKER"
}

resource "google_project_service" "containeranalysis" {
  provider           = google
  disable_on_destroy = false
  project            = var.project_id
  service            = "containeranalysis.googleapis.com"
}

resource "google_project_service" "cloudasset" {
  provider           = google
  disable_on_destroy = false
  project            = var.project_id
  service            = "cloudasset.googleapis.com"
}

resource "google_project_service" "dns" {
  provider           = google
  disable_on_destroy = false
  project            = var.project_id
  service            = "dns.googleapis.com"
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

resource "google_logging_project_sink" "default" {
  name = "all-logs"
  description = "Sink for all logs"
  destination = "storage.googleapis.com/${var.project_id}-all-logs"
  filter      = "NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity"
  project = var.project_id
}

resource "google_logging_metric" "audit_configuration_changes" {
  name = "audit-configuration-changes"
  project = var.project_id
  description = "Count of audit configuration changes"
  filter = "protoPayload.methodName=\"SetIamPolicy\" OR protoPayload.methodName=\"google.cloud.audit.AuditPolicyService.UpdateAuditConfig\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "audit_configuration_changes" {
  display_name = "Audit Configuration Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Audit Configuration Changes"
    condition_threshold {
      filter = "metric.type=\"logging.googleapis.com/user/audit-configuration-changes\" resource.type=\"gcp_project\""
      duration = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "bucket_permission_changes" {
  name = "bucket-permission-changes"
  project = var.project_id
  description = "Count of cloud storage bucket permission changes"
  filter = "resource.type=\"gcs_bucket\" AND protoPayload.methodName=\"storage.setIamPermissions\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes" {
  display_name = "Cloud Storage Bucket Permission Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Cloud Storage Bucket Permission Changes"
    condition_threshold {
      filter = "metric.type=\"logging.googleapis.com/user/bucket-permission-changes\" resource.type=\"gcp_project\""
      duration = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "custom_role_changes" {
  name = "custom-role-changes"
  project = var.project_id
  description = "Count of custom role changes"
  filter = "resource.type=\"iam_role\" AND protoPayload.methodName=\"google.iam.admin.v1.CreateRole\" OR protoPayload.methodName=\"google.iam.admin.v1.DeleteRole\" OR protoPayload.methodName=\"google.iam.admin.v1.UpdateRole\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes" {
  display_name = "Custom Role Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Custom Role Changes"
    condition_threshold {
      filter = "metric.type=\"logging.googleapis.com/user/custom-role-changes\" resource.type=\"gcp_project\""
      duration = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "project_ownership_changes" {
  name = "project-ownership-changes"
  project = var.project_id
  description = "Count of project ownership assignments/changes"
  filter = "resource.type=\"project\" AND protoPayload.methodName=\"SetIamPolicy\" AND protoPayload.request.policy.bindings:data.members=\"user:email@example.com\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes" {
  display_name = "Project Ownership Assignments/Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Project Ownership Assignments/Changes"
    condition_threshold {
      filter = "metric.type=\"logging.googleapis.com/user/project-ownership-changes\" resource.type=\"gcp_project\""
      duration = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "sql_instance_configuration_changes" {
  name = "sql-instance-configuration-changes"
  project = var.project_id
  description = "Count of SQL instance configuration changes"
  filter = "resource.type=\"cloudsql_instance\" AND protoPayload.methodName=\"cloudsql.instances.update\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "sql_instance_configuration_changes" {
  display_name = "SQL Instance Configuration Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "SQL Instance Configuration Changes"
    condition_threshold {
      filter = "metric.type=\"logging.googleapis.com/user/sql-instance-configuration-changes\" resource.type=\"gcp_project\""
      duration = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  name = "vpc-firewall-rule-changes"
  project = var.project_id
  description = "Count of VPC Network Firewall Rule changes"
  filter = "resource.type=\"gcp_firewall_rule\" AND protoPayload.methodName=\"compute.firewalls.insert\" OR protoPayload.methodName=\"compute.firewalls.delete\" OR protoPayload.methodName=\"compute.firewalls.patch\" OR protoPayload.methodName=\"compute.firewalls.update\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes" {
  display_name = "VPC Network Firewall Rule Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "VPC Network Firewall Rule Changes"
    condition_threshold {
      filter = "metric.type=\"logging.googleapis.com/user/vpc-firewall-rule-changes\" resource.type=\"gcp_project\""
      duration = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_network_changes" {
  name = "vpc-network-changes"
  project = var.project_id
  description = "Count of VPC Network changes"
  filter = "resource.type=\"gcp_network\" AND protoPayload.methodName=\"compute.networks.insert\" OR protoPayload.methodName=\"compute.networks.delete\" OR protoPayload.methodName=\"compute.networks.patch\" OR protoPayload.methodName=\"compute.networks.update\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes" {
  display_name = "VPC Network Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "VPC Network Changes"
    condition_threshold {
      filter = "metric.type=\"logging.googleapis.com/user/vpc-network-changes\" resource.type=\"gcp_project\""
      duration = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_network_route_changes" {
  name = "vpc-network-route-changes"
  project = var.project_id
  description = "Count of VPC Network Route changes"
  filter = "resource.type=\"gcp_route\" AND protoPayload.methodName=\"compute.routes.insert\" OR protoPayload.methodName=\"compute.routes.delete\" OR protoPayload.methodName=\"compute.routes.patch\" OR protoPayload.methodName=\"compute.routes.update\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes" {
  display_name = "VPC Network Route Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "VPC Network Route Changes"
    condition_threshold {
      filter = "metric.type=\"logging.googleapis.com/user/vpc-network-route-changes\" resource.type=\"gcp_project\""
      duration = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
    }
  }
  notification_channels = []
}

resource "google_compute_firewall" "rdp" {
  name    = "default-allow-rdp"
  project = var.project_id
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

resource "google_compute_firewall" "ssh" {
  name    = "default-allow-ssh"
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
    source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

resource "google_dns_managed_zone" "private_zone" {
  name        = "private-zone"
  dns_name    = "example.com."
  project     = var.project_id
  description = "Private DNS zone for VPC network"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = "projects/${var.project_id}/global/networks/default"
    }
  }
}

resource "google_project_default_service_accounts" "default_accounts" {
  project = var.project_id
  action = "DISABLE"
}

resource "google_storage_bucket" "buckets" {
  for_each = toset(var.bucket_names)

  name          = each.value
  location      = "US"
  project       = var.project_id
  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_compute_subnetwork" "default" {
  for_each = toset(var.regions)
  name                     = "default"
  ip_cidr_range          = "10.10.10.0/24"
  network                  = "default"
  region                   = each.value
  project                  = var.project_id
  private_ip_google_access = true
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
