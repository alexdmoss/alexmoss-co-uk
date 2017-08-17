provider "google" {
  credentials  = ""
  project      = "moss-work"
  region       = "europe-west2"
}

resource "google_container_cluster" "cluster" {
  name = "moss-work-k8s"
  zone = "europe-west2-b"
  monitoring_service = "monitoring.googleapis.com"

  master_auth {
    username = "admin"
    password = "${var.master_auth_pwd}"
  }

  initial_node_count = 2
  node_version = "1.7.3"
  node_config {
	  machine_type = "n1-standard-1"
	  disk_size_gb = "10"

    oauth_scopes = [
    	"https://www.googleapis.com/auth/compute",
    	"https://www.googleapis.com/auth/devstorage.read_write",
    	"https://www.googleapis.com/auth/logging.write",
    	"https://www.googleapis.com/auth/monitoring"
    ]

  }

}
