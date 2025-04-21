nohup kubectl -n argo port-forward svc/argo-workflows-server 2746:2746 &
minikube service nginx
echo "Все порты проброшены. 🚀"