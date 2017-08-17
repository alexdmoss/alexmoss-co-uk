pod=$1
kubectl describe pod $(kubectl get pods | grep $pod | awk '{print $1}')

