#!/bin/bash

NAMESPACE='gic3'
K8S_DIR='k8s'
MEDIACMS_PATH='/home/mediacms.io/mediacms'
GET_PODS_RUNNING='--no-headers -o custom-columns=:metadata.name --field-selector=status.phase==Running'


#### secrets ####

REDIS_SECRET=$(head -c 24 /dev/random | base64)
kubectl create secret generic prod-db-secret --from-literal=username=mediacms --from-literal=password=$(head -c 24 /dev/random | base64) -n $NAMESPACE
kubectl create secret generic prod-redis-secret --from-literal=password=$REDIS_SECRET -n $NAMESPACE


#### config maps ####

kubectl apply -n $NAMESPACE -f "$K8S_DIR/nginx-configmap.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/redisconfigmap.yaml"


#### ingress deployment ####

kubectl apply -n $NAMESPACE -f "$K8S_DIR/ingress.yaml"


#### postgres deployment ####

kubectl apply -n $NAMESPACE -f "$K8S_DIR/postgres.yaml"

while [ -z $(kubectl get pods $GET_PODS_RUNNING -n $NAMESPACE | grep -m1 postgres) ]
do 
    echo -ne "waiting for postgres to start running..."\\r
    sleep 1
done


#### redis deployment ####

kubectl apply -n $NAMESPACE -f "$K8S_DIR/rediscluster.yaml"

while [ -z $(kubectl get pods $GET_PODS_RUNNING -n gic3 | grep redis-0) ]
do 
    # exec redis-cli monitor on redis-0 pod
    echo -ne "waiting for redis-0 to start running..."\\r
    kubectl exec -n $NAMESPACE -it redis-0 -- /bin/sh -c "redis-cli -a $REDIS_SECRET monitor &"
    sleep 1
done


#### nginx deployment ####

kubectl apply -n $NAMESPACE -f "$K8S_DIR/nginx.yaml"

NGINX_POD_NAME=
while [ -z "$NGINX_POD_NAME" ]
do 
    # wait for nginx pod and get its name
    echo -ne "waiting for nginx to start running..."\\r
    NGINX_POD_NAME=$(kubectl get pods $GET_PODS_RUNNING -n $NAMESPACE | grep -m1 nginx)
    sleep 1
done

# create media_files/hls path in nginx pod
# reload nginx
kubectl exec -n $NAMESPACE -it $NGINX_POD_NAME -- /bin/sh -c "mkdir -p $MEDIACMS_PATH/media_files/hls; nginx -s reload"


#### web-api deployment ####

kubectl apply -n $NAMESPACE -f "$K8S_DIR/api.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/web.yaml"

WEB_POD_NAME=
while [ -z "$WEB_POD_NAME" ]
do 
    # wait for web pod and get its name
    echo -ne "waiting for web to start running..."\\r
    WEB_POD_NAME=$(kubectl get pods $GET_PODS_RUNNING -n $NAMESPACE | grep -m1 web)
    sleep 1
done

# copy tmpstatic to static in web pod
echo "copying static files..."
kubectl exec -n $NAMESPACE -it $WEB_POD_NAME -- /bin/bash -c "cp -r $MEDIACMS_PATH/tmpstatic/* $MEDIACMS_PATH/static"
echo -ne ""\\r


#### celery deployments ####

kubectl apply -n $NAMESPACE -f "$K8S_DIR/celerybeat.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/celeryworker-short.yaml"
kubectl apply -n $NAMESPACE -f "$K8S_DIR/celeryworker-long.yaml"
