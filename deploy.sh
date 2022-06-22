#!/bin/bash

NAMESPACE='gic3'
K8S_DIR='k8s'
MEDIACMS_DIR='docker/mediacmsfiles'

# config maps
#kubectl create configmap nginx-conf --from-file="$K8S_DIR/nginx-configmap.yaml"
#kubectl create configmap redis-config --from-file="$K8S_DIR/redisconfigmap.yaml"

# deployments

kubectl apply -n $NAMESPACE -f "$K8S_DIR/postgres.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/rediscluster.yaml"

kubectl exec -n $NAMESPACE -it redis-0 -- /bin/sh -c "redis-cli -a EMeHRnIthT6JcFYFbnVpNscr4mhds3IT monitor &"

kubectl apply -n $NAMESPACE -f "$K8S_DIR/nginx.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/api.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/web.yaml"

NGINX_POD_NAME=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" -n gic3 | grep -m1 nginx)
WEB_POD_NAME=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" -n gic3 | grep -m1 web)

kubectl exec -n $NAMESPACE -it $WEB_POD_NAME -- /bin/bash -c "cp -r /home/mediacms.io/mediacms/tmpstatic/* /home/mediacms.io/mediacms/static"
kubectl exec -n $NAMESPACE -it $NGINX_POD_NAME -- /bin/sh -c "mkdir -p /home/mediacms.io/mediacms/media_files/hls; nginx -s reload"

kubectl apply -n $NAMESPACE -f "$K8S_DIR/celerybeat.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/celeryworker-short.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/celeryworker-long.yaml"

