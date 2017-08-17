provider "google" {
  credentials  = ""
  project      = "moss-work"
  region       = "us-east1"
}

resource "google_container_cluster" "cluster" {
  name = "moss-work-k8s"
  # US regions (not including W Virginia) give one free f1-micro
  zone = "us-east1-b"
  #additional_zones = ["us-east1-c", "us-east1-d"]
  monitoring_service = "monitoring.googleapis.com"

  master_auth {
    username = "admin"
    password = "${var.master_auth_pwd}"
  }

  initial_node_count = 3
  node_version = "1.6.4"
  node_config {
	  machine_type = "f1-micro"
	  disk_size_gb = "20"

    oauth_scopes = [
    	"https://www.googleapis.com/auth/compute",
    	"https://www.googleapis.com/auth/devstorage.read_write",
    	"https://www.googleapis.com/auth/logging.write",
    	"https://www.googleapis.com/auth/monitoring"
    ]

  }

#  scheduling {
#    automatic_restart   = true
#    on_host_maintenance = "MIGRATE"
#    preemptible = true
#  }

}
