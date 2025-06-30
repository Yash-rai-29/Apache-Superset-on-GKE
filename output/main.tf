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

resource "google_project_service_identity" "gcr_service_account" {
  provider = google
  project  = var.project_id
  service  = "containerregistry.googleapis.com"
}

resource "google_project_iam_member" "gcr_service_account_artifact_registry" {
  provider = google
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_project_service_identity.gcr_service_account.email}"
}

resource "google_project_service" "artifactregistry" {
  provider = google
  project = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "default" {
  provider = google
  project  = var.project_id
  location = var.region
  repository_id = "default-repository"
  format = "DOCKER"
}

resource "google_project_service" "containeranalysis" {
  provider = google
  project  = var.project_id
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_iam_member" "container_analysis_service_account" {
  provider = google
  project = var.project_id
  role    = "roles/containeranalysis.notes.occurrences.viewer"
  member  = "serviceAccount:${google_project_service_identity.gcr_service_account.email}"
  depends_on = [google_project_service.containeranalysis]
}

resource "google_project_service" "cloudasset" {
  provider = google
  project  = var.project_id
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_iam_member" "cloudasset_service_account" {
  project = var.project_id
  role    = "roles/cloudasset.viewer"
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloudasset.iam.gserviceaccount.com"
  depends_on = [google_project_service.cloudasset]
}

data "google_project" "project" {
  provider = google
  project = var.project_id
}

resource "google_project_service" "logging" {
  provider = google
  project  = var.project_id
  service            = "logging.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "oslogin" {
  provider = google
  project  = var.project_id
  service            = "oslogin.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_metadata" "oslogin_enable" {
  provider = google
  project = var.project_id

  metadata = {
    enable-oslogin = "TRUE"
  }

  depends_on = [google_project_service.oslogin]
}

resource "google_compute_network" "default" {
  provider = google
  name                    = "default"
  project                 = var.project_id
  auto_create_subnetworks = false
  delete_default_routes = true
}

resource "google_compute_firewall" "rdp" {
  provider = google
  name    = "default-allow-rdp"
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  direction = "INGRESS"

  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]

  target_tags = []
}

resource "google_compute_firewall" "ssh" {
  provider = google
  name    = "default-allow-ssh"
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction = "INGRESS"

  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]

  target_tags = []
}

resource "google_logging_project_sink" "default_sink" {
  provider = google
  name        = "default-sink"
  project     = var.project_id
  destination = "storage.googleapis.com/${var.project_id}-logs"
  filter      = "severity>=INFO"
}

resource "google_storage_bucket" "log_bucket" {
  provider = google
  name                        = "${var.project_id}-logs"
  project                     = var.project_id
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_project_iam_binding" "storage_writer" {
  project = var.project_id
  role    = "roles/storage.objectCreator"
  members = ["serviceAccount:gcp-sa-logging@gcp-sa-logging.iam.gserviceaccount.com"]
}

resource "google_project_iam_member" "storage_logs_writer" {
  project = var.project_id
  role    = "roles/logging.bucketWriter"
  member = "serviceAccount:gcp-sa-logging@gcp-sa-logging.iam.gserviceaccount.com"
}

resource "google_logging_metric" "audit_config_changes" {
  provider = google
  name        = "audit-config-changes"
  project = var.project_id
  description = "Number of audit configuration changes."
  filter      = "resource.type=audited_resource AND log_name:cloudaudit.googleapis.com%2Factivity AND protoPayload.methodName=SetIamPolicy OR protoPayload.methodName=google.cloud.audit.AuditPolicy.SetAuditConfig"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit        = "1"
  }
}

resource "google_logging_metric" "bucket_permission_changes" {
  provider = google
  name        = "bucket-permission-changes"
  project = var.project_id
  description = "Number of Cloud Storage IAM permission changes."
  filter      = "resource.type=gcs_bucket AND log_name:cloudaudit.googleapis.com%2Fdata_access AND protoPayload.methodName=storage.setIamPermissions"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit        = "1"
  }
}

resource "google_logging_metric" "custom_role_changes" {
  provider = google
  name        = "custom-role-changes"
  project = var.project_id
  description = "Number of custom role changes."
  filter      = "resource.type=iam_role AND log_name:cloudaudit.googleapis.com%2Factivity AND protoPayload.methodName=google.iam.admin.v1.UpdateRole"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit        = "1"
  }
}

resource "google_logging_metric" "project_ownership_changes" {
  provider = google
  name        = "project-ownership-changes"
  project = var.project_id
  description = "Number of project ownership assignments/changes."
  filter      = "resource.type=project AND log_name:cloudaudit.googleapis.com%2Factivity AND protoPayload.methodName=SetIamPolicy"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit        = "1"
  }
}

resource "google_logging_metric" "sql_instance_config_changes" {
  provider = google
  name        = "sql-instance-config-changes"
  project = var.project_id
  description = "Number of SQL instance configuration changes."
  filter      = "resource.type=cloudsql_database AND log_name:cloudaudit.googleapis.com%2Factivity AND protoPayload.methodName=cloudsql.instances.update"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit        = "1"
  }
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  provider = google
  name        = "vpc-firewall-rule-changes"
  project = var.project_id
  description = "Number of VPC network firewall rule changes."
  filter      = "resource.type=gce_firewall_rule AND log_name:cloudaudit.googleapis.com%2Factivity AND protoPayload.methodName=compute.firewalls.insert"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit        = "1"
  }
}

resource "google_logging_metric" "vpc_network_changes" {
  provider = google
  name        = "vpc-network-changes"
  project = var.project_id
  description = "Number of VPC network changes."
  filter      = "resource.type=gce_network AND log_name:cloudaudit.googleapis.com%2Factivity AND protoPayload.methodName=compute.networks.insert"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit        = "1"
  }
}

resource "google_logging_metric" "vpc_network_route_changes" {
  provider = google
  name        = "vpc-network-route-changes"
  project = var.project_id
  description = "Number of VPC network route changes."
  filter      = "resource.type=gce_route AND log_name:cloudaudit.googleapis.com%2Factivity AND protoPayload.methodName=compute.routes.insert"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit        = "1"
  }
}

resource "google_monitoring_alert_policy" "audit_config_changes_alert" {
  provider = google
  display_name = "Audit Config Changes Alert"
  project = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Audit Config Changes Condition"
    condition_threshold {
      filter      = "metric.type=\"logging.googleapis.com/user/audit-config-changes\" AND resource.type=\"global\""
      duration    = "60s"
      comparison  = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }

  notification_channels = []
}

resource "google_monitoring_alert_policy" "bucket_permission_changes_alert" {
  provider = google
  display_name = "Bucket Permission Changes Alert"
  project = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Bucket Permission Changes Condition"
    condition_threshold {
      filter      = "metric.type=\"logging.googleapis.com/user/bucket-permission-changes\" AND resource.type=\"global\""
      duration    = "60s"
      comparison  = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }

  notification_channels = []
}

resource "google_monitoring_alert_policy" "custom_role_changes_alert" {
  provider = google
  display_name = "Custom Role Changes Alert"
  project = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Custom Role Changes Condition"
    condition_threshold {
      filter      = "metric.type=\"logging.googleapis.com/user/custom-role-changes\" AND resource.type=\"global\""
      duration    = "60s"
      comparison  = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }

  notification_channels = []
}

resource "google_monitoring_alert_policy" "project_ownership_changes_alert" {
  provider = google
  display_name = "Project Ownership Changes Alert"
  project = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Project Ownership Changes Condition"
    condition_threshold {
      filter      = "metric.type=\"logging.googleapis.com/user/project-ownership-changes\" AND resource.type=\"global\""
      duration    = "60s"
      comparison  = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }

  notification_channels = []
}

resource "google_monitoring_alert_policy" "sql_instance_config_changes_alert" {
  provider = google
  display_name = "SQL Instance Config Changes Alert"
  project = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "SQL Instance Config Changes Condition"
    condition_threshold {
      filter      = "metric.type=\"logging.googleapis.com/user/sql-instance-config-changes\" AND resource.type=\"global\""
      duration    = "60s"
      comparison  = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }

  notification_channels = []
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes_alert" {
  provider = google
  display_name = "VPC Firewall Rule Changes Alert"
  project = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "VPC Firewall Rule Changes Condition"
    condition_threshold {
      filter      = "metric.type=\"logging.googleapis.com/user/vpc-firewall-rule-changes\" AND resource.type=\"global\""
      duration    = "60s"
      comparison  = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }

  notification_channels = []
}

resource "google_monitoring_alert_policy" "vpc_network_changes_alert" {
  provider = google
  display_name = "VPC Network Changes Alert"
  project = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "VPC Network Changes Condition"
    condition_threshold {
      filter      = "metric.type=\"logging.googleapis.com/user/vpc-network-changes\" AND resource.type=\"global\""
      duration    = "60s"
      comparison  = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }

  notification_channels = []
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes_alert" {
  provider = google
  display_name = "VPC Network Route Changes Alert"
  project = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "VPC Network Route Changes Condition"
    condition_threshold {
      filter      = "metric.type=\"logging.googleapis.com/user/vpc-network-route-changes\" AND resource.type=\"global\""
      duration    = "60s"
      comparison  = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }

  notification_channels = []
}

resource "google_compute_subnetwork" "default" {
  provider = google
  for_each = toset(var.default_subnets)
  name                     = "default"
  ip_cidr_range            = "10.0.0.0/20"
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

resource "google_storage_bucket" "buckets" {
  provider = google
  for_each = toset(var.bucket_names)
  name                        = each.value
  project                     = var.project_id
  location                    = "US"
  uniform_bucket_level_access = true
}
