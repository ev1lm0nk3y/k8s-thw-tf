resource "google_compute_instance" "controllers" {
  count        = 3
  name         = "controller-${count.index}"
  machine_type = "n1-standard-1"
  zone         = "us-east1-c"

  network_interface = {
    subnetwork         = google_compute_subnetwork.k8s_thw.name
    can_ip_forward     = true
    private_network_ip = "10.240.0.1${count.index}"

    boot_disk = {
      initialize_params = {
        size  = 200
        image = "ubuntu-os-cloud/ubuntu-1804-lts"
      }
    }
  }

  tags = [
    "k8s-thw",
    "controller",
  ]

  service_account = {
    scopes = [
      "compute-rw",
      "storage-ro",
      "service-management",
      "service-control",
      "logging-write,monitoring",
    ]
  }
}
