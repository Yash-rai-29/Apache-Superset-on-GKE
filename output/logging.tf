resource "google_project_service" "logging" {
  service = "logging.googleapis.com"
  disable_on_destroy = false
}

resource "google_logging_project_sink" "log_sink" {
  name = "all-logs-sink"
  project = var.project_id
  description = "Sink for all logs in the project"
  destination = "storage.googleapis.com/your-bucket-name"
  filter = "NOT logName:projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Fdata_access"

  depends_on = [google_project_service.logging]
}

resource "google_logging_metric" "audit_config_changes" {
  name = "audit-config-changes"
  project = var.project_id
  description = "Metric for audit configuration changes"
  filter = "resource.type=audited_resource AND protoPayload.methodName=SetIamPolicy"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "audit_config_changes_alert" {
  display_name = "Alert for Audit Configuration Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Condition for Audit Configuration Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/audit-config-changes\" resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "bucket_permission_changes" {
  name = "bucket-permission-changes"
  project = var.project_id
  description = "Metric for Cloud Storage IAM Permission Changes"
  filter = "resource.type=gcs_bucket AND protoPayload.methodName=storage.setIamPermissions"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes_alert" {
  display_name = "Alert for Cloud Storage IAM Permission Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Condition for Cloud Storage IAM Permission Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/bucket-permission-changes\" resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "custom_role_changes" {
  name = "custom-role-changes"
  project = var.project_id
  description = "Metric for Custom Role Changes"
  filter = "resource.type=iam_role AND protoPayload.methodName=google.iam.admin.v1.CreateRole"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes_alert" {
  display_name = "Alert for Custom Role Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Condition for Custom Role Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/custom-role-changes\" resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "project_ownership_changes" {
  name = "project-ownership-changes"
  project = var.project_id
  description = "Metric for Project Ownership Assignments/Changes"
  filter = "resource.type=gcp_project AND protoPayload.methodName=SetIamPolicy AND protoPayload.serviceData.policyDelta.bindingDeltas.member=\"user:*@*\" AND protoPayload.serviceData.policyDelta.bindingDeltas.role=\"roles/owner\""
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes_alert" {
  display_name = "Alert for Project Ownership Assignments/Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Condition for Project Ownership Assignments/Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/project-ownership-changes\" resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "sql_instance_config_changes" {
  name = "sql-instance-config-changes"
  project = var.project_id
  description = "Metric for SQL Instance Configuration Changes"
  filter = "resource.type=cloudsql_database AND protoPayload.methodName=cloudsql.instances.update"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "sql_instance_config_changes_alert" {
  display_name = "Alert for SQL Instance Configuration Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Condition for SQL Instance Configuration Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/sql-instance-config-changes\" resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_firewall_rule_changes" {
  name = "vpc-firewall-rule-changes"
  project = var.project_id
  description = "Metric for VPC Network Firewall Rule Changes"
  filter = "resource.type=gce_firewall_rule AND protoPayload.methodName=compute.firewalls.insert"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_firewall_rule_changes_alert" {
  display_name = "Alert for VPC Network Firewall Rule Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Condition for VPC Network Firewall Rule Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-firewall-rule-changes\" resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_network_changes" {
  name = "vpc-network-changes"
  project = var.project_id
  description = "Metric for VPC Network Changes"
  filter = "resource.type=gce_network AND protoPayload.methodName=compute.networks.insert"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_changes_alert" {
  display_name = "Alert for VPC Network Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Condition for VPC Network Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-changes\" resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  notification_channels = []
}

resource "google_logging_metric" "vpc_network_route_changes" {
  name = "vpc-network-route-changes"
  project = var.project_id
  description = "Metric for VPC Network Route Changes"
  filter = "resource.type=gce_route AND protoPayload.methodName=compute.routes.insert"
  metric_descriptor {
    metric_kind = "COUNTER"
    value_type = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_network_route_changes_alert" {
  display_name = "Alert for VPC Network Route Changes"
  project = var.project_id
  combiner = "OR"
  conditions {
    display_name = "Condition for VPC Network Route Changes"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-network-route-changes\" resource.type=\"gcp_project\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  notification_channels = []
}
