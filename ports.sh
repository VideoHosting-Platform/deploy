nohup kubectl port-forward svc/loki-grafana 3100:80 &
nohup kubectl port-forward svc/rabbitmq 15672:15672 &
minikube service minio-console

open $(minikube service traefik --url | head -1)/app
open http://localhost:3100
open http://localhost:15672
echo "Все порты проброшены. 🚀" 