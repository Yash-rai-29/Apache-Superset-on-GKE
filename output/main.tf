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

resource "google_project_service_identity" "gcr_sa" {
  provider = google
  project  = var.project_id
  service  = "containerregistry.googleapis.com"
}

resource "google_project_service" "artifactregistry" {
  provider           = google
  disable_on_destroy = false
  project            = var.project_id
  service            = "artifactregistry.googleapis.com"
}

resource "google_artifact_registry_repository" "default" {
  provider = google
  location = "us-central1"
  project  = var.project_id
  repository_id = "default-repository"
  format      = "DOCKER"
}

resource "google_project_iam_member" "artifactregistry_access" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_project_service_identity.gcr_sa.email}"
  depends_on = [google_project_service_identity.gcr_sa, google_project_service.artifactregistry]
}

resource "google_project_service" "cloudasset" {
  provider           = google
  disable_on_destroy = false
  project            = var.project_id
  service            = "cloudasset.googleapis.com"
}

resource "google_project_service" "oslogin" {
  provider           = google
  disable_on_destroy = false
  project            = var.project_id
  service            = "oslogin.googleapis.com"
}

resource "google_compute_project_metadata" "oslogin_enable" {
  provider = google
  project  = var.project_id

  metadata = {
    enable-oslogin = "TRUE"
  }
   depends_on = [google_project_service.oslogin]
}

resource "google_compute_network" "default" {
  provider = google
  name                    = "default"
  project                 = var.project_id
  delete_default_routes = true
}

resource "google_compute_network" "default_delete" {
  provider = google
  name                    = "default"
  project                 = var.project_id
  depends_on = [google_compute_network.default]
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_network" "vpc_network" {
  provider = google
  name                    = "vpc-network"
  project                 = var.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  provider = google
  name                     = "subnet-example"
  ip_cidr_range            = "10.10.10.0/24"
  network                  = google_compute_network.vpc_network.id
  project                  = var.project_id
  region                   = "us-central1"
}

resource "google_compute_firewall" "rdp" {
  provider = google
  name    = "disable-rdp-access"
  network = google_compute_network.vpc_network.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["10.0.0.0/8"]
}

resource "google_compute_firewall" "ssh" {
  provider = google
  name    = "disable-ssh-access"
  network = google_compute_network.vpc_network.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["10.0.0.0/8"]
}

resource "google_project_default_service_accounts" "default_accounts" {
  provider = google
  project = var.project_id
  action = "DISABLE"
}

resource "google_logging_project_sink" "default" {
  provider = google
  name = "all-logs"
  project = var.project_id
  destination = "storage.googleapis.com/${var.project_id}-all-logs"
  filter = "NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity"
}

resource "google_storage_bucket" "all_logs" {
  provider = google
  name = "${var.project_id}-all-logs"
  project = var.project_id
  location = "US"
}

resource "google_project_service" "dns" {
  provider           = google
  disable_on_destroy = false
  project            = var.project_id
  service            = "dns.googleapis.com"
}

resource "google_compute_network" "default_network" {
  provider = google
  name    = "default"
  project = var.project_id
  dns_logging_policy = "TRUE"

  depends_on = [google_project_service.dns]
}

resource "google_project_iam_binding" "no_sa_user" {
  provider = google
  project = var.project_id
  role = "roles/iam.serviceAccountUser"
  members = []
}

resource "google_project_iam_binding" "no_sa_token_creator" {
  provider = google
  project = var.project_id
  role = "roles/iam.serviceAccountTokenCreator"
  members = []
}

resource "google_storage_bucket" "buckets" {
  provider = google
  name          = "aviato-game-fight-rvxirf.appspot.com"
  location      = "AUSTRALIA-SOUTHEAST1"
  project       = var.project_id
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "buckets2" {
  provider = google
  name          = "aviato-game-fight-rvxirf_bucket"
  location      = "US"
  project       = var.project_id
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "buckets3" {
  provider = google
  name          = "staging.aviato-game-fight-rvxirf.appspot.com"
  location      = "AUSTRALIA-SOUTHEAST1"
  project       = var.project_id
  uniform_bucket_level_access = true
}

resource "google_project_iam_audit_config" "audit_config" {
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

resource "google_monitoring_alert_policy" "audit_configuration_changes" {
  provider = google
  display_name = "Audit Configuration Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter = "metric.type=\"logging.googleapis.com/user/audit_configuration_changes\" AND resource.type=\"gcp_project\""
      comparison = "COMPARISON_GT"
      duration = "60s"
      threshold_value = 0
      trigger {
        count = 1
      }
    }
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes" {
  provider = google
  display_name = "Cloud Storage IAM Permission Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter = "metric.type=\"logging.googleapis.com/user/bucket_permission_changes\" AND resource.type=\"gcp_project\""
      comparison = "COMPARISON_GT"
      duration = "60s"
      threshold_value = 0
      trigger {
        count = 1
      }
    }
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes" {
  provider = google
  display_name = "Custom Role Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter = "metric.type=\"logging.googleapis.com/user/custom_role_changes\" AND resource.type=\"gcp_project\""
      comparison = "COMPARISON_GT"
      duration = "60s"
      threshold_value = 0
      trigger {
        count = 1
      }
    }
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes" {
  provider = google
  display_name = "Project Ownership Assignments/Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter = "metric.type=\"logging.googleapis.com/user/project_ownership_changes\" AND resource.type=\"gcp_project\""
      comparison = "COMPARISON_GT"
      duration = "60s"
      threshold_value = 0
      trigger {
        count = 1
      }
    }
  }
}

resource "google_monitoring_alert_policy" "sql_instance_configuration_changes" {
  provider = google
  display_name = "SQL Instance Configuration Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter = "metric.type=\"logging.googleapis.com/user/sql_instance_configuration_changes\" AND resource.type=\"gcp_project\""
      comparison = "COMPARISON_GT"
      duration = "60s"
      threshold_value = 0
      trigger {
        count = 1
      }
    }
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes" {
  provider = google
  display_name = "VPC Network Firewall Rule Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter = "metric.type=\"logging.googleapis.com/user/vpc_firewall_rule_changes\" AND resource.type=\"gcp_project\""
      comparison = "COMPARISON_GT"
      duration = "60s"
      threshold_value = 0
      trigger {
        count = 1
      }
    }
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes" {
  provider = google
  display_name = "VPC Network Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter = "metric.type=\"logging.googleapis.com/user/vpc_network_changes\" AND resource.type=\"gcp_project\""
      comparison = "COMPARISON_GT"
      duration = "60s"
      threshold_value = 0
      trigger {
        count = 1
      }
    }
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes" {
  provider = google
  display_name = "VPC Network Route Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Log Metric Condition"
    condition_threshold {
      filter = "metric.type=\"logging.googleapis.com/user/vpc_network_route_changes\" AND resource.type=\"gcp_project\""
      comparison = "COMPARISON_GT"
      duration = "60s"
      threshold_value = 0
      trigger {
        count = 1
      }
    }
  }
}

resource "google_logging_metric" "audit_configuration_changes" {
  provider = google
  name = "audit-configuration-changes"
  project = var.project_id
  description = "Counts the number of audit configuration changes"
  filter = "protoPayload.methodName=\"SetIamPolicy\" OR protoPayload.methodName=\"google.cloud.audit.AuditPolicies.UpdateAuditConfig\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_logging_metric" "bucket_permission_changes" {
  provider = google
  name = "bucket-permission-changes"
  project = var.project_id
  description = "Counts the number of bucket permission changes"
  filter = "resource.type=\"gcs_bucket\" AND protoPayload.methodName=\"storage.setIamPolicy\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_logging_metric" "custom_role_changes" {
  provider = google
  name = "custom-role-changes"
  project = var.project_id
  description = "Counts the number of custom role changes"
  filter = "resource.type=\"iam_role\" AND (protoPayload.methodName=\"CreateRole\" OR protoPayload.methodName=\"UpdateRole\" OR protoPayload.methodName=\"DeleteRole\")"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_logging_metric" "project_ownership_changes" {
  provider = google
  name = "project-ownership-changes"
  project = var.project_id
  description = "Counts the number of project ownership changes"
  filter = "protoPayload.methodName=\"SetIamPolicy\" AND resource.type=\"project\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_logging_metric" "sql_instance_configuration_changes" {
  provider = google
  name = "sql-instance-configuration-changes"
  project = var.project_id
  description = "Counts the number of SQL instance configuration changes"
  filter = "resource.type=\"cloudsql_database_instance\" AND (protoPayload.methodName=\"cloudsql.instances.update\" OR protoPayload.methodName=\"cloudsql.instances.patch\")"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  provider = google
  name = "vpc-firewall-rule-changes"
  project = var.project_id
  description = "Counts the number of VPC firewall rule changes"
  filter = "resource.type=\"gce_firewall_rule\" AND (protoPayload.methodName=\"compute.firewalls.insert\" OR protoPayload.methodName=\"compute.firewalls.delete\" OR protoPayload.methodName=\"compute.firewalls.patch\")"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_logging_metric" "vpc_network_changes" {
  provider = google
  name = "vpc-network-changes"
  project = var.project_id
  description = "Counts the number of VPC network changes"
  filter = "resource.type=\"gce_network\" AND (protoPayload.methodName=\"compute.networks.insert\" OR protoPayload.methodName=\"compute.networks.delete\" OR protoPayload.methodName=\"compute.networks.patch\")"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_logging_metric" "vpc_network_route_changes" {
  provider = google
  name = "vpc-network-route-changes"
  project = var.project_id
  description = "Counts the number of VPC network route changes"
  filter = "resource.type=\"gce_route\" AND (protoPayload.methodName=\"compute.routes.insert\" OR protoPayload.methodName=\"compute.routes.delete\")"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_compute_subnetwork" "subnets" {
  provider = google
  for_each = toset(var.regions)
  name                     = "default"
  region                   = each.key
  network                  = "default"
  project = var.project_id
  flow_logs = true
}
