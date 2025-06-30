terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service_identity" "gcr_sa" {
  provider = google
  project  = var.project_id
  service  = "containerregistry.googleapis.com"
}

resource "google_project_iam_member" "artifactregistry" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_project_service_identity.gcr_sa.email}"
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
  depends_on = [google_project_iam_member.artifactregistry, google_project_service.artifactregistry]
}

resource "google_container_analysis_occurrence" "note_iam_binding" {
  project  = var.project_id
  note_name   = "projects/${var.project_id}/notes/container-scan-note"
  resource_uri = "https://gcr.io/${var.project_id}/test-image"
}

resource "google_project_service" "cloudasset" {
  provider = google
  project  = var.project_id
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_organization_policy" "org_policy" {
  project  = var.project_id
  constraint = "constraints/compute.disableGuestAttributesAccess"

  boolean_policy {
    enforced = true
  }
}

resource "google_compute_project_metadata" "metadata" {
  project = var.project_id

  metadata = {
    enable-oslogin = "true"
  }
}

resource "google_compute_network" "default" {
  name                    = "default"
  project                 = var.project_id
  auto_create_subnetworks = "false"
  delete_default_routes = "true"
}

resource "google_compute_network" "vpc_network" {
  name                    = "vpc-network"
  project                 = var.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default_subnets" {
  for_each = toset(var.default_subnets)

  name                     = "default-${each.value}"
  ip_cidr_range            = "10.10.0.0/20"
  network                  = google_compute_network.vpc_network.id
  project                  = var.project_id
  region                   = each.value
  private_ip_google_access = true
  flow_logs = true
}

resource "google_dns_managed_zone" "private_zone" {
  name         = "private-zone"
  dns_name     = "example.com."
  description  = "Private DNS zone for VPC network"
  project      = var.project_id
  visibility   = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc_network.id
    }
  }
}

resource "google_project_service" "dns" {
  provider = google
  project  = var.project_id
  service            = "dns.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_firewall" "rdp" {
  name    = "default-allow-rdp"
  project = var.project_id
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  source_ranges = ["10.0.0.0/8", "192.168.0.0/16"]
}

resource "google_compute_firewall" "ssh" {
  name    = "default-allow-ssh"
  project = var.project_id
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["10.0.0.0/8", "192.168.0.0/16"]
}

resource "google_storage_bucket" "buckets" {
  for_each = toset(var.bucket_names)
  name          = each.value
  project       = var.project_id
  location      = "US"
  uniform_bucket_level_access = true
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

resource "google_project_iam_custom_role" "custom_role" {
  project     = var.project_id
  role_id     = "custom_role"
  title       = "Custom Role"
  description = "A custom role for separation of duties."
  permissions = ["compute.instances.get"]
}

resource "google_logging_project_sink" "default" {
  name = "all-logs"
  project = var.project_id
  destination = "storage.googleapis.com/${var.project_id}-all-logs"
  filter = "NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Fdata_access"
}

resource "google_logging_metric" "audit_configuration_changes" {
  name        = "audit-configuration-changes"
  project = var.project_id
  description = "Metric for audit configuration changes"
  filter      = "resource.type=audited_resource AND protoPayload.methodName=google.iam.admin.v1.CreateServiceAccount"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "audit_configuration_changes_alert" {
  display_name = "Alert for Audit Configuration Changes"
  project = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/audit-configuration-changes\" resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "bucket_permission_changes" {
  name        = "bucket-permission-changes"
  project = var.project_id
  description = "Metric for bucket permission changes"
  filter      = "resource.type=gcs_bucket AND protoPayload.methodName=storage.setIamPermissions"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes_alert" {
  display_name = "Alert for Cloud Storage Bucket Permission Changes"
  project = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/bucket-permission-changes\" resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "custom_role_changes" {
  name        = "custom-role-changes"
  project = var.project_id
  description = "Metric for custom role changes"
  filter      = "resource.type=iam_role AND protoPayload.methodName=google.iam.admin.v1.CreateRole"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes_alert" {
  display_name = "Alert for Custom Role Changes"
  project = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/custom-role-changes\" resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "project_ownership_changes" {
  name        = "project-ownership-changes"
  project = var.project_id
  description = "Metric for project ownership changes"
  filter      = "resource.type=project AND protoPayload.methodName=google.resourcemanager.v1.SetIamPolicy"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes_alert" {
  display_name = "Alert for Project Ownership Changes"
  project = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/project-ownership-changes\" resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "sql_instance_configuration_changes" {
  name        = "sql-instance-configuration-changes"
  project = var.project_id
  description = "Metric for SQL instance configuration changes"
  filter      = "resource.type=cloudsql_instance AND protoPayload.methodName=cloudsql.instances.update"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "sql_instance_configuration_changes_alert" {
  display_name = "Alert for SQL Instance Configuration Changes"
  project = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/sql-instance-configuration-changes\" resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  name        = "vpc-firewall-rule-changes"
  project = var.project_id
  description = "Metric for VPC firewall rule changes"
  filter      = "resource.type=gce_firewall_rule AND protoPayload.methodName=compute.firewalls.insert"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes_alert" {
  display_name = "Alert for VPC Network Firewall Rule Changes"
  project = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-firewall-rule-changes\" resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_network_changes" {
  name        = "vpc-network-changes"
  project = var.project_id
  description = "Metric for VPC network changes"
  filter      = "resource.type=gce_network AND protoPayload.methodName=compute.networks.insert"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes_alert" {
  display_name = "Alert for VPC Network Changes"
  project = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-changes\" resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_network_route_changes" {
  name        = "vpc-network-route-changes"
  project = var.project_id
  description = "Metric for VPC network route changes"
  filter      = "resource.type=gce_route AND protoPayload.methodName=compute.routes.insert"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes_alert" {
  display_name = "Alert for VPC Network Route Changes"
  project = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-route-changes\" resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }
  notification_channels = []
}
