resource "google_logging_metric" "audit_configuration_changes" {
  provider = google
  name        = "audit-configuration-changes"
  project     = var.project_id
  description = "Count of audit configuration changes"
  filter      = "logName:cloudaudit.googleapis.com"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "audit_configuration_changes" {
  provider = google
  project      = var.project_id
  display_name = "Alert for Audit Configuration Changes"
  combiner     = "OR"
  conditions {
    display_name = "Condition for Audit Configuration Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/audit-configuration-changes\" AND resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "bucket_permission_changes" {
  provider = google
  name        = "bucket-permission-changes"
  project     = var.project_id
  description = "Count of bucket permission changes"
  filter      = "logName:cloudaudit.googleapis.com AND resource.type=gcs_bucket"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes" {
  provider = google
  project      = var.project_id
  display_name = "Alert for Bucket Permission Changes"
  combiner     = "OR"
  conditions {
    display_name = "Condition for Bucket Permission Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/bucket-permission-changes\" AND resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "custom_role_changes" {
  provider = google
  name        = "custom-role-changes"
  project     = var.project_id
  description = "Count of custom role changes"
  filter      = "logName:cloudaudit.googleapis.com AND protoPayload.methodName=\"google.iam.admin.v1.CreateRole\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes" {
  provider = google
  project      = var.project_id
  display_name = "Alert for Custom Role Changes"
  combiner     = "OR"
  conditions {
    display_name = "Condition for Custom Role Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/custom-role-changes\" AND resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "project_ownership_changes" {
  provider = google
  name        = "project-ownership-changes"
  project     = var.project_id
  description = "Count of project ownership changes"
  filter      = "logName:cloudaudit.googleapis.com AND protoPayload.methodName=\"SetIamPolicy\" AND resource.type=\"project\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes" {
  provider = google
  project      = var.project_id
  display_name = "Alert for Project Ownership Changes"
  combiner     = "OR"
  conditions {
    display_name = "Condition for Project Ownership Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/project-ownership-changes\" AND resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "sql_instance_configuration_changes" {
  provider = google
  name        = "sql-instance-configuration-changes"
  project     = var.project_id
  description = "Count of sql instance configuration changes"
  filter      = "logName:cloudaudit.googleapis.com AND resource.type=cloudsql_database_instance"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "sql_instance_configuration_changes" {
  provider = google
  project      = var.project_id
  display_name = "Alert for SQL Instance Configuration Changes"
  combiner     = "OR"
  conditions {
    display_name = "Condition for SQL Instance Configuration Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/sql-instance-configuration-changes\" AND resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  provider = google
  name        = "vpc-firewall-rule-changes"
  project     = var.project_id
  description = "Count of vpc firewall rule changes"
  filter      = "logName:cloudaudit.googleapis.com AND resource.type=gce_firewall_rule"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes" {
  provider = google
  project      = var.project_id
  display_name = "Alert for VPC Firewall Rule Changes"
  combiner     = "OR"
  conditions {
    display_name = "Condition for VPC Firewall Rule Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-firewall-rule-changes\" AND resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_network_changes" {
  provider = google
  name        = "vpc-network-changes"
  project     = var.project_id
  description = "Count of vpc network changes"
  filter      = "logName:cloudaudit.googleapis.com AND resource.type=gce_network"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes" {
  provider = google
  project      = var.project_id
  display_name = "Alert for VPC Network Changes"
  combiner     = "OR"
  conditions {
    display_name = "Condition for VPC Network Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-changes\" AND resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_network_route_changes" {
  provider = google
  name        = "vpc-network-route-changes"
  project     = var.project_id
  description = "Count of vpc network route changes"
  filter      = "logName:cloudaudit.googleapis.com AND resource.type=gce_route"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes" {
  provider = google
  project      = var.project_id
  display_name = "Alert for VPC Network Route Changes"
  combiner     = "OR"
  conditions {
    display_name = "Condition for VPC Network Route Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-route-changes\" AND resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }
  notification_channels = []
}
