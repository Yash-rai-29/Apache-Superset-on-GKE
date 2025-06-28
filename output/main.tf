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
  project  = var.project_id
  location = "us-central1"
  repository_id = "default"
  format = "DOCKER"
}

resource "google_container_analysis_occurrence" "note_att" {
  provider = google
  project  = var.project_id
  note = google_container_analysis_note.note.name
  kind = "VULNERABILITY"
  resource_uri = "us-central1-docker.pkg.dev/${var.project_id}/default/test-image:latest"

  attestation {
    generic_signed_attestation {
      content_type = "APPLICATION_JSON"
      signature {
        public_key_id = "key1"
        signature     = "test"
      }
    }
  }
}

resource "google_container_analysis_note" "note" {
  provider = google
  project  = var.project_id
  name = "test-attestation-note"

  attestation_authority {
    hint {
      human_readable_name = "Example Attestation Authority"
    }
  }
}

resource "google_project_service" "containeranalysis" {
  provider = google
  project            = var.project_id
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudasset" {
  provider = google
  project            = var.project_id
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "gcr" {
  provider = google
  project            = var.project_id
  service            = "containerregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_iam_member" "service_account_token_creator" {
  provider = google
  project = var.project_id
  role = "roles/iam.serviceAccountTokenCreator"
  member = "allUsers"
}

resource "google_project_iam_member" "service_account_user" {
  provider = google
  project = var.project_id
  role = "roles/iam.serviceAccountUser"
  member = "allUsers"
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
  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
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
  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

resource "google_compute_network" "default" {
  provider = google
  name                    = "default"
  project                 = var.project_id
  delete_default_routes = true
}

resource "google_compute_network" "default_dns_logging" {
  provider = google
  name                    = "default"
  project                 = var.project_id
  enable_dns_logging = true
}

resource "google_organization_policy" "oslogin" {
  provider  = google
  org_id    = "272137946959"
  policy_rules {
    enforce = "TRUE"
  }
  constraint = "compute.requireOsLogin"
}

resource "google_compute_subnetwork" "default_flow_logs" {
  provider = google
  for_each = toset(var.regions)
  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
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

resource "google_storage_bucket" "bucket_uba" {
  provider = google
  for_each = toset(var.bucket_names)
  name          = each.value
  project       = var.project_id
  location      = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}

resource "google_logging_metric" "audit_configuration_changes" {
  provider = google
  project      = var.project_id
  name         = "audit-configuration-changes"
  description  = "Metric for audit configuration changes"
  filter       = "protoPayload.methodName=\"google.cloud.audit.AuditLogs.UpdateAuditConfig\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_logging_metric" "bucket_permission_changes" {
  provider = google
  project      = var.project_id
  name         = "bucket-permission-changes"
  description  = "Metric for bucket permission changes"
  filter       = "resource.type=\"gcs_bucket\" AND protoPayload.methodName=\"storage.setIamPermissions\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_logging_metric" "custom_role_changes" {
  provider = google
  project      = var.project_id
  name         = "custom-role-changes"
  description  = "Metric for custom role changes"
  filter       = "protoPayload.methodName=\"google.iam.admin.v1.CreateRole\" OR protoPayload.methodName=\"google.iam.admin.v1.DeleteRole\" OR protoPayload.methodName=\"google.iam.admin.v1.UpdateRole\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_logging_metric" "project_ownership_changes" {
  provider = google
  project      = var.project_id
  name         = "project-ownership-changes"
  description  = "Metric for project ownership changes"
  filter       = "protoPayload.methodName=\"SetIamPolicy\" AND resource.type=\"project\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_logging_metric" "sql_instance_configuration_changes" {
  provider = google
  project      = var.project_id
  name         = "sql-instance-configuration-changes"
  description  = "Metric for SQL instance configuration changes"
  filter       = "resource.type=\"cloudsql_database\" AND protoPayload.methodName=\"cloudsql.instances.update\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  provider = google
  project      = var.project_id
  name         = "vpc-firewall-rule-changes"
  description  = "Metric for VPC firewall rule changes"
  filter       = "resource.type=\"gce_firewall_rule\" AND (protoPayload.methodName=\"compute.firewalls.insert\" OR protoPayload.methodName=\"compute.firewalls.delete\" OR protoPayload.methodName=\"compute.firewalls.patch\" OR protoPayload.methodName=\"compute.firewalls.update\")"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_logging_metric" "vpc_network_changes" {
  provider = google
  project      = var.project_id
  name         = "vpc-network-changes"
  description  = "Metric for VPC network changes"
  filter       = "resource.type=\"gce_network\" AND (protoPayload.methodName=\"compute.networks.insert\" OR protoPayload.methodName=\"compute.networks.delete\" OR protoPayload.methodName=\"compute.networks.patch\" OR protoPayload.methodName=\"compute.networks.update\")"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_logging_metric" "vpc_network_route_changes" {
  provider = google
  project      = var.project_id
  name         = "vpc-network-route-changes"
  description  = "Metric for VPC network route changes"
  filter       = "resource.type=\"gce_route\" AND (protoPayload.methodName=\"compute.routes.insert\" OR protoPayload.methodName=\"compute.routes.delete\")"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_logging_project_sink" "default_sink" {
  provider = google
  name        = "default-sink"
  project     = var.project_id
  destination = "storage.googleapis.com/${var.project_id}-logging-bucket"
  filter      = "severity>=INFO"
}
