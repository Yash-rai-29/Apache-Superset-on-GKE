terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.15.0"
    }
  }
}

provider "google" {
  project = "aviato-game-fight-rvxirf"
  region  = "us-central1"
}

resource "google_project_iam_member" "project" {
  project = "aviato-game-fight-rvxirf"
  role    = "roles/owner"
  member  = "user:example@example.com"
}

resource "google_compute_network" "default" {
  name                    = "default"
  project                 = "aviato-game-fight-rvxirf"
  auto_create_subnetworks = false
  delete_default_routes   = true
}

resource "google_compute_firewall" "rdp" {
  name    = "default-allow-rdp"
  network = "default"
  project = "aviato-game-fight-rvxirf"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  direction = "INGRESS"

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]
}

resource "google_compute_firewall" "ssh" {
  name    = "default-allow-ssh"
  network = "default"
  project = "aviato-game-fight-rvxirf"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction = "INGRESS"

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]
}

resource "google_compute_subnetwork" "default" {
  for_each = {
    "africa-south1"     = "africa-south1"
    "southamerica-west1" = "southamerica-west1"
    "us-west4"           = "us-west4"
    "me-central2"        = "me-central2"
    "asia-east2"         = "asia-east2"
    "asia-northeast1"    = "asia-northeast1"
    "asia-south2"        = "asia-south2"
    "asia-northeast3"    = "asia-northeast3"
    "us-south1"          = "us-south1"
    "australia-southeast1" = "australia-southeast1"
    "us-east4"           = "us-east4"
    "us-west3"           = "us-west3"
    "asia-southeast1"    = "asia-southeast1"
    "europe-southwest1"  = "europe-southwest1"
    "asia-east1"         = "asia-east1"
    "europe-north2"      = "europe-north2"
    "australia-southeast2" = "australia-southeast2"
    "northamerica-northeast2" = "northamerica-northeast2"
    "asia-southeast2"    = "asia-southeast2"
    "northamerica-northeast1" = "northamerica-northeast1"
    "asia-south1"        = "asia-south1"
    "europe-west6"       = "europe-west6"
    "europe-west1"       = "europe-west1"
    "southamerica-east1" = "southamerica-east1"
    "asia-northeast2"    = "asia-northeast2"
    "europe-north1"      = "europe-north1"
    "us-east5"           = "us-east5"
    "us-west2"           = "us-west2"
    "us-west1"           = "us-west1"
    "europe-west10"      = "europe-west10"
    "us-central1"        = "us-central1"
    "northamerica-south1" = "northamerica-south1"
    "europe-west4"       = "europe-west4"
    "europe-west9"       = "europe-west9"
    "europe-west2"       = "europe-west2"
    "europe-west12"      = "europe-west12"
    "europe-west8"       = "europe-west8"
    "me-central1"        = "me-central1"
    "europe-west3"       = "europe-west3"
    "us-east1"           = "us-east1"
    "europe-central2"    = "europe-central2"
    "me-west1"           = "me-west1"
  }

  name                     = "default-${each.value}"
  ip_cidr_range            = "10.10.10.0/24"
  network                  = "default"
  region                   = each.value
  project                  = "aviato-game-fight-rvxirf"
  private_ip_google_access = true
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_project_service" "artifactregistry" {
  project = "aviato-game-fight-rvxirf"
  service = "artifactregistry.googleapis.com"
}

resource "google_artifact_registry_repository" "my-repo" {
  project             = "aviato-game-fight-rvxirf"
  location            = "us-central1"
  repository_id       = "my-repo"
  description         = "Terraform-managed repository."
  format              = "DOCKER"

  depends_on = [google_project_service.artifactregistry]
}

resource "google_container_analysis_occurrence" "vulnz_scan" {
  project  = "aviato-game-fight-rvxirf"
  note_name = "projects/goog-analysis/notes/PACKAGE_VULNERABILITY"
  resource_uri = "goog-analysis/PACKAGE_VULNERABILITY"
}

resource "google_project_service" "containeranalysis" {
  project = "aviato-game-fight-rvxirf"
  service = "containeranalysis.googleapis.com"
}

resource "google_project_service" "containerregistry" {
  project = "aviato-game-fight-rvxirf"
  service = "containerregistry.googleapis.com"
}

resource "google_storage_bucket" "bucket" {
  for_each = toset(["aviato-game-fight-rvxirf.appspot.com", "aviato-game-fight-rvxirf_bucket", "staging.aviato-game-fight-rvxirf.appspot.com"])

  name          = each.value
  project       = "aviato-game-fight-rvxirf"
  location      = "US"
  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_project_service_identity" "gcs_service_account" {
  project = "aviato-game-fight-rvxirf"
  service = "storage.googleapis.com"
}

resource "google_project_service" "cloudasset" {
  project = "aviato-game-fight-rvxirf"
  service = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "oslogin" {
  project = "aviato-game-fight-rvxirf"
  service = "oslogin.googleapis.com"
}

resource "google_compute_project_metadata" "default" {
  project = "aviato-game-fight-rvxirf"
  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_project_iam_binding" "service_account_token_creator" {
  project = "aviato-game-fight-rvxirf"
  role    = "roles/iam.serviceAccountTokenCreator"
  members = []
}

resource "google_project_iam_binding" "service_account_user" {
  project = "aviato-game-fight-rvxirf"
  role    = "roles/iam.serviceAccountUser"
  members = []
}

resource "google_project_iam_member" "no_admin_twitch" {
  project = "aviato-game-fight-rvxirf"
  role    = "roles/viewer"
  member  = "serviceAccount:twitch-login@aviato-game-fight-rvxirf.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "no_admin_appspot" {
  project = "aviato-game-fight-rvxirf"
  role    = "roles/viewer"
  member  = "serviceAccount:aviato-game-fight-rvxirf@appspot.gserviceaccount.com"
}

resource "google_project_iam_member" "no_admin_compute" {
  project = "aviato-game-fight-rvxirf"
  role    = "roles/viewer"
  member  = "serviceAccount:30647320905-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "no_admin_firebase" {
  project = "aviato-game-fight-rvxirf"
  role    = "roles/viewer"
  member  = "serviceAccount:firebase-adminsdk-d21rv@aviato-game-fight-rvxirf.iam.gserviceaccount.com"
}

resource "google_project_iam_custom_role" "custom_role" {
  project     = "aviato-game-fight-rvxirf"
  role_id     = "custom_service_account_role"
  title       = "Custom Service Account Role"
  description = "A custom role for service accounts with limited permissions."
  permissions = [
    "iam.serviceAccounts.actAs",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.list",
  ]
}

data "google_project" "project" {
  project_id = "aviato-game-fight-rvxirf"
}

resource "google_logging_project_sink" "log_sink" {
  name = "all-logs-sink"
  project = data.google_project.project.project_id
  destination = "storage.googleapis.com/${data.google_project.project.project_id}-log-bucket"
  filter = "severity>=INFO"

  unique_writer_identity = true
}

resource "google_storage_bucket" "log_bucket" {
  name = "${data.google_project.project.project_id}-log-bucket"
  project       = data.google_project.project.project_id
  location      = "US"
  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_project_iam_binding" "logging_bucket_writer" {
  project = data.google_project.project.project_id
  role    = "roles/storage.objectCreator"
  members = ["serviceAccount:${google_logging_project_sink.log_sink.writer_identity}"]
}

resource "google_logging_metric" "audit_config_changes" {
  name   = "audit-config-changes"
  project = "aviato-game-fight-rvxirf"
  description = "Records changes to audit logging configuration."
  filter = "resource.type=audited_resource AND protoPayload.methodName=google.cloud.audit.AuditLogs.UpdateAuditConfig"
  metric_descriptor {
      launch_stage = "BETA"
      metric_kind = "COUNTER"
      value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "audit_config_changes_alert" {
  project = "aviato-game-fight-rvxirf"
  display_name = "Audit Configuration Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "Audit Configuration Changes"
    condition_threshold {
      filter     = "metric.type = \"logging.googleapis.com/user/audit-config-changes\" AND metric.label.\"project_id\" = \"${data.google_project.project.project_id}\""
      comparison = "COMPARISON_GT"
      threshold_value  = 0
      duration   = "0s"
      trigger {
        count  = 1
      }
    }
  }
}

resource "google_logging_metric" "bucket_permission_changes" {
  name   = "bucket-permission-changes"
  project = "aviato-game-fight-rvxirf"
  description = "Records changes to Cloud Storage bucket permissions."
  filter = "resource.type=gcs_bucket AND protoPayload.methodName=storage.setIamPermissions"
  metric_descriptor {
      launch_stage = "BETA"
      metric_kind = "COUNTER"
      value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes_alert" {
  project = "aviato-game-fight-rvxirf"
  display_name = "Cloud Storage Bucket Permission Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "Cloud Storage Bucket Permission Changes"
    condition_threshold {
      filter     = "metric.type = \"logging.googleapis.com/user/bucket-permission-changes\" AND metric.label.\"project_id\" = \"${data.google_project.project.project_id}\""
      comparison = "COMPARISON_GT"
      threshold_value  = 0
      duration   = "0s"
      trigger {
        count  = 1
      }
    }
  }
}

resource "google_logging_metric" "custom_role_changes" {
  name   = "custom-role-changes"
  project = "aviato-game-fight-rvxirf"
  description = "Records changes to custom IAM roles."
  filter = "resource.type=iam_role AND protoPayload.methodName=google.iam.v1.Roles.UpdateRole"
  metric_descriptor {
      launch_stage = "BETA"
      metric_kind = "COUNTER"
      value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes_alert" {
  project = "aviato-game-fight-rvxirf"
  display_name = "Custom IAM Role Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "Custom IAM Role Changes"
    condition_threshold {
      filter     = "metric.type = \"logging.googleapis.com/user/custom-role-changes\" AND metric.label.\"project_id\" = \"${data.google_project.project.project_id}\""
      comparison = "COMPARISON_GT"
      threshold_value  = 0
      duration   = "0s"
      trigger {
        count  = 1
      }
    }
  }
}

resource "google_logging_metric" "project_ownership_changes" {
  name   = "project-ownership-changes"
  project = "aviato-game-fight-rvxirf"
  description = "Records changes to project ownership."
  filter = "resource.type=project AND protoPayload.methodName=SetIamPolicy"
  metric_descriptor {
      launch_stage = "BETA"
      metric_kind = "COUNTER"
      value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes_alert" {
  project = "aviato-game-fight-rvxirf"
  display_name = "Project Ownership Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "Project Ownership Changes"
    condition_threshold {
      filter     = "metric.type = \"logging.googleapis.com/user/project-ownership-changes\" AND metric.label.\"project_id\" = \"${data.google_project.project.project_id}\""
      comparison = "COMPARISON_GT"
      threshold_value  = 0
      duration   = "0s"
      trigger {
        count  = 1
      }
    }
  }
}

resource "google_logging_metric" "sql_instance_config_changes" {
  name   = "sql-instance-config-changes"
  project = "aviato-game-fight-rvxirf"
  description = "Records changes to SQL instance configuration."
  filter = "resource.type=cloudsql_instance AND protoPayload.methodName=cloudsql.instances.update"
  metric_descriptor {
      launch_stage = "BETA"
      metric_kind = "COUNTER"
      value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "sql_instance_config_changes_alert" {
  project = "aviato-game-fight-rvxirf"
  display_name = "SQL Instance Configuration Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "SQL Instance Configuration Changes"
    condition_threshold {
      filter     = "metric.type = \"logging.googleapis.com/user/sql-instance-config-changes\" AND metric.label.\"project_id\" = \"${data.google_project.project.project_id}\""
      comparison = "COMPARISON_GT"
      threshold_value  = 0
      duration   = "0s"
      trigger {
        count  = 1
      }
    }
  }
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  name   = "vpc-firewall-rule-changes"
  project = "aviato-game-fight-rvxirf"
  description = "Records changes to VPC firewall rules."
  filter = "resource.type=gce_firewall_rule AND protoPayload.methodName=compute.firewalls.insert"
  metric_descriptor {
      launch_stage = "BETA"
      metric_kind = "COUNTER"
      value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes_alert" {
  project = "aviato-game-fight-rvxirf"
  display_name = "VPC Firewall Rule Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "VPC Firewall Rule Changes"
    condition_threshold {
      filter     = "metric.type = \"logging.googleapis.com/user/vpc-firewall-rule-changes\" AND metric.label.\"project_id\" = \"${data.google_project.project.project_id}\""
      comparison = "COMPARISON_GT"
      threshold_value  = 0
      duration   = "0s"
      trigger {
        count  = 1
      }
    }
  }
}

resource "google_logging_metric" "vpc_network_changes" {
  name   = "vpc-network-changes"
  project = "aviato-game-fight-rvxirf"
  description = "Records changes to VPC networks."
  filter = "resource.type=gce_network AND protoPayload.methodName=compute.networks.insert"
  metric_descriptor {
      launch_stage = "BETA"
      metric_kind = "COUNTER"
      value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes_alert" {
  project = "aviato-game-fight-rvxirf"
  display_name = "VPC Network Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "VPC Network Changes"
    condition_threshold {
      filter     = "metric.type = \"logging.googleapis.com/user/vpc-network-changes\" AND metric.label.\"project_id\" = \"${data.google_project.project.project_id}\""
      comparison = "COMPARISON_GT"
      threshold_value  = 0
      duration   = "0s"
      trigger {
        count  = 1
      }
    }
  }
}

resource "google_logging_metric" "vpc_network_route_changes" {
  name   = "vpc-network-route-changes"
  project = "aviato-game-fight-rvxirf"
  description = "Records changes to VPC network routes."
  filter = "resource.type=gce_route AND protoPayload.methodName=compute.routes.insert"
  metric_descriptor {
      launch_stage = "BETA"
      metric_kind = "COUNTER"
      value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes_alert" {
  project = "aviato-game-fight-rvxirf"
  display_name = "VPC Network Route Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "VPC Network Route Changes"
    condition_threshold {
      filter     = "metric.type = \"logging.googleapis.com/user/vpc-network-route-changes\" AND metric.label.\"project_id\" = \"${data.google_project.project.project_id}\""
      comparison = "COMPARISON_GT"
      threshold_value  = 0
      duration   = "0s"
      trigger {
        count  = 1
      }
    }
  }
}

resource "google_project_service" "dns" {
    project = "aviato-game-fight-rvxirf"
    service = "dns.googleapis.com"
    disable_on_destroy = false
}

resource "google_compute_network" "dns_default" {
  name                    = "default"
  project                 = "aviato-game-fight-rvxirf"
  delete_default_routes   = true
  depends_on = [google_project_service.dns]
  enable_logging          = true
}
