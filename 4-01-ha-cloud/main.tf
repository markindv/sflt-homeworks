provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_vpc_network" "ha" {
  name        = "${var.name_prefix}-network"
  description = "Network for Netology fault-tolerance homework"
}

resource "yandex_vpc_subnet" "ha" {
  name           = "${var.name_prefix}-subnet"
  description    = "Subnet for two Nginx backends"
  zone           = var.zone
  network_id     = yandex_vpc_network.ha.id
  v4_cidr_blocks = ["10.42.0.0/24"]
}

resource "yandex_compute_instance" "web" {
  count = 2

  name        = "${var.name_prefix}-${count.index + 1}"
  hostname    = "${var.name_prefix}-${count.index + 1}"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    auto_delete = true

    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.ha.id
    nat       = true
  }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
      ssh_public_key = trimspace(file("${path.module}/id_ed25519.pub"))
    })
  }

  scheduling_policy {
    preemptible = false
  }
}

resource "yandex_lb_target_group" "web" {
  name        = "${var.name_prefix}-target-group"
  description = "Two Nginx VMs created with count"
  region_id   = "ru-central1"

  dynamic "target" {
    for_each = yandex_compute_instance.web

    content {
      subnet_id = yandex_vpc_subnet.ha.id
      address   = target.value.network_interface[0].ip_address
    }
  }
}

resource "yandex_lb_network_load_balancer" "web" {
  name        = "${var.name_prefix}-nlb"
  description = "External Network Load Balancer for Netology homework"
  type        = "external"

  listener {
    name        = "http"
    port        = 80
    target_port = 80
    protocol    = "tcp"

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.web.id

    healthcheck {
      name                = "http-healthcheck"
      interval            = 2
      timeout             = 1
      healthy_threshold   = 2
      unhealthy_threshold = 2

      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

