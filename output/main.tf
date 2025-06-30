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
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudasset" {
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_project_metadata" "oslogin" {
  project = var.project_id
  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_storage_bucket" "logging_bucket" {
  name          = var.logging_bucket
  location      = var.location
  project       = var.project_id
  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_logging_project_sink" "default" {
  name          = "default-sink"
  project       = var.project_id
  destination   = "storage.googleapis.com/${google_storage_bucket.logging_bucket.name}"
  filter        = "NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity OR NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Fdata_access"
  unique_writer_identity = true
}

resource "google_project_iam_member" "logging_writer" {
  project = var.project_id
  role    = "roles/storage.objectCreator"
  member  = "serviceAccount:${google_logging_project_sink.default.writer_identity}"
}

resource "google_logging_metric" "audit_config_changes" {
  name        = "audit-config-changes"
  project     = var.project_id
  description = "Count of audit configuration changes"
  filter = "resource.type=audited_resource AND protoPayload.methodName:SetIamPolicy OR protoPayload.methodName:UpdateRole"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "audit_config_changes" {
  display_name = "Audit Configuration Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/audit-config-changes\" AND resource.type=\"gcp_project\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }
}

resource "google_logging_metric" "bucket_permission_changes" {
  name        = "bucket-permission-changes"
  project     = var.project_id
  description = "Count of bucket permission changes"
  filter = "resource.type=gcs_bucket AND protoPayload.methodName:storage.setIamPermissions"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes" {
  display_name = "Bucket Permission Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/bucket-permission-changes\" AND resource.type=\"gcp_project\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
    alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }
}

resource "google_logging_metric" "custom_role_changes" {
  name        = "custom-role-changes"
  project     = var.project_id
  description = "Count of custom role changes"
  filter = "resource.type=iam_role AND protoPayload.methodName:google.iam.admin.v1.CreateRole OR protoPayload.methodName:google.iam.admin.v1.DeleteRole OR protoPayload.methodName:google.iam.admin.v1.UpdateRole"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes" {
  display_name = "Custom Role Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/custom-role-changes\" AND resource.type=\"gcp_project\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
    alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }
}

resource "google_logging_metric" "project_ownership_changes" {
  name        = "project-ownership-changes"
  project     = var.project_id
  description = "Count of project ownership changes"
  filter = "resource.type=project AND protoPayload.methodName:SetIamPolicy"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes" {
  display_name = "Project Ownership Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/project-ownership-changes\" AND resource.type=\"gcp_project\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
    alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }
}

resource "google_logging_metric" "sql_instance_config_changes" {
  name        = "sql-instance-config-changes"
  project     = var.project_id
  description = "Count of SQL instance configuration changes"
  filter = "resource.type=cloudsql_database_instance AND protoPayload.methodName:cloudsql.instances.update"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "sql_instance_config_changes" {
  display_name = "SQL Instance Configuration Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/sql-instance-config-changes\" AND resource.type=\"gcp_project\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
    alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  name        = "vpc-firewall-rule-changes"
  project     = var.project_id
  description = "Count of VPC firewall rule changes"
  filter = "resource.type=gce_firewall_rule AND protoPayload.methodName:compute.firewalls.insert OR protoPayload.methodName:compute.firewalls.delete"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes" {
  display_name = "VPC Firewall Rule Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/vpc-firewall-rule-changes\" AND resource.type=\"gcp_project\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
    alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }
}

resource "google_logging_metric" "vpc_network_changes" {
  name        = "vpc-network-changes"
  project     = var.project_id
  description = "Count of VPC network changes"
  filter = "resource.type=gce_network AND protoPayload.methodName:compute.networks.insert OR protoPayload.methodName:compute.networks.patch OR protoPayload.methodName:compute.networks.delete"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes" {
  display_name = "VPC Network Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/vpc-network-changes\" AND resource.type=\"gcp_project\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
    alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }
}

resource "google_logging_metric" "vpc_network_route_changes" {
  name        = "vpc-network-route-changes"
  project     = var.project_id
  description = "Count of VPC network route changes"
  filter = "resource.type=gce_route AND protoPayload.methodName:compute.routes.insert OR protoPayload.methodName:compute.routes.delete"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes" {
  display_name = "VPC Network Route Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/vpc-network-route-changes\" AND resource.type=\"gcp_project\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
    alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }
}

resource "google_compute_firewall" "default_allow_ssh_restricted" {
  name    = "default-allow-ssh"
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.default_ssh_allowed_sources

  target_tags = ["ssh"]
}

resource "google_compute_firewall" "default_allow_rdp_restricted" {
  name    = "default-allow-rdp"
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = var.default_rdp_allowed_sources
  target_tags = ["rdp"]
}

resource "google_compute_default_network_tier" "default" {
  project = var.project_id
  network_tier = "PREMIUM"
}

resource "google_compute_subnetwork" "default" {
  for_each = toset(var.default_network_regions)
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  region                   = each.value
  network                  = var.default_vpc_name
  project                  = var.project_id
  private_ip_google_access = true
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_dns_managed_zone" "default" {
  name        = "dns-logging-zone"
  dns_name    = "example.com."
  project     = var.project_id
  description = "DNS managed zone for VPC DNS logging"
  visibility  = "private"
  private_visibility_config {
    networks {
      network_url = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/global/networks/${var.default_vpc_name}"
    }
  }
}

resource "google_compute_network" "default" {
  name                    = var.default_vpc_name
  project                 = var.project_id
  delete_default_routes_on_create = true
  enable_ula_internal_ipv6    = false
  auto_create_subnetworks = false
  dns_config {
    enable_logging = true
  }
}

resource "google_storage_bucket_iam_binding" "twitch_login" {
  bucket = google_storage_bucket.logging_bucket.name
  members = [
    "serviceAccount:twitch-login@aviato-game-fight-rvxirf.iam.gserviceaccount.com",
  ]
  role = "roles/storage.objectViewer"
}

resource "google_storage_bucket_iam_binding" "compute_account" {
  bucket = google_storage_bucket.logging_bucket.name
  members = [
    "serviceAccount:30647320905-compute@developer.gserviceaccount.com",
  ]
  role = "roles/storage.objectViewer"
}
