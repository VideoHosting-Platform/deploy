helm repo add minio https://charts.min.io/
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add traefik https://traefik.github.io/charts

#minio
helm install minio minio/minio --namespace default \
  -f kuber/minio-values.yaml


# rabbit mq
curl -L "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml" | sed 's/namespace: rabbitmq-system/namespace: default/g' | kubectl apply -f -
kubectl apply -f kuber/rabbitmq.yaml


# prometheus
helm install prometheus prometheus-community/kube-prometheus-stack \
  --version 46.8.0 \
  --namespace default \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues=false \
  --set alertmanager.alertmanagerSpec.alertmanagerConfigSelectorNilUsesHelmValues=false \
  --set grafana.enabled=false


# loki & grafana
helm install loki grafana/loki-stack --namespace default --values kuber/loki-values.yaml


# traefik
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml
helm install traefik traefik/traefik --namespace default \
  --set "providers.kubernetesGateway.enabled=true" \
  --set service.type=LoadBalancer
kubectl apply -f kuber/traefik/gatewayclass.yaml
kubectl apply -f kuber/traefik/gateway.yaml
kubectl apply -f kuber/traefik/upload-service.yaml
kubectl apply -f kuber/traefik/video-service.yaml

# nginx
kubectl create configmap static-html-content --from-file=static/index.html
kubectl apply -f kuber/traefik/nginx.yaml

# get passwords from RabbitMQ and Grafana
echo Grafana password - $(kubectl get secret loki-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)
echo RabbitMQ default user - $(kubectl get secret rabbitmq-default-user -o jsonpath='{.data.username}' | base64 --decode)
echo RabbitMQ default user password - $(kubectl get secret rabbitmq-default-user -o jsonpath='{.data.password}' | base64 --decode)


echo "Все сервисы запущены в фоне. 🚀"