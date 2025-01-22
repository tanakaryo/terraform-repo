resource "google_compute_health_check" "lb_health_check" {
    name = "${var.name}-health-check"
    project = var.project_id
    timeout_sec = 1
    check_interval_sec = 1

    tcp_health_check {
      port = 80
    }
}

resource "google_compute_health_check" "tracking_lb" {
    name = "tracking-lb"
    project = var.project_id
    timeout_sec = 5
    check_interval_sec = 5
    healthy_threshold = 4
    unhealthy_threshold = 5

    http_health_check {
      port = 80
    }
}