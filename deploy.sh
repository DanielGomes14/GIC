#!/bin/bash

NAMESPACE='gic3'
K8S_DIR='k8s'
MEDIACMS_PATH='/home/mediacms.io/mediacms'

# config maps
kubectl apply -n $NAMESPACE -f "$K8S_DIR/nginx-configmap.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/redisconfigmap.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/prometheus-configmap.yaml"

# secrets
bash "./$K8S_DIR/secret.sh"

# deployments
kubectl apply -n $NAMESPACE -f "$K8S_DIR/ingress.yaml"

kubectl apply -n $NAMESPACE -f "$K8S_DIR/postgres.yaml"

kubectl apply -n $NAMESPACE -f "$K8S_DIR/rediscluster.yaml"

kubectl exec -n $NAMESPACE -it redis-0 -- /bin/sh -c "redis-cli -a EMeHRnIthT6JcFYFbnVpNscr4mhds3IT monitor &"

kubectl apply -n $NAMESPACE -f "$K8S_DIR/nginx.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/api.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/web.yaml"

GET_PODS_OPTIONS='--no-headers -o custom-columns=:metadata.name --field-selector=status.phase==Running'

NGINX_POD_NAME=
while [ -z "$NGINX_POD_NAME" ]
do 
    NGINX_POD_NAME=$(kubectl get pods $GET_PODS_OPTIONS -n $NAMESPACE | grep -m1 nginx)
    echo -ne "waiting for nginx to start running..."\\r
    sleep 1
done
echo "NGINX_POD_NAME=$NGINX_POD_NAME"

WEB_POD_NAME=
while [ -z "$WEB_POD_NAME" ]
do 
    WEB_POD_NAME=$(kubectl get pods $GET_PODS_OPTIONS -n $NAMESPACE | grep -m1 web)
    echo -ne "waiting for web to start running..."\\r
    sleep 1
done
echo "WEB_POD_NAME=$WEB_POD_NAME"

kubectl exec -n $NAMESPACE -it $WEB_POD_NAME -- /bin/bash -c "cp -r $MEDIACMS_PATH/tmpstatic/* $MEDIACMS_PATH/static"
kubectl exec -n $NAMESPACE -it $NGINX_POD_NAME -- /bin/sh -c "mkdir -p $MEDIACMS_PATH/media_files/hls; nginx -s reload"

kubectl apply -n $NAMESPACE -f "$K8S_DIR/celerybeat.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/celeryworker-short.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/celeryworker-long.yaml"

kubectl apply -n $NAMESPACE -f "$K8S_DIR/prometheus-role.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/prometheus.yaml"
