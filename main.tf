terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.85"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.16"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.8"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
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
    platform_id = "standard-v2"
    resources {
      memory = 8
      cores  = 4
    }

    boot_disk {
      type = "network-hdd"
      size = 64
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
    fixed_scale {
      size = 3
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

# Настройка провайдеров Kubernetes и Helm
provider "kubernetes" {
  host                   = yandex_kubernetes_cluster.mk8s-cluster.master[0].external_v4_endpoint
  cluster_ca_certificate = yandex_kubernetes_cluster.mk8s-cluster.master[0].cluster_ca_certificate
  token                  = data.yandex_client_config.client.iam_token
}

provider "helm" {
  kubernetes {
    host                   = yandex_kubernetes_cluster.mk8s-cluster.master[0].external_v4_endpoint
    cluster_ca_certificate = yandex_kubernetes_cluster.mk8s-cluster.master[0].cluster_ca_certificate
    token                  = data.yandex_client_config.client.iam_token
  }
}

data "yandex_client_config" "client" {}

# # Добавление Helm репозиториев
# resource "helm_release" "minio-repo" {
#   name             = "minio"
#   repository       = "https://charts.min.io/"
#   chart            = "minio"
#   version          = "4.0.12"
#   namespace        = "minio"
#   create_namespace = true

#   values = [
#     file("kuber/minio-values.yaml")
#   ]
# }

# resource "helm_release" "prometheus-repo" {
#   name             = "prometheus-community"
#   repository       = "https://prometheus-community.github.io/helm-charts"
#   chart            = "kube-prometheus-stack"
#   version          = "46.8.0"
#   namespace        = "monitoring"
#   create_namespace = true

#   set {
#     name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
#     value = "false"
#   }

#   set {
#     name  = "prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues"
#     value = "false"
#   }

#   set {
#     name  = "prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues"
#     value = "false"
#   }

#   set {
#     name  = "alertmanager.alertmanagerSpec.alertmanagerConfigSelectorNilUsesHelmValues"
#     value = "false"
#   }

#   set {
#     name  = "grafana.enabled"
#     value = "false"
#   }
# }

# resource "helm_release" "grafana-repo" {
#   name             = "grafana"
#   repository       = "https://grafana.github.io/helm-charts"
#   chart            = "loki-stack"
#   namespace        = "monitoring"
#   create_namespace = true

#   values = [
#     file("kuber/loki-values.yaml")
#   ]
# }

# resource "helm_release" "traefik-repo" {
#   name             = "traefik"
#   repository       = "https://traefik.github.io/charts"
#   chart            = "traefik"
#   namespace        = "traefik"
#   create_namespace = true

#   set {
#     name  = "providers.kubernetesGateway.enabled"
#     value = "true"
#   }

#   set {
#     name  = "service.type"
#     value = "NodePort"
#   }
# }

# # Установка RabbitMQ Cluster Operator
# provider "kubectl" {
#   host                   = yandex_kubernetes_cluster.mk8s-cluster.master[0].external_v4_endpoint
#   cluster_ca_certificate = yandex_kubernetes_cluster.mk8s-cluster.master[0].cluster_ca_certificate
#   token                  = data.yandex_client_config.client.iam_token
#   load_config_file       = false
# }

# data "http" "rabbitmq_operator" {
#   url = "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"
# }

# resource "kubectl_manifest" "rabbitmq_operator" {
#   yaml_body = data.http.rabbitmq_operator.response_body
#   apply_only = true # Чтобы избежать ошибок если ресурсы уже существуют
# }

# data "http" "traefik_crd" {
#   url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml"
# }

# resource "kubectl_manifest" "traefik_crd" {
#   for_each = {
#     for idx, doc in split("---", data.http.traefik_crd.response_body) :
#     idx => yamldecode(doc) if trimspace(doc) != ""
#   }
#   yaml_body = each.value
# }


# # Применение конфигураций Traefik
# resource "kubernetes_manifest" "gatewayclass" {
#   manifest = yamldecode(file("kuber/traefik/gatewayclass.yaml"))
# }

# resource "kubernetes_manifest" "gateway" {
#   manifest = yamldecode(file("kuber/traefik/gateway.yaml"))
# }

# resource "kubernetes_manifest" "upload_service" {
#   for_each = {
#     for idx, doc in split("---", file("kuber/traefik/upload-service.yaml")) : 
#     idx => yamldecode(doc) if trimspace(doc) != ""
#   }
#   manifest = each.value
# }

# resource "kubernetes_manifest" "video_service" {
#   manifest = yamldecode(file("kuber/traefik/video-service.yaml"))
# }

# # Настройка NGINX
# resource "kubernetes_config_map" "static_html" {
#   metadata {
#     name = "static-html-content"
#   }
#   data = {
#     "index.html" = file("static/index.html")
#   }
# }

# resource "kubernetes_manifest" "nginx" {
#     for_each = {
#     for idx, doc in split("---", file("kuber/traefik/nginx.yaml")) : 
#     idx => yamldecode(doc) if trimspace(doc) != ""
#   }
#   manifest = each.value
# }

output "k8s_external_endpoint" {
  value = yandex_kubernetes_cluster.mk8s-cluster.master[0].external_v4_endpoint
}