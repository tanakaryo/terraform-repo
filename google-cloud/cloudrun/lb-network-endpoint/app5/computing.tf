resource "google_compute_instance" "web_server" {
  project = var.project_id
  name = "${var.name}-web-server"
  zone = "${var.region}-a"
  machine_type = "e2-micro"

  tags = [ "lb-tag" ]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size = "10"
    }
  }

  network_interface {
    network = google_compute_network.lb_network.id
    subnetwork = google_compute_subnetwork.lb_subnet.id
    access_config {
    }
  }

  metadata_startup_script = "sudo apt update; sudo apt install nginx -y; sudo systemctl start nginx"
}

resource "google_compute_instance_group" "web_server_group" {
    project = var.project_id
    zone = "${var.region}-a"
    name = "${var.name}-web-server-group"
    
    instances = [ google_compute_instance.web_server.self_link ]

    named_port {
      name = "tcp"
      port = "80"
    }

}