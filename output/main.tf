terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
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

resource "google_project_iam_member" "artifactregistry" {
  provider = google
  project = var.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_project_service_identity.artifactregistry.email}"
}

resource "google_artifact_registry_repository" "default" {
  provider = google
  project  = var.project_id
  location = "us"
  repository_id = "my-repo"
  format = "DOCKER"
}

resource "google_container_analysis_occurrence" "default" {
  provider = google
  project = var.project_id
  note_name   = "projects/goog-analysis/notes/package-vulnerability"
  resource_uri = "us-docker.pkg.dev/cloudrun/container/hello:latest"

  package_issue {
    affected_location {
      cpe_uri = "cpe:/o:debian:debian_linux:8"
      package = "urllib3"
      version {
        epoch = "0"
        name  = "1.10.2"
        revision = "1"
      }
    }
  }
}

resource "google_project_service" "artifactregistry" {
  provider = google
  project  = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "containeranalysis" {
  provider = google
  project  = var.project_id
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudasset" {
  provider = google
  project  = var.project_id
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "oslogin" {
  provider = google
  project  = var.project_id
  service            = "oslogin.googleapis.com"
  disable_on_destroy = false
}


resource "google_compute_project_metadata" "default" {
  provider = google
  project = var.project_id

  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_network" "default" {
  provider = google
  name                    = "default"
  project                 = var.project_id
  auto_create_subnetworks = "false"

  lifecycle {
    prevent_destroy = true
  }
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

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["rdp"]

  lifecycle {
    prevent_destroy = true
  }
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

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]

   lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_network_dns_policy" "default" {
  provider = google
  project      = var.project_id
  network      = "default"
  enable_logging = true
}

resource "google_logging_project_sink" "default" {
  provider = google
  name   = "all-logs"
  project = var.project_id
  destination = "storage.googleapis.com/${var.project_id}-logs"
  filter = "NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity"

  unique_writer_identity = true
}

resource "google_storage_bucket" "default" {
  provider = google
  name          = "${var.project_id}-logs"
  project       = var.project_id
  location      = "US"
  force_destroy = true
}

resource "google_storage_bucket_iam_binding" "logging_writer" {
  provider = google
  bucket = google_storage_bucket.default.name
  role   = "roles/storage.objectCreator"
  members = ["serviceAccount:${google_logging_project_sink.default.writer_identity}"]
}

resource "google_project_iam_member" "cloud_asset_inventory" {
  provider = google
  project = var.project_id
  role = "roles/cloudasset.viewer"
  member = "serviceAccount:cloudasset.googleapis.com"
}


resource "google_project_iam_member" "logging_admin" {
  provider = google
  project = var.project_id
  role = "roles/logging.configWriter"
  member = "serviceAccount:${google_logging_project_sink.default.writer_identity}"
}

resource "google_monitoring_alert_policy" "audit_configuration_changes" {
  provider = google
  project = var.project_id
  display_name = "Audit Configuration Changes"
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/audit_configuration_changes\" AND resource.type=\"gcp_project\""
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

resource "google_monitoring_alert_policy" "bucket_permission_changes" {
  provider = google
  project = var.project_id
  display_name = "Cloud Storage Bucket Permission Changes"
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/bucket_permission_changes\" AND resource.type=\"gcp_project\""
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

resource "google_monitoring_alert_policy" "custom_role_changes" {
  provider = google
  project = var.project_id
  display_name = "Custom Role Changes"
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/custom_role_changes\" AND resource.type=\"gcp_project\""
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

resource "google_monitoring_alert_policy" "project_ownership_changes" {
  provider = google
  project = var.project_id
  display_name = "Project Ownership Changes"
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/project_ownership_changes\" AND resource.type=\"gcp_project\""
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

resource "google_monitoring_alert_policy" "sql_instance_configuration_changes" {
  provider = google
  project = var.project_id
  display_name = "SQL Instance Configuration Changes"
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/sql_instance_configuration_changes\" AND resource.type=\"gcp_project\""
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

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes" {
  provider = google
  project = var.project_id
  display_name = "VPC Firewall Rule Changes"
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc_firewall_rule_changes\" AND resource.type=\"gcp_project\""
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

resource "google_monitoring_alert_policy" "vpc_network_changes" {
  provider = google
  project = var.project_id
  display_name = "VPC Network Changes"
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc_network_changes\" AND resource.type=\"gcp_project\""
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

resource "google_monitoring_alert_policy" "vpc_network_route_changes" {
  provider = google
  project = var.project_id
  display_name = "VPC Network Route Changes"
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc_network_route_changes\" AND resource.type=\"gcp_project\""
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

resource "google_logging_metric" "audit_configuration_changes" {
  provider = google
  name   = "audit_configuration_changes"
  project = var.project_id
  description = "Log metric for audit configuration changes"
  filter = "protoPayload.methodName=\"SetIamPolicy\" OR protoPayload.methodName=\"google.cloud.audit.AuditPolicies.V1.UpdateAuditConfig\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_logging_metric" "bucket_permission_changes" {
  provider = google
  name   = "bucket_permission_changes"
  project = var.project_id
  description = "Log metric for Cloud Storage bucket permission changes"
  filter = "resource.type=\"gcs_bucket\" AND protoPayload.methodName=\"storage.setIamPermissions\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_logging_metric" "custom_role_changes" {
  provider = google
  name   = "custom_role_changes"
  project = var.project_id
  description = "Log metric for custom role changes"
  filter = "resource.type=\"iam_role\" AND protoPayload.methodName=\"google.iam.admin.v1.CreateRole\" OR resource.type=\"iam_role\" AND protoPayload.methodName=\"google.iam.admin.v1.UpdateRole\" OR resource.type=\"iam_role\" AND protoPayload.methodName=\"google.iam.admin.v1.DeleteRole\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_logging_metric" "project_ownership_changes" {
  provider = google
  name   = "project_ownership_changes"
  project = var.project_id
  description = "Log metric for project ownership changes"
  filter = "protoPayload.methodName=\"SetIamPolicy\" AND resource.type=\"project\" AND protoPayload.authenticationInfo.principalEmail!=\"\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_logging_metric" "sql_instance_configuration_changes" {
  provider = google
  name   = "sql_instance_configuration_changes"
  project = var.project_id
  description = "Log metric for SQL instance configuration changes"
  filter = "resource.type=\"cloudsql_database\" AND protoPayload.methodName=\"cloudsql.instances.update\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  provider = google
  name   = "vpc_firewall_rule_changes"
  project = var.project_id
  description = "Log metric for VPC firewall rule changes"
  filter = "resource.type=\"gce_firewall_rule\" AND protoPayload.methodName=\"compute.firewalls.insert\" OR resource.type=\"gce_firewall_rule\" AND protoPayload.methodName=\"compute.firewalls.delete\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_logging_metric" "vpc_network_changes" {
  provider = google
  name   = "vpc_network_changes"
  project = var.project_id
  description = "Log metric for VPC network changes"
  filter = "resource.type=\"gce_network\" AND protoPayload.methodName=\"compute.networks.insert\" OR resource.type=\"gce_network\" AND protoPayload.methodName=\"compute.networks.delete\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_logging_metric" "vpc_network_route_changes" {
  provider = google
  name   = "vpc_network_route_changes"
  project = var.project_id
  description = "Log metric for VPC network route changes"
  filter = "resource.type=\"gce_route\" AND protoPayload.methodName=\"compute.routes.insert\" OR resource.type=\"gce_route\" AND protoPayload.methodName=\"compute.routes.delete\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}


resource "google_project_iam_custom_role" "service_account_separation_of_duties" {
  provider = google
  project     = var.project_id
  role_id     = "serviceAccountSeparationOfDuties"
  title       = "Service Account Separation of Duties"
  description = "Enforces separation of duties for service account related roles."
  permissions = [
    "iam.serviceAccounts.actAs",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.list",
  ]
}

resource "google_project_iam_audit_config" "default" {
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

resource "google_cloudfunctions_function_iam_binding" "cloud_function_invoker" {
  provider = google
  project = var.project_id
  cloud_function = "example-function"
  region = "us-central1"
  role = "roles/cloudfunctions.invoker"
  members = [
    "allUsers",
  ]
}

resource "google_cloudfunctions_function" "function" {
  provider = google
  project = var.project_id
  name        = "example-function"
  description = "a new function"
  region      = "us-central1"

  available_memory_mb   = 256
  runtime               = "nodejs16"
  timeout               = 60

  source_archive_bucket = "gcp-project-id-gcf-source"
  source_archive_object = "archive.zip"
  trigger_http          = true
}


resource "google_storage_bucket" "gcf_source" {
  provider = google
  project  = var.project_id
  name     = "${var.project_id}-gcf-source"
  location = "US"
  force_destroy = true
}

resource "google_project_iam_binding" "no_service_account_user" {
  provider = google
  project = var.project_id
  role = "roles/iam.serviceAccountUser"
  members = []
}

resource "google_project_iam_binding" "no_service_account_token_creator" {
  provider = google
  project = var.project_id
  role = "roles/iam.serviceAccountTokenCreator"
  members = []
}

resource "google_organization_policy" "disable_service_account_creation" {
  provider = google
  org_id = "123456789"
  policy_type = "iam.disableServiceAccountCreation"

  boolean_policy {
    enforced = true
  }
}

resource "google_project_iam_binding" "default_compute_service_account_no_admin" {
  provider = google
  project = var.project_id
  role = "roles/compute.instanceAdmin.v1"
  members = ["serviceAccount:30647320905-compute@developer.gserviceaccount.com"]
}

resource "google_project_iam_binding" "app_engine_default_service_account_no_admin" {
  provider = google
  project = var.project_id
  role = "roles/appengine.appAdmin"
  members = ["serviceAccount:aviato-game-fight-rvxirf@appspot.gserviceaccount.com"]
}

resource "google_project_iam_binding" "firebase_admin_sdk_no_admin" {
  provider = google
  project = var.project_id
  role = "roles/firebaserules.rulesAdmin"
  members = ["serviceAccount:firebase-adminsdk-d21rv@aviato-game-fight-rvxirf.iam.gserviceaccount.com"]
}

resource "google_project_iam_binding" "twitch_login_no_admin" {
  provider = google
  project = var.project_id
  role = "roles/viewer"
  members = ["serviceAccount:twitch-login@aviato-game-fight-rvxirf.iam.gserviceaccount.com"]
}

resource "google_project_default_service_accounts" "default" {
  provider = google
  project = var.project_id
  action = "DISABLE"
}

resource "google_apikeys_key" "api_key" {
  provider = google
  project     = var.project_id
  name        = "secure-api-key"
  restrictions {
    api_targets {
      service = "translate.googleapis.com"
      methods = ["translate"]
    }
  }
}

resource "google_apikeys_key" "browser_key" {
  provider = google
  project     = var.project_id
  name        = "rotated-browser-key"
  restrictions {
    browser_key {
      allowed_referrers = ["http://localhost/*"]
    }
  }
}

resource "google_project_default_network_tier" "default" {
  provider = google
  project  = var.project_id
  network_tier = "PREMIUM"
}

resource "google_compute_subnetwork" "default" {
  provider = google
  for_each = toset(var.regions)
  name                     = "default-${each.key}"
  ip_cidr_range            = "10.10.10.0/24"
  region                   = each.key
  network                  = "default"
  private_ip_google_access = true
  project                  = var.project_id
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_storage_bucket" "appspot_bucket" {
  provider = google
  project  = var.project_id
  name     = "${var.project_id}.appspot.com"
  location = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
  force_destroy = true
}

resource "google_storage_bucket" "staging_appspot_bucket" {
  provider = google
  project  = var.project_id
  name     = "staging.${var.project_id}.appspot.com"
  location = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
  force_destroy = true
}

resource "google_storage_bucket" "us_bucket" {
  provider = google
  project  = var.project_id
  name     = "${var.project_id}_bucket"
  location = "US"
  uniform_bucket_level_access = true
  force_destroy = true
}
