# пробрасываем порты

check_status() {
  if [ $? -eq 0 ]; then
    echo "✅ $1 запущен успешно!"
  else
    echo "❌ Ошибка при запуске $1!"
    exit 1
  fi
}

nohup kubectl -n argo port-forward svc/argo-workflows-server 2746:2746 &
check_status "Argo Workflows Server (port 2746)"

sleep 5
nohup kubectl port-forward -n minio svc/minio 9000:9000 9001:9001  > /dev/null 2>&1 &
check_status "MinIO (ports 9000, 9001)"
sleep 3

nohup kubectl port-forward -n kube-system svc/registry 5000:80 &
check_status "Registry (port 5000)"

nohup kubectl port-forward -n default svc/fastapi-service 8000:8000 &
check_status "Fastapi port 8000"

nohup minikube dashboard &
check_status "Minikube Dashboard"

echo "Все порты проброшены. 🚀"