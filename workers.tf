resource "google_compute_instance" "workers" {
  count        = 3
  name         = "worker-${count.index}"
  machine_type = "n1-standard-1"
  zone         = "us-east1-c"

  can_ip_forward = true

  network_interface {
    network_ip = "10.240.0.2${count.index}"
    subnetwork = google_compute_subnetwork.k8s_thw.name
  }

  boot_disk {
    initialize_params {
      size  = 200
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  metadata = {
    pod-cidr = "10.240.${count.index}.0/24"
  }

  metadata_startup_script = "gsutil cp ${google_storage_bucket.k8s_thw.name}/generated/{ca,worker-${count.index}-key,worker-${count.index},kubernetes}.pem ${HOME}"

  tags = [
    "k8s-thw",
    "worker",
  ]

  service_account {
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

data "template_file" "worker_csrs" {
  count    = 3
  template = "files/worker-csr.json.tpl"

  vars = {
    instance = "worker-${count.index}"
    city     = var.city
    state    = var.state
  }
}

resource "google_storage_bucket_object" "worker_csrs" {
  count  = 3
  bucket = google_storage_bucket.k8s_thw.name
  name   = "worker-${count.index}"

  content = data.template_file.worker_csrs[count.index].rendered
}

resource "null_resource" "worker_certs" {
  count = 3
  provisioner "local-exec" {
    command = "echo ${data.template_file.worker_csrs[count.index].rendered}| cfssl gencert -ca=generated/ca.pem -ca-key=generated/ca-key.pem -config=files/ca-config.json -hostname=${google_compute_instance.workers[count.index].name},${google_compute_instance.workers[count.index].network_interface_0.access_config.0.nat_ip},${google_compute_instance.workers[count.index].network_interface.0.network_ip} -profile=kubernetes - | cfssljson -bare generated/worker-${count.index} && gsutil generated/worker-${count.index}.* gs://${google_storage_bucket.k8s_thw.name}/"
  }

  depends_on = [
    google_compute_instance.workers,
    null_resource.generate_cert_auth,
  ]
}
