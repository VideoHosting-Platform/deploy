terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.85"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.8"
    }
  }
}

provider "yandex" {
  service_account_key_file     = var.service_account_key_file
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}


# Создание сервисного аккаунта для Kubernetes
resource "yandex_iam_service_account" "k8s-admin" {
  name        = "k8s-admin"
  description = "Service account for managing Kubernetes cluster"
}

# Назначение ролей сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_binding" "k8s-admin" {
  folder_id = var.folder_id
  role      = "editor"
  members   = [
    "serviceAccount:${yandex_iam_service_account.k8s-admin.id}"
  ]
}

# Создание статического ключа доступа для сервисного аккаунта
resource "yandex_iam_service_account_static_access_key" "k8s-sa-key" {
  service_account_id = yandex_iam_service_account.k8s-admin.id
}

# Создание Managed Kubernetes кластера
resource "yandex_kubernetes_cluster" "mk8s-cluster" {
  name        = "mk8s-cluster"
  description = "Managed Kubernetes cluster for applications"
  network_id  = yandex_vpc_network.k8s-network.id

  master {
    version   = "1.31"
    public_ip = true
    zonal {
      zone      = var.zone
      subnet_id = yandex_vpc_subnet.k8s-subnet.id
    }
  }

  service_account_id      = yandex_iam_service_account.k8s-admin.id
  node_service_account_id = yandex_iam_service_account.k8s-admin.id

  depends_on = [
    yandex_resourcemanager_folder_iam_binding.k8s-admin
  ]
}

# Создание группы узлов Kubernetes
resource "yandex_kubernetes_node_group" "k8s-node-group" {
  cluster_id  = yandex_kubernetes_cluster.mk8s-cluster.id
  name        = "k8s-node-group"
  description = "Kubernetes node group"
  version     = "1.31"

  instance_template {
    platform_id = "standard-v2"  # Можно рассмотреть "standard-v1" для еще большей экономии
    resources {
      memory = 4    # Уменьшил память с 8 до 4 ГБ
      cores  = 2    # Уменьшил количество ядер с 4 до 2
    }

    boot_disk {
      type = "network-hdd"
      size = 32    # Уменьшил размер диска с 64 до 32 ГБ
    }

    network_interface {
      subnet_ids = [yandex_vpc_subnet.k8s-subnet.id]
      nat        = true
    }

    metadata = {
      ssh-keys = "ubuntu:${file("/home/${var.username}/.ssh/cloud.pub")}"
    }
  }
  
  scale_policy {
    auto_scale {
      min = 1
      max = 3
      initial = 2
    }
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }
}

# Создание VPC сети
resource "yandex_vpc_network" "k8s-network" {
  name = "k8s-network"
}

# Создание подсети
resource "yandex_vpc_subnet" "k8s-subnet" {
  name           = "k8s-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.k8s-network.id
  v4_cidr_blocks = ["10.10.0.0/16"]
}

provider "helm" {
  kubernetes {
    host                   = yandex_kubernetes_cluster.mk8s-cluster.master[0].external_v4_endpoint
    cluster_ca_certificate = yandex_kubernetes_cluster.mk8s-cluster.master[0].cluster_ca_certificate
    token                  = data.yandex_client_config.client.iam_token
  }
}

data "yandex_client_config" "client" {}

#

output "k8s_external_endpoint" {
  value = yandex_kubernetes_cluster.mk8s-cluster.master[0].external_v4_endpoint
}