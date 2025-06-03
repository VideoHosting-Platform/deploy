nohup kubectl port-forward svc/loki-grafana -n monitoring 3100:80 &
nohup kubectl port-forward svc/rabbitmq -n rabbitmq-system 15672:15672 &
minikube service minio-console -n minio

open $(minikube service traefik -n traefik --url | head -1)/app
open http://localhost:3100
open http://localhost:15672
echo "Все порты проброшены. 🚀" 