## Kubernetes Struct

## Ingress
- Should have two paths: 
    - `/` to frontend
    - `/docs` to swagger docs
    - 443/80 ports

## Frontend
- Should have an NGINX on front of NodeJS App
    - proxy pass to frontend port 8088
    - runs on port 80
    - static files of frontend should be binded here on a volume
- Node JS App
    - runs on port 8088