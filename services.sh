
# upload service
# ! доделать добавление сервисов. сделать создание конфигмап и секретов 
# kubectl apply -f https://github.com/VideoHosting-Platform/upload-service/blob/dev/k8s/configmap.yaml
kubectl apply -f https://github.com/VideoHosting-Platform/upload-service/blob/dev/k8s/deployment.yaml
kubectl apply -f https://github.com/VideoHosting-Platform/upload-service/blob/dev/k8s/service.yaml
kubectl apply -f https://github.com/VideoHosting-Platform/upload-service/blob/dev/k8s/service_monitor.yaml

# processor service
kubectl apply -f https://github.com/VideoHosting-Platform/VideoProcessor-/blob/develop/k8s/configMap.yaml
kubectl apply -f https://github.com/VideoHosting-Platform/VideoProcessor-/blob/develop/k8s/secret.yaml
kubectl apply -f https://github.com/VideoHosting-Platform/VideoProcessor-/blob/develop/k8s/deploy.yaml
kubectl create secret 

# video service
# db
kubectl apply -f https://github.com/VideoHosting-Platform/video-service/blob/main/k8s/configmap.yaml


kubectl apply -f https://github.com/VideoHosting-Platform/video-service/blob/main/k8s/db/pvc.yaml
kubectl apply -f https://github.com/VideoHosting-Platform/video-service/blob/main/k8s/db/deployment.yaml
kubectl apply -f https://github.com/VideoHosting-Platform/video-service/blob/main/k8s/db/service.yaml

kubectl apply -f https://github.com/VideoHosting-Platform/video-service/blob/main/k8s/video-service/deployment.yaml
kubectl apply -f https://github.com/VideoHosting-Platform/video-service/blob/main/k8s/video-service/service.yaml
kubectl apply -f https://github.com/VideoHosting-Platform/video-service/blob/main/k8s/service-monitor.yaml



