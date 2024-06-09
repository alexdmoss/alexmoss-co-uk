resource "google_cloud_run_v2_service" "default" {
  name     = var.app_name
  project  = var.gcp_project_id
  location = "europe-west1"
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = var.image_tag
    }
  }
}
