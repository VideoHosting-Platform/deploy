# Установка всех зависимостей и cli
Установка kubectl(если необходимо)
```
curl -LO https://dl.k8s.io/release/`curl -LS https://dl.k8s.io/release/stable.txt`/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

kubectl version --client


```

Не обязательные фишки
```
// для bash, чтобы в cli были автодополнения команд
// если не bash, то пободно
echo 'source <(kubectl completion bash)' >> ~/.bashrc
source ~/.bashrc
```


Установка `mc` - Minio client(если необходимо)
```
curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o $HOME/minio-binaries/mc

chmod +x $HOME/minio-binaries/mc
export PATH=$PATH:$HOME/minio-binaries/

mc --help
```

Установка Helm(если необходимо)
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

# Запуск
### Запустить кластер локально:
```
minikube start
bash run.sh
```
ports.sh - скрипт, чтобы пробросить порты и автоматически открыть все сервисы

Можно открыть дашборд: `minikube dashboard`

Посмотреть все процессы: `ps aux | grep port-forward`    

Завершить: `pkill -f "kubectl port-forward"`

# Какие сервисы запускаются и как?
- Traefik(API-Gateway) - разворачивается в Helm
- Minio - разворачивается в Helm
- Rabbitmq - разворачивается без Helm, обычным kubectl apply -f ...
- Nginx(раздает статический файл) - разворачивается без Helm, кастомные манифесты
- Prometheus - разворачивается с Helm
- Loki - разворачивается с Helm
- Grafana - разворачивается с Helm во время установки Loki

