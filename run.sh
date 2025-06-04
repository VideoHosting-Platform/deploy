helm repo add minio https://charts.min.io/
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add traefik https://traefik.github.io/charts

#minio
helm install minio minio/minio --namespace minio \
  --create-namespace \
  -f kuber/minio-values.yaml


# rabbit mq
kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"
kubectl apply -f kuber/rabbitmq.yaml


# prometheus
helm install prometheus prometheus-community/kube-prometheus-stack \
  --version 46.8.0 \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues=false \
  --set alertmanager.alertmanagerSpec.alertmanagerConfigSelectorNilUsesHelmValues=false \
  --set grafana.enabled=false


# loki & grafana
helm install loki grafana/loki-stack --namespace monitoring --values kuber/loki-values.yaml


# traefik
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml
helm install traefik traefik/traefik --namespace traefik --create-namespace \
  --set "providers.kubernetesGateway.enabled=true" \
  --set service.type=NodePort
kubectl apply -f kuber/traefik/gatewayclass.yaml
kubectl apply -f kuber/traefik/gateway.yaml
kubectl apply -f kuber/traefik/upload-service.yaml
kubectl apply -f kuber/traefik/video-service.yaml

# nginx
kubectl create configmap static-html-content --from-file=static/index.html
kubectl apply -f kuber/traefik/nginx.yaml

# get passwords from RabbitMQ and Grafana
echo Grafana password - $(kubectl get secret -n monitoring loki-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)
echo RabbitMQ default user - $(kubectl get secret rabbitmq-default-user -n rabbitmq-system -o jsonpath='{.data.username}' | base64 --decode)
echo RabbitMQ default user password - $(kubectl get secret rabbitmq-default-user -n rabbitmq-system -o jsonpath='{.data.password}' | base64 --decode)


echo "Все сервисы запущены в фоне. 🚀"