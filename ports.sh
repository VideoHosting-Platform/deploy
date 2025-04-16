# пробрасываем порты

check_status() {
  if [ $? -eq 0 ]; then
    echo "✅ $1 запущен успешно!"
  else
    echo "❌ Ошибка при запуске $1!"
    exit 1
  fi
}

export PATH=$PATH:$HOME/minio-binaries/
# Проверяем, установлен ли mc (MinIO Client)
if ! command -v mc &> /dev/null; then
    echo "MinIO Client (mc) не найден. Установка..."
    curl https://dl.min.io/client/mc/release/linux-amd64/mc \
    --create-dirs \
    -o $HOME/minio-binaries/mc
    check_status "Установка mc"

    chmod +x $HOME/minio-binaries/mc
    export PATH=$PATH:$HOME/minio-binaries/
    fi

nohup kubectl -n argo port-forward svc/argo-workflows-server 2746:2746 &
check_status "Argo Workflows Server (port 2746)"

nohup kubectl port-forward -n minio svc/minio 9000:9000 9001:9001  > /dev/null 2>&1 &
check_status "MinIO (ports 9000, 9001)"

nohup kubectl port-forward -n kube-system svc/registry 5000:80 &
check_status "Registry (port 5000)"

# Создание бакета videos и настройка нотификаций
export PATH=$PATH:$HOME/minio-binaries/
mc alias set minio http://localhost:9000 minioadmin minioadmin
mc mb minio/videos
mc admin config set minio notify_webhook:service endpoint="http://fastapi-service.default.svc.cluster.local:8000/webhook"
mc admin service restart minio
mc event add minio/videos arn:minio:sqs::service:webhook --event put

mc admin config set minio notify_webhook:service endpoint="http://fastapi-service.default.svc.cluster.local:8000/webhook"
# nohup kubectl port-forward -n default svc/fastapi-service 8000:8000 &
# check_status "Fastapi port 8000"

nohup minikube dashboard &
check_status "Minikube Dashboard"

echo "Все порты проброшены. 🚀"