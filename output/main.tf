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
}

resource "google_compute_network" "default" {
  name                    = var.default_network_name
  project                 = var.project_id
  auto_create_subnetworks = false

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_compute_firewall" "rdp" {
  name    = var.default_allow_rdp_firewall_name
  project = var.project_id
  network = var.default_network_name

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["0.0.0.0/0"]

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_compute_firewall" "ssh" {
  name    = var.default_allow_ssh_firewall_name
  project = var.project_id
  network = var.default_network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]

    lifecycle {
    prevent_destroy = false
  }
}

resource "google_project_iam_member" "project" {
  for_each = toset([
    "roles/viewer",
    "roles/compute.networkViewer",
  ])
  project = var.project_id
  role    = each.key
  member  = "allUsers"

  depends_on = [
    google_compute_firewall.rdp,
    google_compute_firewall.ssh,
    google_compute_network.default
  ]
}

resource "google_compute_subnetwork" "default_flow_logs" {
  for_each = toset(var.regions)

  name                     = "default"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  region                   = each.key
  project                  = var.project_id
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  depends_on = [
    google_compute_network.default
  ]
}

resource "google_storage_bucket" "buckets" {
  for_each = toset(var.bucket_names)

  name          = each.key
  project       = var.project_id
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true
}

resource "google_project_service" "artifactregistry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "repo" {
  provider = google
  location = "us-central1"
  repository_id = "my-repo"
  project = var.project_id
  format = "DOCKER"

  depends_on = [google_project_service.artifactregistry]
}

resource "google_container_analysis_occurrence" "note_occurrence" {
  provider = google
  note = "providers/goog-analysis/notes/package-vulnerability"
  resource_uri = "us-docker.pkg.dev/cloudrun/container/hello:latest"
 project = var.project_id
}

resource "google_project_service" "cloudasset" {
  project = var.project_id
  service = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service_identity" "cloudasset" {
  project = var.project_id
  service = "cloudasset.googleapis.com"
}

resource "google_project_iam_binding" "cloudasset" {
  project = var.project_id
  role    = "roles/cloudasset.serviceAgent"
  members = ["serviceAccount:${data.google_project.project.number}@gcp-sa-cloudasset.iam.gserviceaccount.com"]
  depends_on = [google_project_service_identity.cloudasset,
  google_project_service.cloudasset]
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_service" "gcr" {
  project = var.project_id
  service = "containerregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_iam_binding" "gcr_scanner" {
  project = var.project_id
  role = "roles/containeranalysis.occurrences.viewer"
  members = ["serviceAccount:containeranalysis@appspot.gserviceaccount.com",
  "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"]
  depends_on = [google_project_service.gcr,
  data.google_project.project]
}

resource "google_logging_project_sink" "default_sink" {
  name = "all-logs"
  project = var.project_id
  description = "export all logs to a cloud storage bucket"
  destination = "storage.googleapis.com/${google_storage_bucket.buckets["aviato-game-fight-rvxirf.appspot.com"].name}"
  filter = "NOT logName:\"projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity\" AND NOT logName:\"projects/${var.project_id}/logs/system.gserviceaccount.com%2F\""
}

resource "google_project_service" "logging" {
  project = var.project_id
  service = "logging.googleapis.com"
  disable_on_destroy = false
}

resource "google_monitoring_alert_policy" "audit_configuration_changes_alert" {
  display_name = "Audit Configuration Changes Alert"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Audit Configuration Changes Condition"
    condition_threshold {
      comparison = "COMPARISON_GT"
      duration = "60s"
      filter = "metric.type=\"logging.googleapis.com/log_entry_count\" AND metric.labels.\"log_name\"=\"projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity\" AND resource.type=\"global\""
      threshold_value = 0
      trigger {
        count = 1
        percent = 0
      }
    }
  }
 notification_channels = []
}

resource "google_monitoring_alert_policy" "bucket_permission_changes_alert" {
  display_name = "Cloud Storage IAM Permission Changes Alert"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Cloud Storage IAM Permission Changes Condition"
    condition_threshold {
      comparison = "COMPARISON_GT"
      duration = "60s"
      filter = "metric.type=\"logging.googleapis.com/log_entry_count\" AND metric.labels.\"log_name\"=\"projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Fdata_access\" AND resource.type=\"gcs_bucket\""
      threshold_value = 0
      trigger {
        count = 1
        percent = 0
      }
    }
  }
 notification_channels = []
}

resource "google_monitoring_alert_policy" "custom_role_changes_alert" {
  display_name = "Custom Role Changes Alert"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Custom Role Changes Condition"
    condition_threshold {
      comparison = "COMPARISON_GT"
      duration = "60s"
      filter = "metric.type=\"logging.googleapis.com/log_entry_count\" AND metric.labels.\"log_name\"=\"projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity\" AND resource.type=\"organization\""
      threshold_value = 0
      trigger {
        count = 1
        percent = 0
      }
    }
  }
 notification_channels = []
}

resource "google_monitoring_alert_policy" "project_ownership_changes_alert" {
  display_name = "Project Ownership Assignments/Changes Alert"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Project Ownership Assignments/Changes Condition"
    condition_threshold {
      comparison = "COMPARISON_GT"
      duration = "60s"
      filter = "metric.type=\"logging.googleapis.com/log_entry_count\" AND metric.labels.\"log_name\"=\"projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity\" AND resource.type=\"project\""
      threshold_value = 0
      trigger {
        count = 1
        percent = 0
      }
    }
  }
 notification_channels = []
}

resource "google_monitoring_alert_policy" "sql_instance_configuration_changes_alert" {
  display_name = "SQL Instance Configuration Changes Alert"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "SQL Instance Configuration Changes Condition"
    condition_threshold {
      comparison = "COMPARISON_GT"
      duration = "60s"
      filter = "metric.type=\"logging.googleapis.com/log_entry_count\" AND metric.labels.\"log_name\"=\"projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity\" AND resource.type=\"cloudsql_database\""
      threshold_value = 0
      trigger {
        count = 1
        percent = 0
      }
    }
  }
 notification_channels = []
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes_alert" {
  display_name = "VPC Network Firewall Rule Changes Alert"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "VPC Network Firewall Rule Changes Condition"
    condition_threshold {
      comparison = "COMPARISON_GT"
      duration = "60s"
      filter = "metric.type=\"logging.googleapis.com/log_entry_count\" AND metric.labels.\"log_name\"=\"projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity\" AND resource.type=\"gce_firewall_rule\""
      threshold_value = 0
      trigger {
        count = 1
        percent = 0
      }
    }
  }
 notification_channels = []
}

resource "google_monitoring_alert_policy" "vpc_network_changes_alert" {
  display_name = "VPC Network Changes Alert"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "VPC Network Changes Condition"
    condition_threshold {
      comparison = "COMPARISON_GT"
      duration = "60s"
      filter = "metric.type=\"logging.googleapis.com/log_entry_count\" AND metric.labels.\"log_name\"=\"projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity\" AND resource.type=\"gce_network\""
      threshold_value = 0
      trigger {
        count = 1
        percent = 0
      }
    }
  }
 notification_channels = []
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes_alert" {
  display_name = "VPC Network Route Changes Alert"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "VPC Network Route Changes Condition"
    condition_threshold {
      comparison = "COMPARISON_GT"
      duration = "60s"
      filter = "metric.type=\"logging.googleapis.com/log_entry_count\" AND metric.labels.\"log_name\"=\"projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity\" AND resource.type=\"gce_route\""
      threshold_value = 0
      trigger {
        count = 1
        percent = 0
      }
    }
  }
 notification_channels = []
}

resource "google_project_service" "oslogin" {
  project = var.project_id
  service = "oslogin.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_project_metadata" "oslogin_enable" {
  project = var.project_id

  metadata = {
    enable-oslogin = "TRUE"
  }

  depends_on = [google_project_service.oslogin]
}
