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
  region  = var.region
}

resource "google_project_service_identity" "gcr_sa" {
  provider = google
  project  = var.project_id
  service  = "containerregistry.googleapis.com"
}

resource "google_project_iam_binding" "container_analysis" {
  provider = google
  project = var.project_id
  role = "roles/containeranalysis.notes.occurrences.viewer"
  members = [
    "serviceAccount:${google_project_service_identity.gcr_sa.email}"
  ]
}

resource "google_container_analysis_occurrence" "default" {
  provider = google
  project  = var.project_id
  note_name = "projects/${var.project_id}/notes/package-vulnerability"
  resource_uri = "https://gcr.io/google-containers/pause:3.0"

  effective_severity = "HIGH"

  package_issue {
    affected_location {
      cpe_uri = "cpe:/o:debian:debian_linux:8"
      package = "foo"
      version {
        epoch = "1"
        name = "1.2.3"
        revision = "4"
      }
    }

    fixed_location {
      cpe_uri = "cpe:/o:debian:debian_linux:8"
      package = "foo"
      version {
        epoch = "1"
        name = "1.2.3"
        revision = "5"
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

resource "google_compute_project_metadata" "oslogin_enable" {
  provider = google
  project = var.project_id
  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_network" "default" {
  provider = google
  name                    = "default"
  project                 = var.project_id
  auto_create_subnetworks = false

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_compute_firewall" "disable_rdp" {
  provider = google
  name    = "default-allow-rdp"
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = []
  disabled = true
}

resource "google_compute_firewall" "disable_ssh" {
  provider = google
  name    = "default-allow-ssh"
  project = var.project_id
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = []
  disabled = true
}

resource "google_compute_network" "default_network" {
  provider = google
  name                    = "default"
  project                 = var.project_id
  auto_create_subnetworks = false
  delete_default_routes = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_network" "default_network_dns" {
  provider = google
  name                    = "default"
  project                 = var.project_id
  auto_create_subnetworks = true
  delete_default_routes = false
  dns_config {
    enable_logging = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_logging_project_sink" "default" {
  provider = google
  name        = "default-sink"
  project     = var.project_id
  description = "Exports all logs from the project to a Cloud Storage bucket."
  destination = "storage.googleapis.com/${var.project_id}-logs"

  filter = "severity>=INFO"
}

resource "google_storage_bucket" "default_bucket" {
  provider = google
  name          = "${var.project_id}-logs"
  project       = var.project_id
  location      = "US"
  force_destroy = true
}

resource "google_project_iam_member" "logging_writer" {
  provider = google
  project = var.project_id
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:cloud-logs@system.gserviceaccount.com"
}

resource "google_storage_bucket_iam_binding" "bucket_logging" {
  provider = google
  bucket = google_storage_bucket.default_bucket.name
  role   = "roles/storage.objectViewer"
  members = [
    "serviceAccount:cloud-logs@system.gserviceaccount.com",
  ]
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  provider = google
  project  = var.project_id
  region   = var.region
  name       = "audit-config-changes-alert"
  role       = "roles/cloudfunctions.invoker"
  member     = "allUsers"
}

resource "google_cloudfunctions_function_iam_member" "invoker2" {
  provider = google
  project  = var.project_id
  region   = var.region
  name       = "bucket-permission-changes-alert"
  role       = "roles/cloudfunctions.invoker"
  member     = "allUsers"
}

resource "google_cloudfunctions_function_iam_member" "invoker3" {
  provider = google
  project  = var.project_id
  region   = var.region
  name       = "custom-role-changes-alert"
  role       = "roles/cloudfunctions.invoker"
  member     = "allUsers"
}

resource "google_cloudfunctions_function_iam_member" "invoker4" {
  provider = google
  project  = var.project_id
  region   = var.region
  name       = "project-ownership-changes-alert"
  role       = "roles/cloudfunctions.invoker"
  member     = "allUsers"
}

resource "google_cloudfunctions_function_iam_member" "invoker5" {
  provider = google
  project  = var.project_id
  region   = var.region
  name       = "sql-instance-configuration-changes-alert"
  role       = "roles/cloudfunctions.invoker"
  member     = "allUsers"
}

resource "google_cloudfunctions_function_iam_member" "invoker6" {
  provider = google
  project  = var.project_id
  region   = var.region
  name       = "vpc-firewall-rule-changes-alert"
  role       = "roles/cloudfunctions.invoker"
  member     = "allUsers"
}

resource "google_cloudfunctions_function_iam_member" "invoker7" {
  provider = google
  project  = var.project_id
  region   = var.region
  name       = "vpc-network-changes-alert"
  role       = "roles/cloudfunctions.invoker"
  member     = "allUsers"
}

resource "google_cloudfunctions_function_iam_member" "invoker8" {
  provider = google
  project  = var.project_id
  region   = var.region
  name       = "vpc-network-route-changes-alert"
  role       = "roles/cloudfunctions.invoker"
  member     = "allUsers"
}

resource "google_logging_metric" "audit_config_changes" {
  provider = google
  name   = "audit-config-changes"
  project = var.project_id
  description = "This metric counts the number of audit configuration changes."
  filter = "resource.type=audited_resource AND protoPayload.methodName=\"SetIamPolicy\""
  metric_descriptor {
    launch_stage = "BETA"
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "audit_config_changes_alert" {
  provider = google
  project = var.project_id
  display_name = "Audit Configuration Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "Audit Config Changes Condition"
    condition_threshold {
      comparison = "COMPARISON_GT"
      duration = "60s"
      filter = "metric.type=\"logging.googleapis.com/user/audit-config-changes\" resource.type=\"gcp_project\""
      aggregations {
          alignment_period   = "60s"
          per_series_aligner = "ALIGN_SUM"
        }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "bucket_permission_changes" {
  provider = google
  name   = "bucket-permission-changes"
  project = var.project_id
  description = "This metric counts the number of bucket permission changes."
  filter = "resource.type=gcs_bucket AND protoPayload.methodName=\"storage.setIamPermissions\""
  metric_descriptor {
    launch_stage = "BETA"
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes_alert" {
  provider = google
  project = var.project_id
  display_name = "Cloud Storage Bucket Permission Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "Bucket Permission Changes Condition"
    condition_threshold {
      comparison = "COMPARISON_GT"
      duration = "60s"
      filter = "metric.type=\"logging.googleapis.com/user/bucket-permission-changes\" resource.type=\"gcs_bucket\""
      aggregations {
          alignment_period   = "60s"
          per_series_aligner = "ALIGN_SUM"
        }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "custom_role_changes" {
  provider = google
  name   = "custom-role-changes"
  project = var.project_id
  description = "This metric counts the number of custom role changes."
  filter = "resource.type=iam_role AND protoPayload.methodName=\"google.iam.admin.v1.CreateRole\" OR protoPayload.methodName=\"google.iam.admin.v1.UpdateRole\" OR protoPayload.methodName=\"google.iam.admin.v1.DeleteRole\""
  metric_descriptor {
    launch_stage = "BETA"
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes_alert" {
  provider = google
  project = var.project_id
  display_name = "Custom Role Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "Custom Role Changes Condition"
    condition_threshold {
      comparison = "COMPARISON_GT"
      duration = "60s"
      filter = "metric.type=\"logging.googleapis.com/user/custom-role-changes\" resource.type=\"iam_role\""
      aggregations {
          alignment_period   = "60s"
          per_series_aligner = "ALIGN_SUM"
        }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "project_ownership_changes" {
  provider = google
  name   = "project-ownership-changes"
  project = var.project_id
  description = "This metric counts the number of project ownership changes."
  filter = "resource.type=gcp_project AND protoPayload.methodName=\"SetIamPolicy\" AND protoPayload.serviceData.policyDelta.bindingDeltas.member:(\"user:admin@example.com\")"
  metric_descriptor {
    launch_stage = "BETA"
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes_alert" {
  provider = google
  project = var.project_id
  display_name = "Project Ownership Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "Project Ownership Changes Condition"
    condition_threshold {
      comparison = "COMPARISON_GT"
      duration = "60s"
      filter = "metric.type=\"logging.googleapis.com/user/project-ownership-changes\" resource.type=\"gcp_project\""
      aggregations {
          alignment_period   = "60s"
          per_series_aligner = "ALIGN_SUM"
        }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "sql_instance_configuration_changes" {
  provider = google
  name   = "sql-instance-configuration-changes"
  project = var.project_id
  description = "This metric counts the number of SQL instance configuration changes."
  filter = "resource.type=cloudsql_database AND protoPayload.methodName=\"cloudsql.instances.update\""
  metric_descriptor {
    launch_stage = "BETA"
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "sql_instance_configuration_changes_alert" {
  provider = google
  project = var.project_id
  display_name = "SQL Instance Configuration Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "SQL Instance Configuration Changes Condition"
    condition_threshold {
      comparison = "COMPARISON_GT"
      duration = "60s"
      filter = "metric.type=\"logging.googleapis.com/user/sql-instance-configuration-changes\" resource.type=\"cloudsql_database\""
      aggregations {
          alignment_period   = "60s"
          per_series_aligner = "ALIGN_SUM"
        }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  provider = google
  name   = "vpc-firewall-rule-changes"
  project = var.project_id
  description = "This metric counts the number of VPC firewall rule changes."
  filter = "resource.type=gce_firewall_rule AND protoPayload.methodName=\"compute.firewalls.insert\" OR protoPayload.methodName=\"compute.firewalls.delete\""
  metric_descriptor {
    launch_stage = "BETA"
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes_alert" {
  provider = google
  project = var.project_id
  display_name = "VPC Firewall Rule Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "VPC Firewall Rule Changes Condition"
    condition_threshold {
      comparison = "COMPARISON_GT"
      duration = "60s"
      filter = "metric.type=\"logging.googleapis.com/user/vpc-firewall-rule-changes\" resource.type=\"gce_firewall_rule\""
      aggregations {
          alignment_period   = "60s"
          per_series_aligner = "ALIGN_SUM"
        }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_network_changes" {
  provider = google
  name   = "vpc-network-changes"
  project = var.project_id
  description = "This metric counts the number of VPC network changes."
  filter = "resource.type=gce_network AND protoPayload.methodName=\"compute.networks.insert\" OR protoPayload.methodName=\"compute.networks.delete\""
  metric_descriptor {
    launch_stage = "BETA"
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes_alert" {
  provider = google
  project = var.project_id
  display_name = "VPC Network Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "VPC Network Changes Condition"
    condition_threshold {
      comparison = "COMPARISON_GT"
      duration = "60s"
      filter = "metric.type=\"logging.googleapis.com/user/vpc-network-changes\" resource.type=\"gce_network\""
      aggregations {
          alignment_period   = "60s"
          per_series_aligner = "ALIGN_SUM"
        }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_network_route_changes" {
  provider = google
  name   = "vpc-network-route-changes"
  project = var.project_id
  description = "This metric counts the number of VPC network route changes."
  filter = "resource.type=gce_route AND protoPayload.methodName=\"compute.routes.insert\" OR protoPayload.methodName=\"compute.routes.delete\""
  metric_descriptor {
    launch_stage = "BETA"
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes_alert" {
  provider = google
  project = var.project_id
  display_name = "VPC Network Route Changes Alert"
  combiner = "OR"
  conditions {
    display_name = "VPC Network Route Changes Condition"
    condition_threshold {
      comparison = "COMPARISON_GT"
      duration = "60s"
      filter = "metric.type=\"logging.googleapis.com/user/vpc-network-route-changes\" resource.type=\"gce_route\""
      aggregations {
          alignment_period   = "60s"
          per_series_aligner = "ALIGN_SUM"
        }
    }
  }
  notification_channels = []
}

resource "google_project_iam_binding" "no_service_account_user_project_level" {
  provider = google
  project = var.project_id
  role = "roles/iam.serviceAccountUser"
  members = []
}

resource "google_project_iam_binding" "no_service_account_token_creator_project_level" {
  provider = google
  project = var.project_id
  role = "roles/iam.serviceAccountTokenCreator"
  members = []
}

resource "google_project_iam_custom_role" "separation_of_duties" {
  provider = google
  project = var.project_id
  role_id = "customServiceAccountRole"
  title = "Custom Service Account Role"
  description = "A custom role to enforce separation of duties for service accounts."
  permissions = [
    "iam.serviceAccounts.actAs",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.list",
    "iam.serviceAccountKeys.get",
    "iam.serviceAccountKeys.list",
  ]
}

resource "google_project_iam_member" "project" {
  provider = google
  project = var.project_id
  role   = "roles/viewer"
  member = "allUsers"
}

resource "google_cloudbuild_trigger" "trigger" {
  provider = google
  project = var.project_id
  name = "my-build-trigger"
  location = "global"

  github {
    owner = "google"
    name = "test-repo"
    push {
      branch = "^master$"
    }
  }
  filename = "cloudbuild.yaml"
}

resource "google_access_context_manager_service_perimeter" "perimeter" {
  provider = google
  name = "accessPolicies/${data.google_access_context_manager_access_policy.policy.name}/servicePerimeters/my_service_perimeter"
  title = "My Service Perimeter"
  status {
    restricted_services = ["storage.googleapis.com"]
  }
}

data "google_access_context_manager_access_policy" "policy" {
  provider = google
  name = "test-access-policy"
}

resource "google_essential_contacts_contact" "contact" {
  provider = google
  project = var.project_id
  email        = "test@example.com"
  language_tag = "en-US"
  notification_categorysubscriptions = [
    "ALL",
  ]
}

resource "google_bigquery_dataset_iam_binding" "binding" {
  provider = google
  project   = var.project_id
  dataset_id = "example_dataset"
  members    = ["allUsers"]
  role       = "roles/viewer"
}

resource "google_cloudiot_registry_iam_member" "member" {
  provider = google
  project  = var.project_id
  location = "us-central1"
  registry = "example-registry"
  role     = "roles/viewer"
  member   = "allUsers"
}

resource "google_data_catalog_entry_group_iam_binding" "binding" {
  provider = google
  project       = var.project_id
  location      = "us-central1"
  entry_group = "entry_group_id"
  role     = "roles/viewer"
  members  = ["allUsers"]
}

resource "google_data_loss_prevention_job_trigger_iam_binding" "binding" {
  provider = google
  parent = "projects/${var.project_id}/locations/us-central1/jobTriggers/test-job-trigger"
  role = "roles/viewer"
  members = ["allUsers"]
}

resource "google_folder_iam_binding" "binding" {
  provider = google
  folder = "folders/123456789"
  role = "roles/viewer"
  members = ["allUsers"]
}

resource "google_kms_key_ring_iam_binding" "binding" {
  provider = google
  project   = var.project_id
  location  = "us-central1"
  key_ring  = "key-ring-name"
  role      = "roles/viewer"
  members   = ["allUsers"]
}

resource "google_monitoring_uptime_check_config_iam_binding" "binding" {
  provider = google
  project                  = var.project_id
  uptime_check_config_id = "uptime_check_config_id"
  role                     = "roles/viewer"
  members                  = ["allUsers"]
}

resource "google_organization_iam_binding" "binding" {
  provider = google
  org_id = "123456789"
  role = "roles/viewer"
  members = ["allUsers"]
}

resource "google_privateca_certificate_authority_iam_binding" "binding" {
  provider = google
  project                  = var.project_id
  location                 = "us-central1"
  certificate_authority = "ca-id"
  role      = "roles/viewer"
  members   = ["allUsers"]
}

resource "google_project_default_service_accounts" "project_default_sa" {
  provider = google
  project = var.project_id
  action = "DISABLE"
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
    exempted_members = [
      "user:jo****@gmail.com",
    ]
  }
}

resource "google_monitoring_group_iam_binding" "binding" {
  provider = google
  project = var.project_id
  group = "group_id"
  role = "roles/viewer"
  members = ["allUsers"]
}

resource "google_project_service_identity" "service_identity" {
  provider = google
  project = var.project_id
  service = "apikeys.googleapis.com"
}

resource "google_secret_manager_secret_iam_binding" "binding" {
  provider = google
  project = var.project_id
  secret = "secret-id"
  role = "roles/viewer"
  members = ["allUsers"]
}

resource "google_service_networking_connection_iam_binding" "binding" {
  provider = google
  project = var.project_id
  network = "network-id"
  service = "servicenetworking.googleapis.com"
  role = "roles/viewer"
  members = ["allUsers"]
}

resource "google_sql_database_instance_iam_binding" "binding" {
  provider = google
  project  = var.project_id
  name    = "database-instance-id"
  role   = "roles/viewer"
  members = ["allUsers"]
}

resource "google_storage_notification_iam_binding" "binding" {
  provider = google
  bucket   = "bucket-id"
  notification_id = "notification-id"
  role   = "roles/viewer"
  members = ["allUsers"]
}

resource "google_tpu_v2_vm_template_iam_binding" "binding" {
  provider = google
  project = var.project_id
  name = "name"
  location = "us-central1"
  role = "roles/viewer"
  members = ["allUsers"]
}

resource "google_cloudfunctions_function" "function" {
  provider = google
  project = var.project_id
  name = "audit-config-changes-alert"
  region = var.region
  description = "Alert on audit configuration changes"
  runtime = "python39"
  available_memory_mb = 256
  source_archive_bucket = "bucket-id"
  source_archive_object = "object-id"
  trigger_http = true
}

resource "google_cloudfunctions_function" "function2" {
  provider = google
  project = var.project_id
  name = "bucket-permission-changes-alert"
  region = var.region
  description = "Alert on bucket permission changes"
  runtime = "python39"
  available_memory_mb = 256
  source_archive_bucket = "bucket-id"
  source_archive_object = "object-id"
  trigger_http = true
}

resource "google_cloudfunctions_function" "function3" {
  provider = google
  project = var.project_id
  name = "custom-role-changes-alert"
  region = var.region
  description = "Alert on custom role changes"
  runtime = "python39"
  available_memory_mb = 256
  source_archive_bucket = "bucket-id"
  source_archive_object = "object-id"
  trigger_http = true
}

resource "google_cloudfunctions_function" "function4" {
  provider = google
  project = var.project_id
  name = "project-ownership-changes-alert"
  region = var.region
  description = "Alert on project ownership changes"
  runtime = "python39"
  available_memory_mb = 256
  source_archive_bucket = "bucket-id"
  source_archive_object = "object-id"
  trigger_http = true
}

resource "google_cloudfunctions_function" "function5" {
  provider = google
  project = var.project_id
  name = "sql-instance-configuration-changes-alert"
  region = var.region
  description = "Alert on sql instance configuration changes"
  runtime = "python39"
  available_memory_mb = 256
  source_archive_bucket = "bucket-id"
  source_archive_object = "object-id"
  trigger_http = true
}

resource "google_cloudfunctions_function" "function6" {
  provider = google
  project = var.project_id
  name = "vpc-firewall-rule-changes-alert"
  region = var.region
  description = "Alert on vpc firewall rule changes"
  runtime = "python39"
  available_memory_mb = 256
  source_archive_bucket = "bucket-id"
  source_archive_object = "object-id"
  trigger_http = true
}

resource "google_cloudfunctions_function" "function7" {
  provider = google
  project = var.project_id
  name = "vpc-network-changes-alert"
  region = var.region
  description = "Alert on vpc network changes"
  runtime = "python39"
  available_memory_mb = 256
  source_archive_bucket = "bucket-id"
  source_archive_object = "object-id"
  trigger_http = true
}

resource "google_cloudfunctions_function" "function8" {
  provider = google
  project = var.project_id
  name = "vpc-network-route-changes-alert"
  region = var.region
  description = "Alert on vpc network route changes"
  runtime = "python39"
  available_memory_mb = 256
  source_archive_bucket = "bucket-id"
  source_archive_object = "object-id"
  trigger_http = true
}

resource "google_storage_bucket" "ubla_buckets" {
  provider = google
  name          = "${var.project_id}.appspot.com"
  project       = var.project_id
  location      = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "ubla_buckets2" {
  provider = google
  name          = "${var.project_id}_bucket"
  project       = var.project_id
  location      = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "ubla_buckets3" {
  provider = google
  name          = "staging.${var.project_id}.appspot.com"
  project       = var.project_id
  location      = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}

resource "google_compute_subnetwork" "subnetworks" {
  provider = google
  for_each = toset(var.default_regions)
  name                     = "default-${each.key}"
  ip_cidr_range            = "10.128.0.0/20"
  network                  = "default"
  private_ip_google_access = true
  region                   = each.key
  project                  = var.
