resource "google_project_service" "apikeys" {
  service            = "apikeys.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_iam_member" "apikeys_accessors" {
  count = 10
  project = var.project_id
  role = "roles/apikeys.viewer"
  member = "user:apikeys_accessor_${count}@example.com"

  depends_on = [google_project_service.apikeys]
}

resource "google_api_gateway_api_config_iam_member" "api_config_accessors" {
  count = 10
  api_config = "example-api-config"
  api = "example-api"
  location = "us-central1"
  role = "roles/apikeys.viewer"
  member = "user:api_config_accessor_${count}@example.com"

  depends_on = [google_project_iam_member.apikeys_accessors]
}

resource "google_apikeys_key" "keys" {
  count = 3
  name = "${var.key_prefix}-${count}"
  project = var.project_id
  restrictions {
    api_targets {
      service  = "translate.googleapis.com"
      methods = ["translate"]
    }
  }

  depends_on = [google_api_gateway_api_config_iam_member.api_config_accessors]
}

resource "google_apikeys_key" "rotate_keys" {
  count = 3
  name = "key_rotate-${count}"
  project = var.project_id
  restrictions {
    api_targets {
      service  = "translate.googleapis.com"
      methods = ["translate"]
    }
  }
  destroy_after = var.key_rotation_interval

  depends_on = [google_apikeys_key.keys]
}
