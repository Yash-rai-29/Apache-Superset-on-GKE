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
}

resource "google_project_service" "containeranalysis" {
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_iam_binding" "service_account_binding_compute" {
  project = "aviato-game-fight-rvxirf"
  role    = "roles/compute.editor"
  members = [
    "serviceAccount:30647320905-compute@developer.gserviceaccount.com"
  ]
}

resource "google_project_iam_binding" "service_account_binding_appspot" {
  project = "aviato-game-fight-rvxirf"
  role    = "roles/viewer"
  members = [
    "serviceAccount:aviato-game-fight-rvxirf@appspot.gserviceaccount.com"
  ]
}

resource "google_project_iam_binding" "service_account_binding_adminsdk" {
  project = "aviato-game-fight-rvxirf"
  role    = "roles/viewer"
  members = [
    "serviceAccount:firebase-adminsdk-d21rv@aviato-game-fight-rvxirf.iam.gserviceaccount.com"
  ]
}

resource "google_project_service" "cloudasset" {
  service            = "cloudasset.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_network_dns_logging_policy" "default" {
  name    = "default"
  network = "default"
}

resource "google_project_metadata" "enable_oslogin" {
  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_subnet" "default_asia_east2" {
  name          = "default"
  network       = "default"
  region        = "asia-east2"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_asia_southeast2" {
  name          = "default"
  network       = "default"
  region        = "asia-southeast2"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_us_east5" {
  name          = "default"
  network       = "default"
  region        = "us-east5"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_europe_west8" {
  name          = "default"
  network       = "default"
  region        = "europe-west8"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_europe_west3" {
  name          = "default"
  network       = "default"
  region        = "europe-west3"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_europe_west9" {
  name          = "default"
  network       = "default"
  region        = "europe-west9"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_me_central1" {
  name          = "default"
  network       = "default"
  region        = "me-central1"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_asia_south2" {
  name          = "default"
  network       = "default"
  region        = "asia-south2"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_asia_northeast3" {
  name          = "default"
  network       = "default"
  region        = "asia-northeast3"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_australia_southeast1" {
  name          = "default"
  network       = "default"
  region        = "australia-southeast1"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_asia_south1" {
  name          = "default"
  network       = "default"
  region        = "asia-south1"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_northamerica_south1" {
  name          = "default"
  network       = "default"
  region        = "northamerica-south1"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_me_west1" {
  name          = "default"
  network       = "default"
  region        = "me-west1"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_asia_northeast2" {
  name          = "default"
  network       = "default"
  region        = "asia-northeast2"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_europe_west2" {
  name          = "default"
  network       = "default"
  region        = "europe-west2"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_asia_northeast1" {
  name          = "default"
  network       = "default"
  region        = "asia-northeast1"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_me_central2" {
  name          = "default"
  network       = "default"
  region        = "me-central2"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_northamerica_northeast2" {
  name          = "default"
  network       = "default"
  region        = "northamerica-northeast2"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_southamerica_west1" {
  name          = "default"
  network       = "default"
  region        = "southamerica-west1"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_europe_west6" {
  name          = "default"
  network       = "default"
  region        = "europe-west6"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_australia_southeast2" {
  name          = "default"
  network       = "default"
  region        = "australia-southeast2"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_europe_west12" {
  name          = "default"
  network       = "default"
  region        = "europe-west12"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_us_south1" {
  name          = "default"
  network       = "default"
  region        = "us-south1"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_europe_central2" {
  name          = "default"
  network       = "default"
  region        = "europe-central2"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_europe_west4" {
  name          = "default"
  network       = "default"
  region        = "europe-west4"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_europe_west10" {
  name          = "default"
  network       = "default"
  region        = "europe-west10"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_asia_southeast1" {
  name          = "default"
  network       = "default"
  region        = "asia-southeast1"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_asia_east1" {
  name          = "default"
  network       = "default"
  region        = "asia-east1"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_us_west1" {
  name          = "default"
  network       = "default"
  region        = "us-west1"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_europe_west1" {
  name          = "default"
  network       = "default"
  region        = "europe-west1"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_northamerica_northeast1" {
  name          = "default"
  network       = "default"
  region        = "northamerica-northeast1"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_europe_north1" {
  name          = "default"
  network       = "default"
  region        = "europe-north1"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_africa_south1" {
  name          = "default"
  network       = "default"
  region        = "africa-south1"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_southamerica_east1" {
  name          = "default"
  network       = "default"
  region        = "southamerica-east1"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_us_west4" {
  name          = "default"
  network       = "default"
  region        = "us-west4"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_us_west3" {
  name          = "default"
  network       = "default"
  region        = "us-west3"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_us_east4" {
  name          = "default"
  network       = "default"
  region        = "us-east4"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_us_central1" {
  name          = "default"
  network       = "default"
  region        = "us-central1"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_us_west2" {
  name          = "default"
  network       = "default"
  region        = "us-west2"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_europe_southwest1" {
  name          = "default"
  network       = "default"
  region        = "europe-southwest1"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_compute_subnet" "default_us_east1" {
  name          = "default"
  network       = "default"
  region        = "us-east1"
  ip_cidr_range = "10.128.0.0/20"
  enable_flow_logs = true
}

resource "google_storage_bucket" "default" {
  name                        = "aviato-game-fight-rvxirf.appspot.com"
  location                    = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "custom" {
  name                        = "aviato-game-fight-rvxirf_bucket"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "staging" {
  name                        = "staging.aviato-game-fight-rvxirf.appspot.com"
  location                    = "AUSTRALIA-SOUTHEAST1"
  uniform_bucket_level_access = true
}

resource "google_compute_firewall" "default-allow-ssh" {
  name    = "default-allow-ssh"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["10.0.0.0/8"]
}

resource "google_compute_firewall" "default-allow-rdp" {
  name    = "default-allow-rdp"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  source_ranges = ["10.0.0.0/8"]
}
resource "google_logging_project_sink" "default" {
  name = "all-logs"
  destination = "bigquery.googleapis.com/aviato-game-fight-rvxirf:all_logs"
  filter = "NOT logName:\"projects/${data.google_project.project.number}/logs/cloudaudit.googleapis.com%2Fdata_access\""
}

data "google_project" "project" {
}

resource "google_logging_metric" "audit_config_changes" {
  name        = "audit-config-changes"
  description = "This metric counts the number of audit config changes."
  project     = data.google_project.project.project_id
  filter      = "resource.type=audited_resource AND severity>=NOTICE AND logName:activity AND (protoPayload.methodName:SetIamPolicy OR protoPayload.methodName:InsertRole OR protoPayload.methodName:UpdateRole OR protoPayload.methodName:DeleteRole)"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_monitoring_alert_policy" "audit_config_changes" {
  display_name = "Audit Configuration Changes Alert"
  project      = data.google_project.project.project_id
  combiner     = "OR"
  conditions {
    display_name = "Audit Config Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/audit-config-changes\" resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "bucket_permission_changes" {
  name        = "bucket-permission-changes"
  description = "This metric counts the number of bucket permission changes."
  project     = data.google_project.project.project_id
  filter      = "resource.type=gcs_bucket AND severity>=NOTICE AND logName:activity AND (protoPayload.methodName:storage.setIamPermissions OR protoPayload.methodName:SetIamPolicy)"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes" {
  display_name = "Bucket Permission Changes Alert"
  project      = data.google_project.project.project_id
  combiner     = "OR"
  conditions {
    display_name = "Bucket Permission Changes Condition"
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
  description = "This metric counts the number of custom role changes."
  project     = data.google_project.project.project_id
  filter      = "resource.type=iam_role AND severity>=NOTICE AND logName:activity AND (protoPayload.methodName:CreateRole OR protoPayload.methodName:UpdateRole OR protoPayload.methodName:DeleteRole)"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes" {
  display_name = "Custom Role Changes Alert"
  project      = data.google_project.project.project_id
  combiner     = "OR"
  conditions {
    display_name = "Custom Role Changes Condition"
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
  description = "This metric counts the number of project ownership changes."
  project     = data.google_project.project.project_id
  filter      = "resource.type=project AND severity>=NOTICE AND logName:activity AND (protoPayload.methodName:SetIamPolicy OR protoPayload.methodName:InsertRole OR protoPayload.methodName:UpdateRole OR protoPayload.methodName:DeleteRole)"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes" {
  display_name = "Project Ownership Changes Alert"
  project      = data.google_project.project.project_id
  combiner     = "OR"
  conditions {
    display_name = "Project Ownership Changes Condition"
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
  description = "This metric counts the number of SQL instance configuration changes."
  project     = data.google_project.project.project_id
  filter      = "resource.type=cloudsql_instance AND severity>=NOTICE AND logName:activity AND (protoPayload.methodName:cloudsql.instances.update OR protoPayload.methodName:cloudsql.instances.patch)"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_monitoring_alert_policy" "sql_instance_configuration_changes" {
  display_name = "SQL Instance Configuration Changes Alert"
  project      = data.google_project.project.project_id
  combiner     = "OR"
  conditions {
    display_name = "SQL Instance Configuration Changes Condition"
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
  description = "This metric counts the number of VPC firewall rule changes."
  project     = data.google_project.project.project_id
  filter      = "resource.type=gce_firewall AND severity>=NOTICE AND logName:activity AND (protoPayload.methodName:compute.firewalls.insert OR protoPayload.methodName:compute.firewalls.patch OR protoPayload.methodName:compute.firewalls.update)"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes" {
  display_name = "VPC Firewall Rule Changes Alert"
  project      = data.google_project.project.project_id
  combiner     = "OR"
  conditions {
    display_name = "VPC Firewall Rule Changes Condition"
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
  description = "This metric counts the number of VPC network changes."
  project     = data.google_project.project.project_id
  filter      = "resource.type=gce_network AND severity>=NOTICE AND logName:activity AND (protoPayload.methodName:compute.networks.insert OR protoPayload.methodName:compute.networks.patch OR protoPayload.methodName:compute.networks.update)"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes" {
  display_name = "VPC Network Changes Alert"
  project      = data.google_project.project.project_id
  combiner     = "OR"
  conditions {
    display_name = "VPC Network Changes Condition"
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
  description = "This metric counts the number of VPC network route changes."
  project     = data.google_project.project.project_id
  filter      = "resource.type=gce_route AND severity>=NOTICE AND logName:activity AND (protoPayload.methodName:compute.routes.insert OR protoPayload.methodName:compute.routes.delete)"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes" {
  display_name = "VPC Network Route Changes Alert"
  project      = data.google_project.project.project_id
  combiner     = "OR"
  conditions {
    display_name = "VPC Network Route Changes Condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-route-changes\" resource.type=\"gcp_project\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  }
  notification_channels = []
}
