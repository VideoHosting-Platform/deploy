nohup kubectl -n argo port-forward svc/argo-workflows-server 2746:2746 &
minikube service minio-console -n minio
minikube service nginx
open http://localhost:2746/workflows
echo "Все порты проброшены. 🚀" 