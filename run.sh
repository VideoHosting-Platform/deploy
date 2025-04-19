# запускает minikube, minio, argo, registry и дашборды для них

check_status() {
  if [ $? -eq 0 ]; then
    echo "✅ $1 запущен успешно!"
  else
    echo "❌ Ошибка при запуске $1!"
    exit 1
  fi
}

minikube start

helm repo add minio https://charts.min.io/
helm install minio minio/minio --namespace minio \
  --create-namespace \
  -f kuber/minio/minio-values.yaml

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argo-workflows argo/argo-workflows \
  --namespace argo \
  --create-namespace \
  --set "server.extraArgs={--auth-mode=server}"

kubectl apply -f kuber/ffmpeg-templates.yaml -n argo
kubectl apply -f kuber/fastapi-deployment.yaml
kubectl apply -f kuber/roles.yaml
kubectl apply -f kuber/rbac.yaml

kubectl apply -f kuber/nginx/nginx-configmap.yaml
kubectl apply -f kuber/nginx/nginx-deployment.yaml
kubectl apply -f kuber/nginx/nginx-service.yaml


minikube addons enable registry

mc alias set minio $(minikube service -n minio minio --url | head -n 1) minioadmin minioadmin
sleep 3
mc admin config set minio notify_webhook:service endpoint="http://fastapi-service.default.svc.cluster.local:8000/webhook"
mc admin service restart minio
sleep 3
mc event add minio/videos arn:minio:sqs::service:webhook --event put

echo "Все сервисы запущены в фоне. 🚀"