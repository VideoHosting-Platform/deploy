# Установка kubectl(если необходимо)
curl -LO https://dl.k8s.io/release/`curl -LS https://dl.k8s.io/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version --client

# Добавляем репозиторий Argo
helm repo add argo https://argoproj.github.io/argo-helm

# Обновляем репозитории
helm repo update

helm install argo-workflows argo/argo-workflows \
  --namespace argo \
  --create-namespace \
  --set "server.extraArgs={--auth-mode=server}"

kubectl -n argo port-forward svc/argo-workflows-server 2746:2746

# Установка Argo CLI(если необходимо)
wget https://github.com/argoproj/argo-workflows/releases/latest/download/argo-linux-amd64.gz
gunzip argo-linux-amd64.gz
chmod +x argo-linux-amd64
sudo mkdir /usr/local/bin/argo 
sudo mv argo-linux-amd64 /usr/local/bin/argo