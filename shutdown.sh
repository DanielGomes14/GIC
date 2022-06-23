#!/bin/bash

NAMESPACE='gic3'
K8S_DIR='k8s'


#### secrets ####

kubectl delete secret prod-db-secret -n $NAMESPACE
kubectl delete secret prod-redis-secret -n $NAMESPACE


#### config maps ####

kubectl delete -n $NAMESPACE -f "$K8S_DIR/nginx-configmap.yaml"
kubectl delete -n $NAMESPACE -f "$K8S_DIR/redisconfigmap.yaml"


#### deployments ####

kubectl delete -n $NAMESPACE -f "$K8S_DIR/ingress.yaml"
kubectl delete -n $NAMESPACE -f "$K8S_DIR/postgres.yaml"
kubectl delete -n $NAMESPACE -f "$K8S_DIR/rediscluster.yaml"
kubectl delete -n $NAMESPACE -f "$K8S_DIR/nginx.yaml"
kubectl delete -n $NAMESPACE -f "$K8S_DIR/api.yaml"
kubectl delete -n $NAMESPACE -f "$K8S_DIR/web.yaml"
kubectl delete -n $NAMESPACE -f "$K8S_DIR/celerybeat.yaml"
kubectl delete -n $NAMESPACE -f "$K8S_DIR/celeryworker-short.yaml"
kubectl delete -n $NAMESPACE -f "$K8S_DIR/celeryworker-long.yaml"
