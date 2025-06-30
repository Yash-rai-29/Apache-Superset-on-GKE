resource "google_logging_metric" "audit_config_changes" {
  provider = google
  name   = "audit-config-changes"
  project = var.project_id
  filter = "protoPayload.methodName=\"SetIamPolicy\" OR protoPayload.methodName=\"google.cloud.audit.AuditPolicies.updateAuditConfig\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "audit_config_changes_alert" {
  provider = google
  project      = var.project_id
  display_name = "Audit Config Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "Audit Config Changes Condition"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/audit-config-changes\" AND resource.type=\"gcp_project\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
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
  filter = "resource.type=\"gcs_bucket\" AND protoPayload.methodName=\"storage.setIamPermissions\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes_alert" {
  provider = google
  project      = var.project_id
  display_name = "Bucket Permission Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "Bucket Permission Changes Condition"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/bucket-permission-changes\" AND resource.type=\"gcp_project\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
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
  filter = "resource.type=\"iam_role\" AND protoPayload.methodName=\"google.iam.admin.v1.CreateRole\" OR protoPayload.methodName=\"google.iam.admin.v1.DeleteRole\" OR protoPayload.methodName=\"google.iam.admin.v1.UpdateRole\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes_alert" {
  provider = google
  project      = var.project_id
  display_name = "Custom Role Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "Custom Role Changes Condition"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/custom-role-changes\" AND resource.type=\"gcp_project\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
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
  filter = "protoPayload.serviceName=\"cloudresourcemanager.googleapis.com\" AND protoPayload.methodName=\"SetIamPolicy\" AND resource.type=\"project\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes_alert" {
  provider = google
  project      = var.project_id
  display_name = "Project Ownership Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "Project Ownership Changes Condition"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/project-ownership-changes\" AND resource.type=\"gcp_project\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "sql_instance_config_changes" {
  provider = google
  name   = "sql-instance-config-changes"
  project = var.project_id
  filter = "resource.type=\"cloudsql_database_instance\" AND protoPayload.methodName=\"cloudsql.instances.update\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "sql_instance_config_changes_alert" {
  provider = google
  project      = var.project_id
  display_name = "SQL Instance Config Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "SQL Instance Config Changes Condition"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/sql-instance-config-changes\" AND resource.type=\"gcp_project\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
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
  filter = "resource.type=\"gce_firewall_rule\" AND protoPayload.methodName=\"compute.firewalls.insert\" OR protoPayload.methodName=\"compute.firewalls.delete\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes_alert" {
  provider = google
  project      = var.project_id
  display_name = "VPC Firewall Rule Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "VPC Firewall Rule Changes Condition"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/vpc-firewall-rule-changes\" AND resource.type=\"gcp_project\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
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
  filter = "resource.type=\"gce_network\" AND protoPayload.methodName=\"compute.networks.insert\" OR protoPayload.methodName=\"compute.networks.delete\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes_alert" {
  provider = google
  project      = var.project_id
  display_name = "VPC Network Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "VPC Network Changes Condition"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/vpc-network-changes\" AND resource.type=\"gcp_project\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
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
  filter = "resource.type=\"gce_route\" AND protoPayload.methodName=\"compute.routes.insert\" OR protoPayload.methodName=\"compute.routes.delete\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes_alert" {
  provider = google
  project      = var.project_id
  display_name = "VPC Network Route Changes Alert"
  combiner     = "OR"
  conditions {
    display_name = "VPC Network Route Changes Condition"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/vpc-network-route-changes\" AND resource.type=\"gcp_project\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  notification_channels = []
}
