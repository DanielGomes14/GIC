kubectl create secret generic prod-db-secret --from-literal=username=mediacms --from-literal=password=$(head -c 24 /dev/random | base64) -n gic3
kubectl create secret generic prod-redis-secret --from-literal=password=$(head -c 24 /dev/random | base64) -n gic3

