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

resource "google_compute_firewall" "rdp" {
  name    = var.default_rdp_ssh_firewall_name
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["10.128.0.0/9"]
}

resource "google_compute_firewall" "ssh" {
  name    = var.default_ssh_firewall_name
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["10.128.0.0/9"]
}

resource "google_compute_network" "default" {
  name                    = "default"
  project                 = var.project_id
  auto_create_subnetworks = false
  delete_default_routes = true
}

resource "google_project_default_network" "default_network" {
  project = var.project_id
  action  = "DELETE"
}

resource "google_compute_network" "default_network_dns_logging" {
  name                    = "default"
  project                 = var.project_id
  delete_default_routes = true
  dns_logging_policy      = "on"
}

resource "google_compute_subnetwork" "default_subnet_flow_logs" {
  for_each = toset(var.regions)
  name                     = "default"
  ip_cidr_range          = "10.128.0.0/20"
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

resource "google_project_metadata" "oslogin" {
  project = var.project_id

  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_artifact_registry_repository" "artifact_repository" {
  project = var.project_id
  location = "us-central1"
  repository_id = "container-analysis"
  description = "repository for container analysis"
  format = "DOCKER"
}

resource "google_container_analysis_occurrence" "container_analysis" {
  project = var.project_id
  note_name = "projects/goog-analysis/notes/PACKAGE_VULNERABILITY"
  resource_uri = "https://gcr.io/cloud-marketplace/nginx:latest"

  remediation = "Upgrade to a non-vulnerable version of the package."
}

resource "google_container_analysis_note" "container_analysis_note" {
  project = var.project_id
  name = "PACKAGE_VULNERABILITY"

  vulnerability {
    details {
      type = "cve"
      severity = "HIGH"
      affected_version_end {
        kind = "NORMAL"
        major = 1
        minor = 14
      }
    }
  }
}

resource "google_container_registry" "container_registry" {
  project = var.project_id
  location = "us"
  name = "gcr.io"
}

resource "google_project_service_identity" "gcr_service_account" {
  project = var.project_id
  service = "containerregistry.googleapis.com"
}

resource "google_cloudfunctions2_function" "cloud_function" {
  project = var.project_id
  name = "gcr-container-scanning"
  location = "us-central1"
  build_config {
    entry_point = "hello_http"
    runtime = "python39"
    source {
      storage_source {
        bucket = "gcr-container-scanning-source"
        object = "main.zip"
      }
    }
  }
  service_config {
    max_instance_count = 1
    min_instance_count = 0
    available_memory = "256M"
    timeout_seconds = 60
  }
}

resource "google_project_service" "container_analysis_api" {
  project = var.project_id
  service = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudasset_api" {
  project = var.project_id
  service = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_organization_policy" "disable_service_account_token_creation" {
  constraint = "iam.disableServiceAccountTokenCreation"
  org_id     = "YOUR_ORG_ID"
  policy_type = "boolean"

  boolean_policy {
    enforced = true
  }
}

resource "google_organization_policy" "disable_service_account_user" {
  constraint = "iam.disableServiceAccountUser"
  org_id     = "YOUR_ORG_ID"
  policy_type = "boolean"

  boolean_policy {
    enforced = true
  }
}

resource "google_project_iam_binding" "service_account_binding" {
  project = var.project_id
  role    = "roles/viewer"
  members = [
    "serviceAccount:twitch-login@aviato-game-fight-rvxirf.iam.gserviceaccount.com",
    "serviceAccount:aviato-game-fight-rvxirf@appspot.gserviceaccount.com",
    "serviceAccount:30647320905-compute@developer.gserviceaccount.com",
    "serviceAccount:firebase-adminsdk-d21rv@aviato-game-fight-rvxirf.iam.gserviceaccount.com"
  ]
}

resource "google_project_iam_audit_config" "audit_config" {
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

resource "google_logging_metric" "audit_config_changes" {
  name        = "audit-config-changes"
  project     = var.project_id
  description = "Log metric for audit configuration changes"
  filter      = "resource.type=audited_resource AND protoPayload.methodName=google.iam.admin.v1.SetIamPolicy AND protoPayload.serviceName=iam.googleapis.com"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_logging_metric" "bucket_permission_changes" {
  name        = "bucket-permission-changes"
  project     = var.project_id
  description = "Log metric for bucket permission changes"
  filter      = "resource.type=gcs_bucket AND protoPayload.methodName=storage.setIamPermissions"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_logging_metric" "custom_role_changes" {
  name        = "custom-role-changes"
  project     = var.project_id
  description = "Log metric for custom role changes"
  filter      = "resource.type=iam_role AND protoPayload.methodName=google.iam.admin.v1.CreateRole OR protoPayload.methodName=google.iam.admin.v1.UpdateRole OR protoPayload.methodName=google.iam.admin.v1.DeleteRole"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_logging_metric" "project_ownership_changes" {
  name        = "project-ownership-changes"
  project     = var.project_id
  description = "Log metric for project ownership changes"
  filter      = "resource.type=project AND protoPayload.methodName=google.cloudresourcemanager.v1.SetIamPolicy"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_logging_metric" "sql_instance_configuration_changes" {
  name        = "sql-instance-config-changes"
  project     = var.project_id
  description = "Log metric for sql instance config changes"
  filter      = "resource.type=cloudsql_instance AND protoPayload.methodName=cloudsql.instances.update"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  name        = "vpc-firewall-rule-changes"
  project     = var.project_id
  description = "Log metric for vpc firewall rule changes"
  filter      = "resource.type=gce_firewall_rule AND protoPayload.methodName=compute.firewalls.insert OR protoPayload.methodName=compute.firewalls.delete"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_logging_metric" "vpc_network_changes" {
  name        = "vpc-network-changes"
  project     = var.project_id
  description = "Log metric for vpc network changes"
  filter      = "resource.type=gce_network AND protoPayload.methodName=compute.networks.insert OR protoPayload.methodName=compute.networks.delete"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_logging_metric" "vpc_network_route_changes" {
  name        = "vpc-network-route-changes"
  project     = var.project_id
  description = "Log metric for vpc network route changes"
  filter      = "resource.type=gce_route AND protoPayload.methodName=compute.routes.insert OR protoPayload.methodName=compute.routes.delete"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_project_iam_member" "logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:p1234567890@gcp-sa-logging.iam.gserviceaccount.com"
}

resource "google_logging_project_sink" "default_sink" {
  name = "all-logs"
  project = var.project_id
  description = "Sink for exporting all log entries"
  destination = "storage.googleapis.com/your-bucket-name"
  filter = "NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity"
  unique_writer_identity = true
}

resource "google_storage_bucket" "buckets" {
  for_each = toset(var.bucket_names)
  name          = each.value
  project       = var.project_id
  location      = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}
