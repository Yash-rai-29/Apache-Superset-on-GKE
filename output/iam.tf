data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_iam_member" "project" {
  count  = length(data.google_project.project.project_id) > 0 ? 1 : 0
  project = data.google_project.project.project_id
  role   = "roles/viewer"
  member = "allUsers"
}
