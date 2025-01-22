resource "google_compute_firewall" "ssh_fw" {
    name = "allow-ssh"
    project = var.project_id
    network = google_compute_network.lb_network.id
    priority = 1000
    source_ranges = ["0.0.0.0/0"]
    target_tags = ["ssh"]
    direction = "INGRESS"
    allow {
      protocol = "tcp"
      ports = ["22"]
    }
}

resource "google_compute_firewall" "http_fw" {
    name = "allow-http-https"
    project = var.project_id
    network = google_compute_network.lb_network.id
    priority = 1000
    source_ranges = [ "0.0.0.0/0" ]
    target_tags = [ "web" ]
    direction = "INGRESS"
    allow {
      protocol = "tcp"
      ports = [ "80", "443" ]
    }
}

resource "google_compute_firewall" "web_fw" {
    name = "web-fw"
    project = var.project_id
    network = google_compute_network.lb_network.id

    allow {
      protocol = "tcp"
      ports = [ "80" ]
    }

    source_ranges = [ 
        "130.211.0.0/22",
        "35.191.0.0/16"
     ]

     target_tags = [ "web" ]
}