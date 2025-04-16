# Установка всех зависимостей и cli
Установка kubectl(если необходимо)
```
curl -LO https://dl.k8s.io/release/`curl -LS https://dl.k8s.io/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version --client
```

Добавление Argo Workflows в кластер как приложение
```
# Добавляем репозиторий Argo
helm repo add argo https://argoproj.github.io/argo-helm

# Обновляем репозитории
helm repo update

helm install argo-workflows argo/argo-workflows \
  --namespace argo \
  --create-namespace \
  --set "server.extraArgs={--auth-mode=server}"

kubectl -n argo port-forward svc/argo-workflows-server 2746:2746
```

Установка Argo CLI(если необходимо)
```
wget https://github.com/argoproj/argo-workflows/releases/latest/download/argo-linux-amd64.gz
gunzip argo-linux-amd64.gz
chmod +x argo-linux-amd64
sudo mkdir /usr/local/bin/argo 
sudo mv argo-linux-amd64 /usr/local/bin/argo
```

# Запуск
#### 1) Запустить minikube:
```
minikube start
```
Можно открыть дашборд: `minikube dashboard`. Адрес: `http://localhost:9001`
    
#### 2) Для установки минио рименить манифест:
```
kubectl apply -f minio-deployment.yaml
```

Настройки доступа: 
```
kubectl create secret generic minio-credentials \
  --from-literal=accesskey=minioadmin \
  --from-literal=secretkey=minioadmin \
  --from-literal=endpoint=
```

Пробросить порты(Пример в фоновом режиме):
```
nohup kubectl port-forward -n default svc/minio 9000:9000 9001:9001  > /dev/null 2>&1 &
```     
Посмотреть все процессы: `ps aux | grep port-forward`    
Завершить: `pkill -f "kubectl port-forward"` 
   
#### 3) Создать и запустить воркфлоу из workflow.yaml:
```
kubectl -n argo create -f workflow.yaml
```

#### логи
argo logs -n argo <workflow-name> --timestamps
argo logs -n argo @latest --timestamps

# Создание Registry  
Включить аддон:  
minikube addons enable registry  

Проверить работу  
kubectl get pods -n kube-system -l kubernetes.io/minikube-addons=registry  

Добавить registry в insecure-реестры
echo '{
  "insecure-registries": ["'$(minikube ip)':5000", "localhost:5000"]
}' | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker
Рестарт докера останавливает миникуб

Пробросить порты
kubectl port-forward -n kube-system svc/registry 5000:80 &


Переключиться на Docker daemon Minikube
eval $(minikube docker-env)

docker build -t video-processor:1.0 .
docker tag video-processor:1.0 localhost:5000/video-processor:1.0
docker push localhost:5000/video-processor:1.0

curl http://localhost:5000/v2/_catalog - это снаружи кубера