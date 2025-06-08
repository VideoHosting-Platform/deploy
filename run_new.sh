#!/bin/bash

# Можно на default, но лучше явно указать
NAMESPACE_RABBITMQ=messaging
NAMESPACE_MINIO=minio


kubectl create namespace $NAMESPACE_RABBITMQ
kubectl create namespace $NAMESPACE_MINIO


#если есть флаг --re, то переустанавливаем сервисы
if [[ "$1" == "--reinstall" ]]; then
    echo "Cleaning up existing services..."

    helm uninstall rabbitmq -n $NAMESPACE_RABBITMQ
    helm uninstall minio -n $NAMESPACE_MINIO

fi

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add minio https://charts.min.io/



helm install rabbitmq bitnami/rabbitmq \
  --namespace $NAMESPACE_RABBITMQ \
  -f kuber/values/rabbitmq_value.yaml

# rabbitmq-headless  нужен для кластеризации RabbitMQ
# поэтому пока что удаляем его
kubectl delete  services/rabbitmq-headless -n $NAMESPACE_RABBITMQ


# minio
# Тоже без кластеризации
helm install minio minio/minio \
    --namespace $NAMESPACE_MINIO \
    -f kuber/values/minio_value.yaml


