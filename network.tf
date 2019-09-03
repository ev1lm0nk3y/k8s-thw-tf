resource "google_compute_network" "k8s_thw" {
  name                    = "k8s-thw-tf"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "k8s_thw" {
  name          = "k8s-thw-sn"
  ip_cidr_range = "10.240.0.0/24"
  network       = google_compute_network.k8s_thw.name
}

resource "google_compute_firewall" "k8s_thw_allow_internal" {
  name    = "k8s-thw-allow-internal"
  network = google_compute_network.k8s_thw.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  source_ranges = [
    "10.240.0.0/24",
    "10.200.0.0/16",
  ]
}

resource "google_compute_firewall" "k8s_thw_allow_external" {
  name    = "k8s-thw-allow-external"
  network = google_compute_network.k8s_thw.name

  allow {
    protocol = "tcp"
    ports    = ["22", "6443"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    "0.0.0.0/0",
  ]
}

resource "google_compute_address" "k8s_thw_address" {
  name = "k8s-thw"
}
