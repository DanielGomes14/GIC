# How to Deploy

1. Create Secrets

<code> bash ./secrets.sh </code>

2. Create Ingress

<code> kubectl apply -f ingress.yaml </code>

3. Create PostgreSQL

<code> kubectl apply -f postgres.yaml </code>

4. Create Redis ConfigMap

<code> kubectl apply -f redisconfigmap.yaml </code>

5. Create Redis Cluster

<code> kubectl apply -f rediscluster.yaml </code>

6. Create NGINX ConfigMap

<code> kubectl apply -f nginx-configmap.yaml </code>

7. Create NGINX

<code> kubectl apply -f nginx.yaml </code>

8. Create Web 

<code> kubectl apply -f web.yaml </code>

9. Create Api

<code> kubectl apply -f api.yaml </code>

10. Copy static files and create hls folder

- Enter inside the web pod

<code> kubectl exec -it <web_pod_id> -- sh </code>
    
- Copy static folder
    
 <code> cp -r tmpstatic/* static/ </code>

    
- Create hls folder
    
 <code> cd media_files </code>
    
 <code> mkdir hls </code>
    
11. Reload NGINX
 
 - Enter inside the nginx pod

<code> kubectl exec -it <nginx_pod_id> -- sh </code>
    
- Reload nginx
    
 <code> nginx -s reload </code>
    
    
12. Create Celery Beat

<code> kubectl apply -f clerybeat.yaml </code>
     
    
13. Create Celery Worker Long

<code> kubectl apply -f celeryworker-long.yaml </code>
    
    
14. Create Celery Worker Short

<code> kubectl apply -f celeryworker-short.yaml </code>
    
    
Deployment done!
    
Check the application at : [http://mediacms.k3s/](http://mediacms.k3s/)
  
