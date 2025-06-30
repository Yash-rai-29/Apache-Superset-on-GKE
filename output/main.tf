terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.14.0"
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

resource "google_project_service" "artifactregistry" {
  provider = google
  project  = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_iam_member" "artifactregistry_admin" {
  provider = google
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_project_service_identity.gcr_sa.email}"

  depends_on = [google_project_service.artifactregistry]
}

resource "google_project_service" "containeranalysis" {
  provider = google
  project  = var.project_id
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
  depends_on = [google_project_service.artifactregistry]
}

resource "google_container_analysis_occurrence" "default_occurrence" {
  provider = google
  project  = var.project_id
  note               = "projects/goog-analysis/notes/package-vulnerability"
  resource_uri       = "https://gcr.io/google-appengine/python:latest"
  short_description  = "Container Vulnerability Scanning"
  long_description   = "Enable Container Vulnerability Scanning using AR Container Analysis"

  package_issue {
    affected_location {
      cpe_uri = "cpe:/o:debian:debian_linux:8"
      package = "packagename"
      version {
        epoch  = "1"
        name   = "1.2.3"
        revision = "4"
      }
    }

    fixed_location {
      cpe_uri = "cpe:/o:debian:debian_linux:8"
      package = "packagename"
      version {
        epoch  = "1"
        name   = "1.2.3"
        revision = "5"
      }
    }

    vulnerability_details {
      type                 = "vulnerability-type"
      cvss_v3 {
        base_score          = 7.5
        attack_vector       = "ATTACK_VECTOR_LOCAL"
        attack_complexity   = "ATTACK_COMPLEXITY_LOW"
        privileges_required = "PRIVILEGES_REQUIRED_NONE"
        user_interaction    = "USER_INTERACTION_REQUIRED"
        scope               = "SCOPE_CHANGED"
        confidence          = "CONFIDENCE_HIGH"
        integrity_impact    = "IMPACT_HIGH"
        availability_impact = "IMPACT_HIGH"
        exploitability_score = 2.2
        impact_score        = 3.3
      }
    }
  }

  effective_severity = "HIGH"

  remediation = "Upgrade the operating system to fix this vulnerability."

  related_note_names = ["projects/goog-analysis/notes/package-vulnerability"]
}

resource "google_project_service" "cloudasset" {
  provider = google
  project  = var.project_id
  service = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "oslogin" {
  provider = google
  project  = var.project_id
  service = "oslogin.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_default_network" "default" {
  provider = google
  project = var.project_id

  action = "delete"
}

resource "google_compute_network_dns_policy" "default" {
  provider = google
  name    = "default"
  project = var.project_id
  network = "default"
  enable_logging = true
}

resource "google_project_service" "gcr" {
  provider = google
  project  = var.project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_container_registry" "registry" {
  provider = google
  project = var.project_id
  location = var.region
  deletion_policy = "DELETE"
}

resource "google_logging_project_sink" "default_sink" {
  provider = google
  name        = "default-sink"
  project     = var.project_id
  description = "exports copies of all log entries"
  destination = "storage.googleapis.com/${var.project_id}-logs"

  filter = "NOT logName:compute.googleapis.com/serialconsole.log AND NOT logName:shielded_vm_serialconsole.googleapis.com/serialconsole.log"

  unique_writer_identity = true
}

resource "google_storage_bucket" "log_bucket" {
  provider = google
  name          = "${var.project_id}-logs"
  project       = var.project_id
  location      = var.region
  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_project_iam_binding" "logging_writer" {
  provider = google
  project = var.project_id
  role = "roles/storage.objectCreator"
  members = [
    "serviceAccount:${google_logging_project_sink.default_sink.writer_identity}"
  ]
}

resource "google_monitoring_alert_policy" "audit_config_changes" {
  provider = google
  project  = var.project_id
  display_name = "Audit Configuration Changes"
  combiner     = "OR"

  conditions {
    display_name = "Audit Configuration Changes"
    condition_threshold {
      filter          = "resource.type=global AND logName:cloudaudit.googleapis.com%2Factivity AND protoPayload.methodName:SetIamPolicy"
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }

  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }

  notification_channels = []
}

resource "google_monitoring_alert_policy" "bucket_permission_changes" {
  provider = google
  project  = var.project_id
  display_name = "Cloud Storage IAM Permission Changes"
  combiner     = "OR"

  conditions {
    display_name = "Cloud Storage IAM Permission Changes"
    condition_threshold {
      filter          = "resource.type=gcs_bucket AND logName:cloudaudit.googleapis.com%2Factivity AND protoPayload.methodName:storage.setIamPermissions"
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }

  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }

  notification_channels = []
}

resource "google_monitoring_alert_policy" "custom_role_changes" {
  provider = google
  project  = var.project_id
  display_name = "Custom Role Changes"
  combiner     = "OR"

  conditions {
    display_name = "Custom Role Changes"
    condition_threshold {
      filter          = "resource.type=iam_role AND logName:cloudaudit.googleapis.com%2Factivity AND (protoPayload.methodName:CreateRole OR protoPayload.methodName:UpdateRole OR protoPayload.methodName:DeleteRole)"
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }

  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }

  notification_channels = []
}

resource "google_monitoring_alert_policy" "project_ownership_changes" {
  provider = google
  project  = var.project_id
  display_name = "Project Ownership Assignments/Changes"
  combiner     = "OR"

  conditions {
    display_name = "Project Ownership Assignments/Changes"
    condition_threshold {
      filter          = "resource.type=project AND logName:cloudaudit.googleapis.com%2Factivity AND protoPayload.methodName:SetIamPolicy AND protoPayload.request.policy.bindings:\"roles%2Fowner\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }

  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }

  notification_channels = []
}

resource "google_monitoring_alert_policy" "sql_instance_config_changes" {
  provider = google
  project  = var.project_id
  display_name = "SQL Instance Configuration Changes"
  combiner     = "OR"

  conditions {
    display_name = "SQL Instance Configuration Changes"
    condition_threshold {
      filter          = "resource.type=cloudsql_instance AND logName:cloudaudit.googleapis.com%2Factivity AND (protoPayload.methodName:cloudsql.instances.update OR protoPayload.methodName:cloudsql.instances.patch)"
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }

  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }

  notification_channels = []
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes" {
  provider = google
  project  = var.project_id
  display_name = "VPC Network Firewall Rule Changes"
  combiner     = "OR"

  conditions {
    display_name = "VPC Network Firewall Rule Changes"
    condition_threshold {
      filter          = "resource.type=gce_firewall_rule AND logName:cloudaudit.googleapis.com%2Factivity AND (protoPayload.methodName:compute.firewalls.insert OR protoPayload.methodName:compute.firewalls.delete OR protoPayload.methodName:compute.firewalls.patch)"
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }

  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }

  notification_channels = []
}

resource "google_monitoring_alert_policy" "vpc_network_changes" {
  provider = google
  project  = var.project_id
  display_name = "VPC Network Changes"
  combiner     = "OR"

  conditions {
    display_name = "VPC Network Changes"
    condition_threshold {
      filter          = "resource.type=gce_network AND logName:cloudaudit.googleapis.com%2Factivity AND (protoPayload.methodName:compute.networks.insert OR protoPayload.methodName:compute.networks.delete OR protoPayload.methodName:compute.networks.patch)"
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }

  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }

  notification_channels = []
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes" {
  provider = google
  project  = var.project_id
  display_name = "VPC Network Route Changes"
  combiner     = "OR"

  conditions {
    display_name = "VPC Network Route Changes"
    condition_threshold {
      filter          = "resource.type=gce_route AND logName:cloudaudit.googleapis.com%2Factivity AND (protoPayload.methodName:compute.routes.insert OR protoPayload.methodName:compute.routes.delete)"
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }

  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }

  notification_channels = []
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
  priority  = 65534

  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  target_tags   = []
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
  priority  = 65534

  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  target_tags   = []
}

resource "google_project_iam_member" "no_service_account_user" {
  provider = google
  project = var.project_id
  role = "roles/iam.serviceAccountUser"
  member = "allUsers"
}

resource "google_project_iam_member" "no_service_account_token_creator" {
  provider = google
  project = var.project_id
  role = "roles/iam.serviceAccountTokenCreator"
  member = "allUsers"
}

resource "google_compute_subnetwork" "default_subnet_flow_logs" {
  provider = google
  for_each = toset(var.default_subnets)
  name                     = each.key
  project                  = var.project_id
  region                   = each.key
  network                  = "default"
  ip_cidr_range            = "10.128.0.0/20"
  private_ip_google_access = true
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_storage_bucket" "gcs_uniform_access" {
  provider = google
  for_each = toset(var.gcs_buckets)
  name          = each.key
  project       = var.project_id
  location      = "US"
  force_destroy = true
  uniform_bucket_level_access = true
}
