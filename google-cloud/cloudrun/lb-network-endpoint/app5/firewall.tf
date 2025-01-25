resource "google_compute_firewall" "allow_network_ipv4" {
    network = google_compute_network.lb_network.id
    name = "allow-network-ipv4"

    target_tags = [ "lb-tag" ]

    source_ranges = [ "0.0.0.0/0" ]

    allow {
      protocol = "tcp"
      ports = ["80"]
    }
  
}