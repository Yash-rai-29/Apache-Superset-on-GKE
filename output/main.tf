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
  region  = "us-central1"
}

resource "google_project_service_identity" "gcr_service_account" {
  provider = google
  project  = var.project_id
  service  = "containerregistry.googleapis.com"
}

resource "google_project_service_identity" "artifactregistry_service_account" {
  provider = google
  project  = var.project_id
  service  = "artifactregistry.googleapis.com"
}

resource "google_container_registry" "registry" {
  project  = var.project_id
  location = "US"
  depends_on = [google_project_service_identity.gcr_service_account]
}

resource "google_artifact_registry_repository" "default" {
  provider = google
  project = var.project_id
  location = "us-central1"
  repository_id = "default-repo"
  format = "DOCKER"
  depends_on = [google_project_service_identity.artifactregistry_service_account]
}

resource "google_project_service" "artifact_registry" {
  provider = google
  project = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudasset" {
  provider = google
  project  = var.project_id
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_iam_member" "cloudasset_sa" {
  project = var.project_id
  role    = "roles/cloudasset.serviceAgent"
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloudasset.iam.gserviceaccount.com"
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_compute_network" "default" {
  provider = google
  name                    = var.default_network_name
  project                 = var.project_id
  auto_create_subnetworks = false
  delete_default_routes = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_firewall" "default_allow_ssh" {
  provider = google
  name    = var.default_allow_ssh_firewall_rule_name
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]

  lifecycle {
    ignore_changes = [source_ranges]
  }
}

resource "google_compute_firewall" "default_allow_rdp" {
  provider = google
  name    = var.default_allow_rdp_firewall_rule_name
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["0.0.0.0/0"]
  lifecycle {
    ignore_changes = [source_ranges]
  }
}


resource "google_compute_subnetwork" "default_subnetworks" {
  for_each = toset(var.regions)

  name                     = "default"
  ip_cidr_range          = cidrsubnet("10.0.0.0/8", 8, index(toset(var.regions), each.value))
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

resource "google_project_default_service_accounts" "default_accounts" {
  provider = google
  project = var.project_id
  action = "DISABLE"
}

resource "google_project_organization_policy" "iam_allowed_policy_member_domains" {
  name = "iam.allowedPolicyMemberDomains"
  project = var.project_id
  constraint = "iam.allowedPolicyMemberDomains"

  list_policy {
    allow {
      all = true
    }
  }
}

resource "google_logging_project_sink" "default" {
  name        = "all-logs"
  project     = var.project_id
  destination = "storage.googleapis.com/${var.project_id}-all-logs"
  filter      = "NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Fdata_access"
}

resource "google_storage_bucket" "logging_bucket" {
  name          = "${var.project_id}-all-logs"
  project       = var.project_id
  location      = "US"
  force_destroy = true
}

resource "google_monitoring_alert_policy" "audit_configuration_changes" {
  display_name = "Audit Configuration Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/audit_configuration_changes\" AND resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
      trigger {
        count = 1
      }
    }
  }

  notification_channels = []
}

resource "google_logging_metric" "audit_configuration_changes" {
  name   = "audit_configuration_changes"
  project = var.project_id
  description = "Count of audit configuration changes"
  bucket_options {
    explicit_buckets {
      bounds = [
        1,
        2,
        3,
        4,
        5
      ]
    }
  }
  filter = "resource.type=gcp_project AND protoPayload.methodName:SetIamPolicy OR protoPayload.methodName:CreateServiceAccount OR protoPayload.methodName:DeleteServiceAccount OR protoPayload.methodName:UndeleteServiceAccount OR protoPayload.methodName:UpdateServiceAccount OR protoPayload.methodName:PatchServiceAccount OR protoPayload.methodName:DisableServiceAccount OR protoPayload.methodName:EnableServiceAccount OR protoPayload.methodName:GrantServiceAccountRoles OR protoPayload.methodName:RevokeServiceAccountRoles"
  metric_descriptor {
    launch_stage = "BETA"
    name         = "logging.googleapis.com/user/audit_configuration_changes"
    type         = "INT64"
    unit         = "1"
    value_type   = "INT64"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes" {
  display_name = "Cloud Storage IAM Permission Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/bucket_permission_changes\" AND resource.type=\"gcs_bucket\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
      trigger {
        count = 1
      }
    }
  }

  notification_channels = []
}

resource "google_logging_metric" "bucket_permission_changes" {
  name   = "bucket_permission_changes"
  project = var.project_id
  description = "Count of Cloud Storage IAM permission changes"
  bucket_options {
    explicit_buckets {
      bounds = [
        1,
        2,
        3,
        4,
        5
      ]
    }
  }
  filter = "resource.type=gcs_bucket AND protoPayload.methodName=storage.setIamPermissions"
  metric_descriptor {
    launch_stage = "BETA"
    name         = "logging.googleapis.com/user/bucket_permission_changes"
    type         = "INT64"
    unit         = "1"
    value_type   = "INT64"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes" {
  display_name = "Custom Role Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/custom_role_changes\" AND resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
      trigger {
        count = 1
      }
    }
  }

  notification_channels = []
}

resource "google_logging_metric" "custom_role_changes" {
  name   = "custom_role_changes"
  project = var.project_id
  description = "Count of custom role changes"
  bucket_options {
    explicit_buckets {
      bounds = [
        1,
        2,
        3,
        4,
        5
      ]
    }
  }
  filter = "resource.type=gcp_project AND protoPayload.methodName=iam.roles.create OR protoPayload.methodName=iam.roles.delete OR protoPayload.methodName=iam.roles.update"
  metric_descriptor {
    launch_stage = "BETA"
    name         = "logging.googleapis.com/user/custom_role_changes"
    type         = "INT64"
    unit         = "1"
    value_type   = "INT64"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes" {
  display_name = "Project Ownership Assignments/Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/project_ownership_changes\" AND resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
      trigger {
        count = 1
      }
    }
  }

  notification_channels = []
}

resource "google_logging_metric" "project_ownership_changes" {
  name   = "project_ownership_changes"
  project = var.project_id
  description = "Count of project ownership assignments/changes"
  bucket_options {
    explicit_buckets {
      bounds = [
        1,
        2,
        3,
        4,
        5
      ]
    }
  }
  filter = "resource.type=gcp_project AND protoPayload.methodName=SetIamPolicy AND protoPayload.request.policy.bindings:\"roles/owner\""
  metric_descriptor {
    launch_stage = "BETA"
    name         = "logging.googleapis.com/user/project_ownership_changes"
    type         = "INT64"
    unit         = "1"
    value_type   = "INT64"
  }
}

resource "google_monitoring_alert_policy" "sql_instance_configuration_changes" {
  display_name = "SQL Instance Configuration Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/sql_instance_configuration_changes\" AND resource.type=\"cloudsql_database\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
      trigger {
        count = 1
      }
    }
  }

  notification_channels = []
}

resource "google_logging_metric" "sql_instance_configuration_changes" {
  name   = "sql_instance_configuration_changes"
  project = var.project_id
  description = "Count of SQL instance configuration changes"
  bucket_options {
    explicit_buckets {
      bounds = [
        1,
        2,
        3,
        4,
        5
      ]
    }
  }
  filter = "resource.type=cloudsql_database AND protoPayload.methodName=cloudsql.instances.update"
  metric_descriptor {
    launch_stage = "BETA"
    name         = "logging.googleapis.com/user/sql_instance_configuration_changes"
    type         = "INT64"
    unit         = "1"
    value_type   = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes" {
  display_name = "VPC Network Firewall Rule Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc_firewall_rule_changes\" AND resource.type=\"gcp_firewall_rule\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
      trigger {
        count = 1
      }
    }
  }

  notification_channels = []
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  name   = "vpc_firewall_rule_changes"
  project = var.project_id
  description = "Count of VPC network firewall rule changes"
  bucket_options {
    explicit_buckets {
      bounds = [
        1,
        2,
        3,
        4,
        5
      ]
    }
  }
  filter = "resource.type=gcp_firewall_rule AND protoPayload.methodName=compute.firewalls.insert OR protoPayload.methodName=compute.firewalls.delete OR protoPayload.methodName=compute.firewalls.patch"
  metric_descriptor {
    launch_stage = "BETA"
    name         = "logging.googleapis.com/user/vpc_firewall_rule_changes"
    type         = "INT64"
    unit         = "1"
    value_type   = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes" {
  display_name = "VPC Network Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc_network_changes\" AND resource.type=\"gcp_network\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
      trigger {
        count = 1
      }
    }
  }

  notification_channels = []
}

resource "google_logging_metric" "vpc_network_changes" {
  name   = "vpc_network_changes"
  project = var.project_id
  description = "Count of VPC network changes"
  bucket_options {
    explicit_buckets {
      bounds = [
        1,
        2,
        3,
        4,
        5
      ]
    }
  }
  filter = "resource.type=gcp_network AND protoPayload.methodName=compute.networks.insert OR protoPayload.methodName=compute.networks.delete OR protoPayload.methodName=compute.networks.patch"
  metric_descriptor {
    launch_stage = "BETA"
    name         = "logging.googleapis.com/user/vpc_network_changes"
    type         = "INT64"
    unit         = "1"
    value_type   = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes" {
  display_name = "VPC Network Route Changes"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc_network_route_changes\" AND resource.type=\"gcp_route\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
      trigger {
        count = 1
      }
    }
  }

  notification_channels = []
}

resource "google_logging_metric" "vpc_network_route_changes" {
  name   = "vpc_network_route_changes"
  project = var.project_id
  description = "Count of VPC network route changes"
  bucket_options {
    explicit_buckets {
      bounds = [
        1,
        2,
        3,
        4,
        5
      ]
    }
  }
  filter = "resource.type=gcp_route AND protoPayload.methodName=compute.routes.insert OR protoPayload.methodName=compute.routes.delete"
  metric_descriptor {
    launch_stage = "BETA"
    name         = "logging.googleapis.com/user/vpc_network_route_changes"
    type         = "INT64"
    unit         = "1"
    value_type   = "INT64"
  }
}

resource "google_project_iam_binding" "service_account_token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  members = []
}

resource "google_project_iam_binding" "service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  members = []
}

resource "google_compute_project_metadata" "oslogin_enable" {
  project = var.project_id
  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_storage_bucket" "buckets" {
  for_each = toset(var.bucket_names)
  name          = each.value
  project       = var.project_id
  location      = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}

resource "google_project_iam_binding" "no_admin_privileges" {
  for_each = toset(var.service_accounts)
  project = var.project_id
  role = "roles/viewer"
  members = ["serviceAccount:${each.value}"]
}

resource "google_iam_service_account_key" "user_managed_keys" {
  for_each = toset(var.service_accounts)
  service_account_id = "projects/${var.project_id}/serviceAccounts/${each.value}"
  disabled = true
}

resource "google_compute_network_dns_logging_policy" "dns_logging" {
  project = var.project_id
  network = "default"
  logging_config {
      enable = true
  }
}
