# Установка всех зависимостей и cli
Установка kubectl(если необходимо)
``` bash
curl -LO https://dl.k8s.io/release/`curl -LS https://dl.k8s.io/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version --client
```


Установка `mc` - Minio client(если необходимо)
``` bash
curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o $HOME/minio-binaries/mc

chmod +x $HOME/minio-binaries/mc
export PATH=$PATH:$HOME/minio-binaries/

mc --help
```

Установка Helm(если необходимо)
``` bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

# Запуск
### Запуск кластера локально:
Для того чтобы не пондимать постоянно необходимые контейнеры, например RabbitMq, MinIO etc, делаем проброс портов
``` bash
minikube start
helm install video-hosting oci://ghcr.io/redblood-pixel/charts/video-hosting-stack --version 0.1.1
bash bash/local_dev_ports.sh # скрипт, чтобы пробросить порты и автоматически открыть все сервисы
```
- Смотрим на вывод паролей и логинов(для лок. разработки)
и экспортируем к себе (в config)

### Запуск кластера для прода
Для запуска для прода рекомендуется создать и заполнить в корне проекта values.yaml(пример можно найти в директории helm/video-hosting-stack)

Для того, чтобы редактировать values.yaml для зависимостей, можно использовать следующие референсы
- [Traefik](https://artifacthub.io/packages/helm/traefik/traefik)
- [Rabbitmq](https://artifacthub.io/packages/helm/bitnami/rabbitmq)
- [Minio](https://artifacthub.io/packages/helm/bitnami/minio)

Перед запуском terraform его необходимо [настроить](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/kubernetes-terraform-provider)
```
terraform -chdir=terraform init
terraform -chdir=terraform apply
```
Чтобы удалить поднятую инфраструктуру, нужно воспользоваться командой `terraform -chdir=terraform destroy`

### Сборка и пуш чарта
Чтобы собрать и запушить чарт нужно:
- Перейти в папку с чартом - `cd ./path-to-chart(helm/video-hosting-stack)`
- Обновить и скачать зависимости - `helm dependency update`
- Проверить чарт - `helm lint .`
- Собрать чарт - `helm package .`
- Чтобы запушить нужно
  - Создайте Personal Access Token (PAT) в GitHub: 
    - Настройки → Developer settings → Personal access tokens → Tokens (classic).
    - Дайте права: write:packages, read:packages, delete:packages
  - Залогиньтесь в GHCR через Helm:
    ``` bash
    echo "ваш_github_token" | helm registry login ghcr.io \
    --username ваш_github_username \
    --password-stdi
    ```
- Запушить чарт - `helm push ваш-чарт-0.1.0.tgz oci://ghcr.io/ваш_github_username/charts`
- Можно скачать чарт - `helm install my-app oci://ghcr.io/ваш_github_username/charts/ваш-чарт --version 0.1.1`

# Какие сервисы запускаются и как?
- Traefik(API-Gateway) - разворачивается в Helm
- Minio - разворачивается в Helm
- Rabbitmq - разворачивается без Helm, обычным kubectl apply -f ...
- Nginx(раздает статический файл) - разворачивается без Helm, кастомные манифесты

