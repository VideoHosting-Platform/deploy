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
kubectl create namespace minio
kubectl apply -f kuber/minio-deployment.yaml
check_status "minio поднят"

kubectl create secret generic minio-credentials \
  --from-literal=accesskey=minioadmin \
  --from-literal=secretkey=minioadmin \
  --from-literal=endpoint=

# kubectl wait --for=condition=available deployment/minio -n minio --timeout=120s

# Добавляем репозиторий Argo
helm repo add argo https://argoproj.github.io/argo-helm

# Обновляем репозитории
helm repo update

helm install argo-workflows argo/argo-workflows \
  --namespace argo \
  --create-namespace \
  --set "server.extraArgs={--auth-mode=server}"

kubectl create namespace argo-events
kubectl apply -f kuber/ffmpeg-templates.yaml -n argo

# Устанавливаем Argo Events (минимальная настройка)
helm install argo-events argo/argo-events \
  -n argo-events \
  --create-namespace \
  --set controller.enabled=true \
  --set eventbus.install=true \
  --set eventbus.native.enabled=true \
  --set eventsources.enabled=false \
  --set sensors.enabled=false \
  --set webhook.enabled=false   

kubectl apply -n argo-events -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: operate-workflow-sa
  namespace: argo-events
EOF

kubectl apply -f kuber/argo-event.yaml -n argo-events
kubectl apply -f kuber/argo-sensor.yaml -n argo-events

kubectl rollout restart deployment argo-workflows-server -n argo
kubectl rollout restart deployment argo-workflows-workflow-controller -n argo

kubectl apply -f kuber/fastapi-deployment.yaml

minikube addons enable registry



# nohup kubectl -n argo port-forward svc/argo-workflows-server 2746:2746 &
# check_status "Argo Workflows Server (port 2746)"


# nohup kubectl port-forward -n minio svc/minio 9000:9000 9001:9001  > /dev/null 2>&1 &
# check_status "MinIO (ports 9000, 9001)"

# nohup kubectl port-forward -n kube-system svc/registry 5000:80 &
# check_status "Registry (port 5000)"

# nohup minikube dashboard &
# check_status "Minikube Dashboard"

# sleep 5
# mc alias set kubemc http://localhost:9000 minioadmin minioadmin
# mc mb kubemc/videos

echo "Все сервисы запущены в фоне. 🚀"