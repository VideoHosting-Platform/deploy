# Установка всех зависимостей и cli
Установка kubectl(если необходимо)
```
curl -LO https://dl.k8s.io/release/`curl -LS https://dl.k8s.io/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version --client
```


Установка Argo CLI(если необходимо)
```
wget https://github.com/argoproj/argo-workflows/releases/latest/download/argo-linux-amd64.gz
gunzip argo-linux-amd64.gz
chmod +x argo-linux-amd64
sudo mkdir /usr/local/bin/argo 
sudo mv argo-linux-amd64 /usr/local/bin/argo
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
bash run.sh
```
Можно открыть дашборд: `minikube dashboard`

Адрес: `http://localhost:9001` 

Посмотреть все процессы: `ps aux | grep port-forward`    

Завершить: `pkill -f "kubectl port-forward"` 
   
### Создать и запустить воркфлоу из ffmpeg-workflows.yaml:
```
argo submit -n argo kuber/ffmpeg-workflows.yaml \
  -p video_path="BigBuckBunny_640x360.m4v" \
  -p uuid="12" -p preset="240p"
```

#### Посмотреть логи
argo logs -n argo <workflow-name> --timestamps
argo logs -n argo @latest --timestamps

