resource "google_compute_instance" "web_server" {
    name = "web-server"
    machine_type = "e2-micro"
    zone = "${var.region}-a"

    tags = [ "web" ]

    boot_disk {
      initialize_params {
        image = "debian-cloud/debian-12"
        size = "10"
        type = "pd-standard"
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

resource "google_compute_instance_group" "vm_group" {
    name = "web-server-group"
    description = "web-server instance group"
    zone = "${var.region}-a"

    instances = [ google_compute_instance.web_server.self_link ]

    named_port {
      name = "http"
      port = "80"
    }
}