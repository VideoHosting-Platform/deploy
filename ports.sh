# пробрасываем порты

check_status() {
  if [ $? -eq 0 ]; then
    echo "✅ $1 запущен успешно!"
  else
    echo "❌ Ошибка при запуске $1!"
    exit 1
  fi
}

# Установка mc
echo "Установка mc..."
curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o $HOME/minio-binaries/mc

chmod +x $HOME/minio-binaries/mc
export PATH=$PATH:$HOME/minio-binaries/
check_status "Установка mc"

nohup kubectl -n argo port-forward svc/argo-workflows-server 2746:2746 &
check_status "Argo Workflows Server (port 2746)"

nohup kubectl port-forward -n minio svc/minio 9000:9000 9001:9001  > /dev/null 2>&1 &
check_status "MinIO (ports 9000, 9001)"

nohup kubectl port-forward -n kube-system svc/registry 5000:80 &
check_status "Registry (port 5000)"

sleep 5
mc alias set kubemc http://localhost:9000 minioadmin minioadmin
mc mb kubemc/videos
check_status "Создание бакета"

nohup minikube dashboard &
check_status "Minikube Dashboard"


echo "Все порты проброшены. 🚀"