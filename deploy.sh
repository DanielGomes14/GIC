#!/bin/bash

NAMESPACE='gic3'
K8S_DIR='k8s'
MEDIACMS_PATH='/home/mediacms.io/mediacms'


### secrets ###

REDIS_SECRET=$(head -c 24 /dev/random | base64)
kubectl create secret generic prod-db-secret --from-literal=username=mediacms --from-literal=password=$(head -c 24 /dev/random | base64) -n gic3
kubectl create secret generic prod-redis-secret --from-literal=password=$REDIS_SECRET -n gic3


### config maps ###

kubectl apply -n $NAMESPACE -f "$K8S_DIR/nginx-configmap.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/redisconfigmap.yaml"


### deployments ###

kubectl apply -n $NAMESPACE -f "$K8S_DIR/ingress.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/postgres.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/rediscluster.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/nginx.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/api.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/web.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/celerybeat.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/celeryworker-short.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/celeryworker-long.yaml"


### further details ###

while [ -z $(kubectl get pods -n gic3 | grep redis-0) ]
do 
    # exec redis-cli monitor on redis-0 pod
    kubectl exec -n $NAMESPACE -it redis-0 -- /bin/sh -c "redis-cli -a $REDIS_SECRET monitor &"
done

GET_PODS_OPTIONS='--no-headers -o custom-columns=:metadata.name --field-selector=status.phase==Running'

NGINX_POD_NAME=
while [ -z "$NGINX_POD_NAME" ]
do 
    # wait for nginx pod and get its name
    NGINX_POD_NAME=$(kubectl get pods $GET_PODS_OPTIONS -n $NAMESPACE | grep -m1 nginx)
    echo -ne "waiting for nginx to start running..."\\r
    sleep 1
done
echo "NGINX_POD_NAME=$NGINX_POD_NAME"

# copy tmpstatic to static in web pod
echo "copying static files..."
kubectl exec -n $NAMESPACE -it $WEB_POD_NAME -- /bin/bash -c "cp -r $MEDIACMS_PATH/tmpstatic/* $MEDIACMS_PATH/static"
echo -ne ""\\r

WEB_POD_NAME=
while [ -z "$WEB_POD_NAME" ]
do 
    # wait for web pod and get its name
    WEB_POD_NAME=$(kubectl get pods $GET_PODS_OPTIONS -n $NAMESPACE | grep -m1 web)
    echo -ne "waiting for web to start running..."\\r
    sleep 1
done
echo "WEB_POD_NAME=$WEB_POD_NAME"

# create media_files/hls path in nginx pod
# reload nginx
kubectl exec -n $NAMESPACE -it $NGINX_POD_NAME -- /bin/sh -c "mkdir -p $MEDIACMS_PATH/media_files/hls; nginx -s reload"
