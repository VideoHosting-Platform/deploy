# resource "kubernetes_deployment" "demo-app-deployment" {
#   depends_on = [
#     yandex_kubernetes_cluster.mk8s-cluster
#   ]
#   metadata {
#     name = "hello"
#     labels = {
#       app = "hello"
#       version = "v1"
#     }
#   }
#   spec {
#     replicas = 2
#     selector {
#       match_labels = {
#         app = "hello"
#       }
#     }
#     template {
#       metadata {
#         labels = {
#           app = "hello"
#           version = "v1"
#         }
#       }
#       spec {
#         container {
#           name  = "hello-app"
#           image = "cr.yandex/crpjd37scfv653nl11i9/hello:1.1"
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_service" "demo-lb-service" {
#   depends_on = [
#     yandex_kubernetes_cluster.mk8s-cluster,
#     kubernetes_deployment.demo-app-deployment
#   ]
#   metadata {
#     name = "hello"
#   }
#   spec {
#     selector = {
#       app = kubernetes_deployment.demo-app-deployment.spec.0.template.0.metadata[0].labels.app
#     }
#     type = "LoadBalancer"
#     port {
#       port = 80
#       target_port = 8080
#     }te
#   }
# }

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

# resource "null_resource" "apply_rabbitmq_operator" {
#   provisioner "local-exec" {
#     interpreter = ["bash", "-exc"]
#     command     = "kubectl apply -f https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"
#   }
# }

# resource "null_resource" "apply_traefik_crd" {
#   provisioner "local-exec" {
#     interpreter = ["bash", "-exc"]
#     command     = <<EOT
#       kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml
#       kubectl wait --for=condition=Established crd/gatewayclasses.gateway.networking.k8s.io --timeout=60s
#       sleep 5
#     EOT
#   }
# }

# # data "http" "rabbitmq_operator" {
# #   url = "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"
# # }

# # resource "kubectl_manifest" "rabbitmq_operator" {
# #   yaml_body = data.http.rabbitmq_operator.response_body
# #   apply_only = true # Чтобы избежать ошибок если ресурсы уже существуют
# # }

# # data "http" "traefik_crd" {
# #   url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml"
# # }


# # resource "kubectl_manifest" "traefik_crd" {
# #   for_each = {
# #     for idx, doc in split("---", data.http.traefik_crd.response_body) :
# #     idx => yamldecode(doc) if trimspace(doc) != ""
# #   }
# #   yaml_body = each.value
# # }


# # Применение конфигураций Traefik
# resource "kubernetes_manifest" "gatewayclass" {
#   depends_on = [
#     yandex_kubernetes_cluster.mk8s-cluster,
#     helm_release.traefik-repo
#   ]
#   manifest = yamldecode(file("kuber/traefik/gatewayclass.yaml"))
# }

# resource "kubernetes_manifest" "gateway" {
#   depends_on = [
#     yandex_kubernetes_cluster.mk8s-cluster,
#     helm_release.traefik-repo
#   ]
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