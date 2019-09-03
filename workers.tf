resource "google_compute_instance" "workers" {
  count        = 3
  name         = "worker-${count.index}"
  machine_type = "n1-standard-1"
  zone         = "us-east1-c"

  network_interface  = google_compute_subnetwork.k8s_thw.name
  can_ip_forward     = true
  private_network_ip = "10.240.0.2${count.index}"

  boot_disk = {
    initialize_params = {
      size  = 200
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  metadata = {
    pod-cidr = "10.240.${count.index}.0/24"
  }

  provisioner "local-exec" {
    command = "echo ${template_file.worker_csrs.rendered[count.index]}| cfssl gencert -ca=generated/ca.pem -ca-key=generated/ca-key.pem -config=files/ca-config.json -hostname=${element(google_compute_instance.workers.name, count.index)},${element(google_compute_instance.workers.network_interface_0.access_config.0.nat_ip, count.index)},${element(google_compute_instance.workers.network_interface.0.network_ip, count.index)} -profile | cfssljson -bar generated/worker-${count.index} && gsutil generated/worker-${count.index} gs://${google_storage_bucket.name}/worker.json"
  }

  tags = [
    "k8s-thw",
    "worker",
  ]

  service_account = {
    scopes = [
      "compute-rw",
      "storage-ro",
      "service-management",
      "service-control",
      "logging-write",
      "monitoring",
    ]
  }
}
