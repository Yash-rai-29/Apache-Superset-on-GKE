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
}

resource "google_project_service_identity" "artifactregistry" {
  provider = google
  project  = var.project_id
  service  = "artifactregistry.googleapis.com"
}

resource "google_artifact_registry_repository" "default" {
  provider = google
  project             = var.project_id
  location            = "us-central1"
  repository_id     = "container-analysis-metadata"
  description         = "Repository for storing container analysis metadata"
  format              = "DOCKER"
}

resource "google_container_analysis_occurrence" "default" {
  provider = google
  project   = var.project_id

  note_name     = "projects/goog-analysis/notes/PACKAGE_VULNERABILITY"
  resource_uri  = "https://gcr.io/my-project/my-image:123"

  package_issue {
    affected_location {
      cpe_uri   = "cpe:/o:debian:debian_linux:8"
      package   = "dpkg"
      version {
        epoch   = "0"
        name    = "1.18.2"
        revision = "5ubuntu5.2"
      }
    }
    fixed_location {
      cpe_uri   = "cpe:/o:debian:debian_linux:8"
      package   = "dpkg"
      version {
        epoch   = "0"
        name    = "1.18.2"
        revision = "5ubuntu5.3"
      }
    }
    severity        = "HIGH"
  }
}


resource "google_storage_bucket" "default" {
  for_each = toset(var.bucket_names)
  name          = each.value
  project       = var.project_id
  location      = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}


resource "google_compute_firewall" "rdp" {
  name    = "default-allow-rdp"
  project = var.project_id
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  direction = "INGRESS"
  disabled = true
}

resource "google_compute_firewall" "ssh" {
  name    = "default-allow-ssh"
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  direction = "INGRESS"
  disabled = true
}

resource "google_compute_network" "default" {
  name                    = "default"
  project                 = var.project_id
  auto_create_subnetworks = false
  delete_default_routes = true
}

resource "google_compute_network_dns_logging_policy" "default" {
  name        = "default"
  project     = var.project_id
  network     = "default"
  logging_config {
      enable_logging = true
  }
}

resource "google_compute_project_metadata" "project" {
  project = var.project_id

  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_subnetwork" "default" {
  for_each = toset(var.regions)
  name                     = "default"
  project                  = var.project_id
  region                   = each.value
  network                  = "default"
  ip_cidr_range            = "10.10.10.0/24"
  private_ip_google_access = true
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_project_service" "container_scanning" {
  provider = google
  project = var.project_id
  service = "containerscanning.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudasset" {
  provider = google
  project = var.project_id
  service = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_logging_log_sink" "default" {
  name        = "all-logs"
  project     = var.project_id
  destination = "storage.googleapis.com/${var.project_id}-logging-bucket"
  filter      = "NOT logName:compute.googleapis.com/serialConsoleOutput"
}

resource "google_logging_metric" "audit_configuration_changes" {
  name        = "audit-configuration-changes"
  project     = var.project_id
  description = "Count of audit configuration changes"
  filter      = "logName:activity AND protoPayload.methodName:SetIamPolicy"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "audit_configuration_changes" {
  display_name = "Audit Configuration Changes Alert"
  project     = var.project_id
  combiner = "OR"

  conditions {
    display_name = "Audit Configuration Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/audit-configuration-changes\" resource.type=\"global\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }

  notification_channels = [] # Replace with your notification channel
}

resource "google_logging_metric" "bucket_permission_changes" {
  name        = "bucket-permission-changes"
  project     = var.project_id
  description = "Count of Cloud Storage IAM permission changes"
  filter      = "logName:data_access AND protoPayload.methodName:storage.setIamPermissions"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes" {
  display_name = "Cloud Storage IAM Permission Changes Alert"
  project     = var.project_id
  combiner = "OR"

  conditions {
    display_name = "Cloud Storage IAM Permission Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/bucket-permission-changes\" resource.type=\"global\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }

  notification_channels = [] # Replace with your notification channel
}

resource "google_logging_metric" "custom_role_changes" {
  name        = "custom-role-changes"
  project     = var.project_id
  description = "Count of Custom Role changes"
  filter      = "logName:iam.googleapis.com%2Froles AND protoPayload.methodName:google.iam.admin.v1.CreateRole OR protoPayload.methodName:google.iam.admin.v1.DeleteRole OR protoPayload.methodName:google.iam.admin.v1.UpdateRole"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes" {
  display_name = "Custom Role Changes Alert"
  project     = var.project_id
  combiner = "OR"

  conditions {
    display_name = "Custom Role Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/custom-role-changes\" resource.type=\"global\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }

  notification_channels = [] # Replace with your notification channel
}

resource "google_logging_metric" "project_ownership_changes" {
  name        = "project-ownership-changes"
  project     = var.project_id
  description = "Count of Project Ownership Assignments/Changes"
  filter      = "logName:cloudresourcemanager.googleapis.com%2Factivity AND protoPayload.methodName:SetIamPolicy AND resource.type:project"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes" {
  display_name = "Project Ownership Changes Alert"
  project     = var.project_id
  combiner = "OR"

  conditions {
    display_name = "Project Ownership Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/project-ownership-changes\" resource.type=\"global\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }

  notification_channels = [] # Replace with your notification channel
}

resource "google_logging_metric" "sql_instance_configuration_changes" {
  name        = "sql-instance-configuration-changes"
  project     = var.project_id
  description = "Count of SQL Instance Configuration Changes"
  filter      = "logName:cloudaudit.googleapis.com%2Fdata_access AND protoPayload.serviceName:sqladmin.googleapis.com AND protoPayload.methodName:cloudsql.instances.update"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "sql_instance_configuration_changes" {
  display_name = "SQL Instance Configuration Changes Alert"
  project     = var.project_id
  combiner = "OR"

  conditions {
    display_name = "SQL Instance Configuration Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/sql-instance-configuration-changes\" resource.type=\"global\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }

  notification_channels = [] # Replace with your notification channel
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  name        = "vpc-firewall-rule-changes"
  project     = var.project_id
  description = "Count of VPC Network Firewall Rule Changes"
  filter      = "logName:compute.googleapis.com%2Factivity AND protoPayload.methodName:compute.firewalls.insert OR protoPayload.methodName:compute.firewalls.delete"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes" {
  display_name = "VPC Network Firewall Rule Changes Alert"
  project     = var.project_id
  combiner = "OR"

  conditions {
    display_name = "VPC Network Firewall Rule Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-firewall-rule-changes\" resource.type=\"global\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }

  notification_channels = [] # Replace with your notification channel
}

resource "google_logging_metric" "vpc_network_changes" {
  name        = "vpc-network-changes"
  project     = var.project_id
  description = "Count of VPC Network Changes"
  filter      = "logName:compute.googleapis.com%2Factivity AND protoPayload.methodName:compute.networks.insert OR protoPayload.methodName:compute.networks.delete"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes" {
  display_name = "VPC Network Changes Alert"
  project     = var.project_id
  combiner = "OR"

  conditions {
    display_name = "VPC Network Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-changes\" resource.type=\"global\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }

  notification_channels = [] # Replace with your notification channel
}

resource "google_logging_metric" "vpc_network_route_changes" {
  name        = "vpc-network-route-changes"
  project     = var.project_id
  description = "Count of VPC Network Route Changes"
  filter      = "logName:compute.googleapis.com%2Factivity AND protoPayload.methodName:compute.routes.insert OR protoPayload.methodName:compute.routes.delete"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes" {
  display_name = "VPC Network Route Changes Alert"
  project     = var.project_id
  combiner = "OR"

  conditions {
    display_name = "VPC Network Route Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-route-changes\" resource.type=\"global\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }

  notification_channels = [] # Replace with your notification channel
}
