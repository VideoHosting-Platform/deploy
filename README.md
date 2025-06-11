# Установка всех зависимостей и cli
Установка kubectl(если необходимо)
```
curl -LO https://dl.k8s.io/release/`curl -LS https://dl.k8s.io/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version --client
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
### Запуск кластера локально:
Для того чтобы не пондимать постоянно необходимые контейнеры, например RabbitMq, MinIO etc, делаем проброс портов
```
minikube start
helm install video-hosting oci://ghcr.io/redblood-pixel/charts/video-hosting-stack --version 0.1.1
bash bash/local_dev_ports.sh # скрипт, чтобы пробросить порты и автоматически открыть все сервисы
```
- Смотрим на вывод паролей и логинов(для лок. разработки)
и экспортируем к себе (в config)

### Запуск кластера для прода
Для запуска для прода рекомендуется отредактировать values.yaml(пример можно найти в директории helm/video-hosting-stack)
```
# дополнить, наверное терраформ
```

# Какие сервисы запускаются и как?
- Traefik(API-Gateway) - разворачивается в Helm
- Minio - разворачивается в Helm
- Rabbitmq - разворачивается без Helm, обычным kubectl apply -f ...
- Nginx(раздает статический файл) - разворачивается без Helm, кастомные манифесты

