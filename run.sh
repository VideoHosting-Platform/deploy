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
# kubectl create namespace minio
# kubectl apply -f kuber/minio-deployment.yaml
# check_status "minio поднят"

# kubectl create secret generic minio-credentials \
#   --from-literal=accesskey=minioadmin \
#   --from-literal=secretkey=minioadmin \
#   --from-literal=endpoint=

helm repo add 

helm install minio minio/minio --namespace minio \
  --create-namespace \
  -f kuber/minio-values.yaml

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argo-workflows argo/argo-workflows \
  --namespace argo \
  --create-namespace \
  --set "server.extraArgs={--auth-mode=server}"

kubectl apply -f kuber/ffmpeg-templates.yaml -n argo
kubectl apply -f kuber/fastapi-deployment.yaml

kubectl apply -f kuber/roles.yaml

minikube addons enable registry

echo "Все сервисы запущены в фоне. 🚀"