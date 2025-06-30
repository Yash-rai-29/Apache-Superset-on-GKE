terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.68.0"
    }
  }
}

provider "google" {
  project = "aviato-game-fight-rvxirf"
  region  = "us-central1"
}

resource "google_project_service_identity" "artifact_registry" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  service = "artifactregistry.googleapis.com"
}

resource "google_project_iam_binding" "artifact_registry_pull" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  role = "roles/artifactregistry.reader"
  members = [
    "serviceAccount:${google_project_service_identity.artifact_registry.email}",
  ]
}

resource "google_project_iam_binding" "artifact_registry_push" {
  provider = google
  project = "aviato-game-fight-rvxirf"
  role = "roles/artifactregistry.writer"
  members = [
    "serviceAccount:${google_project_service_identity.artifact_registry.email}",
  ]
}

resource "google_project_iam_member" "firebase_sdk_admin_service_agent_remediation" {
  project = "aviato-game-fight-rvxirf"
  role = "roles/viewer"
  member = "serviceAccount:twitch-login@aviato-game-fight-rvxirf.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "appspot_service_account_remediation" {
  project = "aviato-game-fight-rvxirf"
  role = "roles/viewer"
  member = "serviceAccount:aviato-game-fight-rvxirf@appspot.gserviceaccount.com"
}

resource "google_project_iam_member" "compute_service_account_remediation" {
  project = "aviato-game-fight-rvxirf"
  role = "roles/viewer"
  member = "serviceAccount:30647320905-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "storage_admin_remediation" {
  project = "aviato-game-fight-rvxirf"
  role = "roles/viewer"
  member = "serviceAccount:firebase-adminsdk-d21rv@aviato-game-fight-rvxirf.iam.gserviceaccount.com"
}

resource "google_project_service" "containeranalysis" {
  provider = google
  project  = "aviato-game-fight-rvxirf"
  service = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudasset" {
  provider = google
  project  = "aviato-game-fight-rvxirf"
  service = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_network" "default" {
  provider = google
  name                    = "default"
  project                 = "aviato-game-fight-rvxirf"
  delete_default_routes = true
}

resource "google_compute_subnetwork" "default_asia_east1" {
  name                     = "default"
  ip_cidr_range          = "10.0.0.0/20"
  network                  = "default"
  region                   = "asia-east1"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_asia_east2" {
  name                     = "default"
  ip_cidr_range          = "10.20.0.0/20"
  network                  = "default"
  region                   = "asia-east2"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_asia_northeast1" {
  name                     = "default"
  ip_cidr_range          = "10.40.0.0/20"
  network                  = "default"
  region                   = "asia-northeast1"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_asia_northeast3" {
  name                     = "default"
  ip_cidr_range          = "10.30.0.0/20"
  network                  = "default"
  region                   = "asia-northeast3"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_asia_south1" {
  name                     = "default"
  ip_cidr_range          = "10.140.0.0/20"
  network                  = "default"
  region                   = "asia-south1"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_asia_south2" {
  name                     = "default"
  ip_cidr_range          = "10.130.0.0/20"
  network                  = "default"
  region                   = "asia-south2"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_asia_southeast1" {
  name                     = "default"
  ip_cidr_range          = "10.150.0.0/20"
  network                  = "default"
  region                   = "asia-southeast1"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_asia_southeast2" {
  name                     = "default"
  ip_cidr_range          = "10.120.0.0/20"
  network                  = "default"
  region                   = "asia-southeast2"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_australia_southeast1" {
  name                     = "default"
  ip_cidr_range          = "10.160.0.0/20"
  network                  = "default"
  region                   = "australia-southeast1"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_australia_southeast2" {
  name                     = "default"
  ip_cidr_range          = "10.170.0.0/20"
  network                  = "default"
  region                   = "australia-southeast2"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_europe_central2" {
  name                     = "default"
  ip_cidr_range          = "10.180.0.0/20"
  network                  = "default"
  region                   = "europe-central2"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_europe_north1" {
  name                     = "default"
  ip_cidr_range          = "10.190.0.0/20"
  network                  = "default"
  region                   = "europe-north1"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_europe_north2" {
  name                     = "default"
  ip_cidr_range          = "10.200.0.0/20"
  network                  = "default"
  region                   = "europe-north2"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_europe_southwest1" {
  name                     = "default"
  ip_cidr_range          = "10.210.0.0/20"
  network                  = "default"
  region                   = "europe-southwest1"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_europe_west1" {
  name                     = "default"
  ip_cidr_range          = "10.220.0.0/20"
  network                  = "default"
  region                   = "europe-west1"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_europe_west10" {
  name                     = "default"
  ip_cidr_range          = "10.230.0.0/20"
  network                  = "default"
  region                   = "europe-west10"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_europe_west2" {
  name                     = "default"
  ip_cidr_range          = "10.240.0.0/20"
  network                  = "default"
  region                   = "europe-west2"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_europe_west3" {
  name                     = "default"
  ip_cidr_range          = "10.250.0.0/20"
  network                  = "default"
  region                   = "europe-west3"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_europe_west4" {
  name                     = "default"
  ip_cidr_range          = "10.0.0.0/20"
  network                  = "default"
  region                   = "europe-west4"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_europe_west6" {
  name                     = "default"
  ip_cidr_range          = "10.10.0.0/20"
  network                  = "default"
  region                   = "europe-west6"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_me_central1" {
  name                     = "default"
  ip_cidr_range          = "10.30.0.0/20"
  network                  = "default"
  region                   = "me-central1"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_me_west1" {
  name                     = "default"
  ip_cidr_range          = "10.40.0.0/20"
  network                  = "default"
  region                   = "me-west1"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_northamerica_northeast1" {
  name                     = "default"
  ip_cidr_range          = "10.50.0.0/20"
  network                  = "default"
  region                   = "northamerica-northeast1"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_northamerica_northeast2" {
  name                     = "default"
  ip_cidr_range          = "10.60.0.0/20"
  network                  = "default"
  region                   = "northamerica-northeast2"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_northamerica_south1" {
  name                     = "default"
  ip_cidr_range          = "10.70.0.0/20"
  network                  = "default"
  region                   = "northamerica-south1"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_southamerica_east1" {
  name                     = "default"
  ip_cidr_range          = "10.80.0.0/20"
  network                  = "default"
  region                   = "southamerica-east1"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_southamerica_west1" {
  name                     = "default"
  ip_cidr_range          = "10.90.0.0/20"
  network                  = "default"
  region                   = "southamerica-west1"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_us_central1" {
  name                     = "default"
  ip_cidr_range          = "10.100.0.0/20"
  network                  = "default"
  region                   = "us-central1"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_us_east4" {
  name                     = "default"
  ip_cidr_range          = "10.110.0.0/20"
  network                  = "default"
  region                   = "us-east4"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_us_east5" {
  name                     = "default"
  ip_cidr_range          = "10.120.0.0/20"
  network                  = "default"
  region                   = "us-east5"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_us_south1" {
  name                     = "default"
  ip_cidr_range          = "10.130.0.0/20"
  network                  = "default"
  region                   = "us-south1"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_us_west1" {
  name                     = "default"
  ip_cidr_range          = "10.140.0.0/20"
  network                  = "default"
  region                   = "us-west1"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_us_west2" {
  name                     = "default"
  ip_cidr_range          = "10.150.0.0/20"
  network                  = "default"
  region                   = "us-west2"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_us_west3" {
  name                     = "default"
  ip_cidr_range          = "10.160.0.0/20"
  network                  = "default"
  region                   = "us-west3"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_subnetwork" "default_us_west4" {
  name                     = "default"
  ip_cidr_range          = "10.170.0.0/20"
  network                  = "default"
  region                   = "us-west4"
  project                 = "aviato-game-fight-rvxirf"
  enable_flow_logs = true
}

resource "google_compute_network_dns_policy" "default" {
  provider = google
  project  = "aviato-game-fight-rvxirf"
  network = "default"
  enable_logging = true
}

resource "google_compute_firewall" "default_allow_ssh" {
  provider = google
  name    = "default-allow-ssh"
  network = "default"
  project = "aviato-game-fight-rvxirf"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["130.211.0.0/22", "35.235.240.0/20"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "default_allow_rdp" {
  provider = google
  name    = "default-allow-rdp"
  network = "default"
  project = "aviato-game-fight-rvxirf"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["130.211.0.0/22", "35.235.240.0/20"]
  target_tags   = ["rdp"]
}

resource "google_project_metadata" "metadata" {
  provider = google
  project = "aviato-game-fight-rvxirf"

  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_storage_bucket" "default_bucket" {
  name = "aviato-game-fight-rvxirf.appspot.com"
  location = "AUSTRALIA-SOUTHEAST1"
  project = "aviato-game-fight-rvxirf"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "default_bucket_us" {
  name = "aviato-game-fight-rvxirf_bucket"
  location = "US"
  project = "aviato-game-fight-rvxirf"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "staging_bucket" {
  name = "staging.aviato-game-fight-rvxirf.appspot.com"
  location = "AUSTRALIA-SOUTHEAST1"
  project = "aviato-game-fight-rvxirf"
  uniform_bucket_level_access = true
}

resource "google_logging_project_sink" "all_logs" {
  name        = "all-logs-sink"
  project     = "aviato-game-fight-rvxirf"
  destination = "storage.googleapis.com/${google_storage_bucket.default_bucket.name}"
  filter      = "NOT logName:projects/${"aviato-game-fight-rvxirf"}/logs/cloudaudit.googleapis.com%2Fdata_access"

  unique_writer_identity = true
}

resource "google_logging_metric" "audit_configuration_changes" {
  name          = "audit-configuration-changes"
  project     = "aviato-game-fight-rvxirf"
  description = "Records the number of audit configuration changes."
  filter      = "protoPayload.methodName=\"SetIamPolicy\" OR protoPayload.methodName=\"UpdateAuditConfig\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "audit_configuration_changes_alert" {
  display_name = "Audit Configuration Changes Alert"
  project     = "aviato-game-fight-rvxirf"
  combiner = "OR"
  conditions {
    display_name = "Audit Configuration Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/audit-configuration-changes\" AND resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "bucket_permission_changes" {
  name          = "bucket-permission-changes"
  project     = "aviato-game-fight-rvxirf"
  description = "Records the number of Cloud Storage Bucket IAM Permission changes."
  filter      = "resource.type=\"gcs_bucket\" AND protoPayload.methodName=\"storage.setIamPolicy\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes_alert" {
  display_name = "Bucket Permission Changes Alert"
  project     = "aviato-game-fight-rvxirf"
  combiner = "OR"
  conditions {
    display_name = "Bucket Permission Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/bucket-permission-changes\" AND resource.type=\"gcs_bucket\""
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "custom_role_changes" {
  name          = "custom-role-changes"
  project     = "aviato-game-fight-rvxirf"
  description = "Records the number of Custom Role changes."
  filter      = "resource.type=\"iam_role\" AND protoPayload.methodName=(\"google.iam.admin.v1.CreateRole\" OR \"google.iam.admin.v1.DeleteRole\" OR \"google.iam.admin.v1.UpdateRole\")"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes_alert" {
  display_name = "Custom Role Changes Alert"
  project     = "aviato-game-fight-rvxirf"
  combiner = "OR"
  conditions {
    display_name = "Custom Role Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/custom-role-changes\" AND resource.type=\"iam_role\""
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "project_ownership_changes" {
  name          = "project-ownership-changes"
  project     = "aviato-game-fight-rvxirf"
  description = "Records the number of Project Ownership Assignments/Changes."
  filter      = "resource.type=\"gcp_project\" AND protoPayload.methodName=\"SetIamPolicy\" AND protoPayload.request.policy.bindings:data_transfer OR resource.type=\"gcp_project\" AND protoPayload.methodName=\"SetIamPolicy\" AND protoPayload.request.policy.bindings.role:roles/owner"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes_alert" {
  display_name = "Project Ownership Changes Alert"
  project     = "aviato-game-fight-rvxirf"
  combiner = "OR"
  conditions {
    display_name = "Project Ownership Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/project-ownership-changes\" AND resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "sql_instance_configuration_changes" {
  name          = "sql-instance-configuration-changes"
  project     = "aviato-game-fight-rvxirf"
  description = "Records the number of SQL Instance Configuration Changes."
  filter      = "resource.type=\"cloudsql_database_instance\" AND protoPayload.methodName=(\"cloudsql.instances.update\" OR \"cloudsql.instances.patch\")"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "sql_instance_configuration_changes_alert" {
  display_name = "SQL Instance Configuration Changes Alert"
  project     = "aviato-game-fight-rvxirf"
  combiner = "OR"
  conditions {
    display_name = "SQL Instance Configuration Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/sql-instance-configuration-changes\" AND resource.type=\"cloudsql_database_instance\""
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  name          = "vpc-firewall-rule-changes"
  project     = "aviato-game-fight-rvxirf"
  description = "Records the number of VPC Network Firewall Rule Changes."
  filter      = "resource.type=\"gce_firewall_rule\" AND protoPayload.methodName=(\"compute.firewalls.insert\" OR \"compute.firewalls.patch\" OR \"compute.firewalls.delete\")"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes_alert" {
  display_name = "VPC Firewall Rule Changes Alert"
  project     = "aviato-game-fight-rvxirf"
  combiner = "OR"
  conditions {
    display_name = "VPC Firewall Rule Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-firewall-rule-changes\" AND resource.type=\"gce_firewall_rule\""
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_network_changes" {
  name          = "vpc-network-changes"
  project     = "aviato-game-fight-rvxirf"
  description = "Records the number of VPC Network Changes."
  filter      = "resource.type=\"gce_network\" AND protoPayload.methodName=(\"compute.networks.insert\" OR \"compute.networks.patch\" OR \"compute.networks.delete\")"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes_alert" {
  display_name = "VPC Network Changes Alert"
  project     = "aviato-game-fight-rvxirf"
  combiner = "OR"
  conditions {
    display_name = "VPC Network Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-changes\" AND resource.type=\"gce_network\""
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_network_route_changes" {
  name          = "vpc-network-route-changes"
  project     = "aviato-game-fight-rvxirf"
  description = "Records the number of VPC Network Route Changes."
  filter      = "resource.type=\"gce_route\" AND protoPayload.methodName=(\"compute.routes.insert\" OR \"compute.routes.delete\")"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
    unit = "1"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes_alert" {
  display_name = "VPC Network Route Changes Alert"
  project     = "aviato-game-fight-rvxirf"
  combiner = "OR"
  conditions {
    display_name = "VPC Network Route Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-route-changes\" AND resource.type=\"gce_route\""
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_iam_service_account_key" "user_managed_key_rotation_30647320905" {
  service_account_id = "30647320905-compute@developer.gserviceaccount.com"
  project              = "aviato-game-fight-rvxirf"
}

resource "google_iam_service_account_key" "user_managed_key_rotation_twitch" {
  service_account_id = "twitch-login@aviato-game-fight-rvxirf.iam.gserviceaccount.com"
  project              = "aviato-game-fight-rvxirf"
}

resource "google_project_iam_member" "twitch_login" {
  project = "aviato-game-fight-rvxirf"
  role    = "roles/viewer"
  member  = "serviceAccount:twitch-login@aviato-game-fight-rvxirf.iam.gserviceaccount.com"
}

resource "google_project_iam_audit_config" "audit_config" {
  project = "aviato-game-fight-rvxirf"
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

resource "google_project_default_service_accounts" "project" {
  project = "aviato-game-fight-rvxirf"
  action = "DISABLE_DELETION"
}
