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

resource "google_project_service_identity" "gcr_sa" {
  provider = google
  project  = var.project_id
  service  = "containerregistry.googleapis.com"
}

resource "google_project_iam_member" "container_analysis" {
  project = var.project_id
  role    = "roles/containeranalysis.notes.occurrences.viewer"
  member  = "serviceAccount:${google_project_service_identity.gcr_sa.email}"
}


resource "google_container_analysis_occurrence" "container_analysis" {
  project               = var.project_id
  note_name             = "projects/${var.project_id}/notes/container-analysis-note"
  resource_uri          = "https://gcr.io/${var.project_id}/test-image"
  effective_severity    = "CRITICAL"
  remediation           = "upgrade the system"

  attestation {
    generic_signed_attestation {
      content_type = "APPLICATION_JSON"
      serialized_payload = jsonencode({
        "key1" : "value1",
        "key2" : "value2"
      })
      signatures {
        signature         = "signature"
        public_key_id     = "key-id"
      }
    }
  }
}

resource "google_project_service" "artifactregistry" {
  provider = google
  project            = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudasset" {
  provider = google
  project            = var.project_id
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "oslogin" {
  provider = google
  project            = var.project_id
  service            = "oslogin.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_project_metadata" "oslogin" {
  provider = google
  project = var.project_id

  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_firewall" "rdp" {
  project = var.project_id
  name    = "default-allow-rdp"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  direction = "INGRESS"
  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

resource "google_compute_firewall" "ssh" {
  project = var.project_id
  name    = "default-allow-ssh"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
   direction = "INGRESS"
  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

resource "google_compute_network" "default" {
  name                    = "default"
  project                 = var.project_id
  delete_default_routes = true
}

resource "google_compute_network_dns_policy" "dns_logging" {
  project = var.project_id
  name    = "default"
  network = "default"
  enable_logging = true
}

resource "google_logging_project_sink" "default_sink" {
  name        = "all-logs"
  project     = var.project_id
  destination = "storage.googleapis.com/${var.project_id}-logs-bucket"
  filter      = "NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Fdata_access"
}

resource "google_storage_bucket" "log_bucket" {
  name          = "${var.project_id}-logs-bucket"
  project       = var.project_id
  location      = "US"
  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_logging_metric" "audit_config_changes" {
  name        = "audit-config-changes"
  project     = var.project_id
  description = "Metric for audit configuration changes"
  filter      = "resource.type=audited_resource AND protoPayload.methodName=SetIamPolicy"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_monitoring_alert_policy" "audit_config_changes_alert" {
  project      = var.project_id
  display_name = "Audit Configuration Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "Audit Configuration Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/audit-config-changes\" resource.type=\"global\""
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "bucket_permission_changes" {
  name        = "bucket-permission-changes"
  project     = var.project_id
  description = "Metric for Cloud Storage IAM permission changes"
  filter      = "resource.type=gcs_bucket AND protoPayload.methodName=storage.setIamPermissions"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes_alert" {
  project      = var.project_id
  display_name = "Cloud Storage IAM Permission Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "Cloud Storage IAM Permission Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/bucket-permission-changes\" resource.type=\"gcs_bucket\""
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "custom_role_changes" {
  name        = "custom-role-changes"
  project     = var.project_id
  description = "Metric for Custom Role changes"
  filter      = "resource.type=iam_role AND protoPayload.methodName=google.iam.admin.v1.CreateRole"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes_alert" {
  project      = var.project_id
  display_name = "Custom Role Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "Custom Role Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/custom-role-changes\" resource.type=\"iam_role\""
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "project_ownership_changes" {
  name        = "project-ownership-changes"
  project     = var.project_id
  description = "Metric for Project Ownership Assignments/Changes"
  filter      = "resource.type=project AND protoPayload.methodName=SetIamPolicy AND protoPayload.serviceData.policyDelta.bindingDeltas.action=ADD AND protoPayload.serviceData.policyDelta.bindingDeltas.role=\"roles/owner\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes_alert" {
  project      = var.project_id
  display_name = "Project Ownership Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "Project Ownership Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/project-ownership-changes\" resource.type=\"project\""
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "sql_instance_config_changes" {
  name        = "sql-instance-config-changes"
  project     = var.project_id
  description = "Metric for SQL Instance Configuration Changes"
  filter      = "resource.type=cloudsql_instance AND protoPayload.methodName=cloudsql.instances.update"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_monitoring_alert_policy" "sql_instance_config_changes_alert" {
  project      = var.project_id
  display_name = "SQL Instance Configuration Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "SQL Instance Configuration Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/sql-instance-config-changes\" resource.type=\"cloudsql_instance\""
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  name        = "vpc-firewall-rule-changes"
  project     = var.project_id
  description = "Metric for VPC Network Firewall Rule Changes"
  filter      = "resource.type=gce_firewall_rule AND protoPayload.methodName=compute.firewalls.insert"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes_alert" {
  project      = var.project_id
  display_name = "VPC Network Firewall Rule Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "VPC Network Firewall Rule Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-firewall-rule-changes\" resource.type=\"gce_firewall_rule\""
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_network_changes" {
  name        = "vpc-network-changes"
  project     = var.project_id
  description = "Metric for VPC Network Changes"
  filter      = "resource.type=gce_network AND protoPayload.methodName=compute.networks.insert"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes_alert" {
  project      = var.project_id
  display_name = "VPC Network Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "VPC Network Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-changes\" resource.type=\"gce_network\""
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_network_route_changes" {
  name        = "vpc-network-route-changes"
  project     = var.project_id
  description = "Metric for VPC Network Route Changes"
  filter      = "resource.type=gce_route AND protoPayload.methodName=compute.routes.insert"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes_alert" {
  project      = var.project_id
  display_name = "VPC Network Route Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "VPC Network Route Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-route-changes\" resource.type=\"gce_route\""
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_project_iam_binding" "no_service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  members = []
}

resource "google_project_iam_binding" "no_service_account_token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  members = []
}

resource "google_project_iam_custom_role" "enforce_separation_of_duties" {
  project     = var.project_id
  role_id     = "separationOfDutiesRole"
  title       = "Separation of Duties Role"
  description = "Custom role to enforce separation of duties"
  permissions = [
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.list",
    "iam.serviceAccountKeys.create",
    "iam.serviceAccountKeys.delete",
  ]
}

resource "google_project_service" "container_scanning" {
  project = var.project_id
  service = "containerscanning.googleapis.com"
  disable_on_destroy = false
}

resource "google_storage_bucket" "buckets" {
  count     = length(var.bucket_names)
  name          = element(var.bucket_names, count.index)
  project       = var.project_id
  location      = "US"
  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_compute_subnet" "default_subnets" {
  for_each = toset(var.regions)
  name                     = "default"
  project                  = var.project_id
  region                   = each.value
  network                  = "default"
  ip_cidr_range            = "10.128.0.0/20"
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL"
  }
}
