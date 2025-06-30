resource "google_project_organization_policy" "oslogin" {
  project = var.project_id
  constraint = "compute.requireOsLogin"

  boolean_policy {
    enforced = true
  }
}
