Ingress

-> redireciona request para o nginx, que por sua vez irá redirecionar os pedidos ou para o frontend ou para o backend?



Nginx

-> deployment

->  service

-> configmap

-> volume( Apenas PVC? )



Frontend

-> igual a backend ig apenas o nome da imagem muda de forma a conseguirmos distinguir replicas



Backend

-> deployment

-> service

-> secret -> pwds e merdas do genero

-> configmap -> usar env de ambiente

-> volume (mediafiles e logs maybe?)



Redis

-> for now 1 replica apenas!

-> para agora deployment, dps statefulset

-> service

-> configmap



Celery  Beat

-> imagem do mediacms criada, correr comando no k8s com beat

Celery Worker 

-> same shit mas com worker(usar short queue para agora)

Postgres

-> statefulset

-> service

-> pvc

-> probably configmap









