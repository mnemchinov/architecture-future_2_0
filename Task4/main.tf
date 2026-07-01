terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone_a
}

# VPC
resource "yandex_vpc_network" "arch" {
  name = "arch-network"
}

resource "yandex_vpc_subnet" "a" {
  name           = "arch-subnet-a"
  zone           = var.zone_a
  network_id     = yandex_vpc_network.arch.id
  v4_cidr_blocks = ["10.0.1.0/24"]
  route_table_id = yandex_vpc_route_table.nat.id
}

resource "yandex_vpc_subnet" "b" {
  name           = "arch-subnet-b"
  zone           = var.zone_b
  network_id     = yandex_vpc_network.arch.id
  v4_cidr_blocks = ["10.0.2.0/24"]
  route_table_id = yandex_vpc_route_table.nat.id
}

# NAT
resource "yandex_vpc_gateway" "nat" {
  name = "arch-nat"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "nat" {
  name       = "arch-nat-rt"
  network_id = yandex_vpc_network.arch.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

# Security Groups
resource "yandex_vpc_security_group" "k8s" {
  name        = "arch-sg-k8s"
  network_id  = yandex_vpc_network.arch.id

  ingress {
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    port           = 6443
    v4_cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "db" {
  name        = "arch-sg-db"
  network_id  = yandex_vpc_network.arch.id

  ingress {
    protocol       = "TCP"
    port           = 6432
    v4_cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    protocol       = "TCP"
    port           = 9092
    v4_cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    protocol       = "TCP"
    port           = 8123
    v4_cidr_blocks = ["10.0.0.0/8"]
  }
}

resource "yandex_vpc_security_group" "bastion" {
  name        = "arch-sg-bastion"
  network_id  = yandex_vpc_network.arch.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM
resource "yandex_iam_service_account" "k8s" {
  name        = "arch-sa-k8s"
  description = "Service account for Managed K8s"
}

resource "yandex_iam_service_account" "storage" {
  name        = "arch-sa-storage"
  description = "Service account for Object Storage"
}

resource "yandex_resourcemanager_folder_iam_binding" "k8s-editor" {
  folder_id = var.folder_id
  role      = "editor"
  members   = ["serviceAccount:${yandex_iam_service_account.k8s.id}"]
}

resource "yandex_resourcemanager_folder_iam_binding" "storage-editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  members   = ["serviceAccount:${yandex_iam_service_account.storage.id}"]
}

# Managed Kubernetes
resource "yandex_kubernetes_cluster" "main" {
  name        = "arch-k8s"
  network_id  = yandex_vpc_network.arch.id

  master {
    zonal {
      zone      = var.zone_a
      subnet_id = yandex_vpc_subnet.a.id
    }
  }

  service_account_id      = yandex_iam_service_account.k8s.id
  node_service_account_id = yandex_iam_service_account.k8s.id

  depends_on = [
    yandex_resourcemanager_folder_iam_binding.k8s-editor
  ]
}

resource "yandex_kubernetes_node_group" "main" {
  name        = "arch-k8s-ng"
  cluster_id  = yandex_kubernetes_cluster.main.id

  instance_template {
    platform_id = "standard-v3"
    resources {
      cores  = var.k8s_node_cores
      memory = var.k8s_node_memory
    }
    boot_disk {
      size = var.k8s_node_disk_size
      type = "network-ssd"
    }
    network_interface {
      subnet_ids = [yandex_vpc_subnet.a.id, yandex_vpc_subnet.b.id]
    }
  }

  scale_policy {
    fixed_scale {
      size = var.k8s_node_count
    }
  }
}

# Managed PostgreSQL
resource "yandex_mdb_postgresql_cluster" "main" {
  name        = "arch-pg"
  environment = var.environment
  network_id  = yandex_vpc_network.arch.id

  config {
    version  = var.pg_version
    resources {
      resource_preset_id = var.pg_preset
      disk_size          = var.pg_disk_size
      disk_type_id       = "network-ssd"
    }
  }

  host {
    zone      = var.zone_a
    subnet_id = yandex_vpc_subnet.a.id
  }

  host {
    zone      = var.zone_b
    subnet_id = yandex_vpc_subnet.b.id
  }
}

# Managed ClickHouse
resource "yandex_mdb_clickhouse_cluster" "main" {
  name        = "arch-ch"
  environment = var.environment
  network_id  = yandex_vpc_network.arch.id

  clickhouse {
    resources {
      resource_preset_id = var.ch_preset
      disk_size          = var.ch_disk_size
      disk_type_id       = "network-ssd"
    }
  }

  host {
    zone      = var.zone_a
    subnet_id = yandex_vpc_subnet.a.id
  }
}

# Managed Kafka
resource "yandex_mdb_kafka_cluster" "main" {
  name        = "arch-kafka"
  environment = var.environment
  network_id  = yandex_vpc_network.arch.id

  config {
    version           = var.kafka_version
    brokers_count     = var.kafka_brokers
    zones             = [var.zone_a, var.zone_b]
    assign_public_ip  = false
    resources {
      resource_preset_id = var.kafka_preset
      disk_size          = var.kafka_disk_size
      disk_type_id       = "network-ssd"
    }
  }

  host {
    zone      = var.zone_a
    subnet_id = yandex_vpc_subnet.a.id
  }

  host {
    zone      = var.zone_b
    subnet_id = yandex_vpc_subnet.b.id
  }
}

# Object Storage
resource "yandex_storage_bucket" "lakehouse" {
  bucket     = var.bucket_name
  acl        = "private"

  anonymous_access_flags {
    read        = false
    list        = false
    config_read = false
  }
}

# Bastion VM
resource "yandex_compute_instance" "bastion" {
  name        = "arch-bastion"
  platform_id = "standard-v3"
  zone        = var.zone_a

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd827b91d99psvq5fjit"
      size     = 20
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.bastion.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}
