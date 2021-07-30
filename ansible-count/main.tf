terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
  token     = var.yc_token
}

resource "yandex_compute_instance" "vm-1" {

  count = var.num

  name = "terraform-${count.index}"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  provisioner "remote-exec" {
    inline = ["echo alive!!!!"]

    connection {
      host        = self.network_interface.0.nat_ip_address
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
    }
  }


}


resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "null_resource" "ansible-install" {
  count = var.num
  provisioner "local-exec" {
    command = format("ansible-playbook -D -i %s, -u ubuntu ${path.module}/provision/provision.yml",
    yandex_compute_instance.vm-1[count.index].network_interface[0].nat_ip_address != "" ? yandex_compute_instance.vm-1[count.index].network_interface[0].nat_ip_address : yandex_compute_instance.vm-1[count.index].network_interface[0].ip_address,
    )
  }

  
}
