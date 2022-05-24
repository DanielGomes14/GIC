#!/bin/bash
#Check if Psql, Redis and Celery are up


echo "Waiting for Postgres to Start..."

while ! nc -z postgres-svc 5432; do
  sleep 0.1
done
echo "Postgres started"


echo "Waiting for Redis is running..."


#while ! nc -z redis 6379; do
#  sleep 0.1
#done
echo "Redis started"

cd mediacmsfiles

mkdir logs
mkdir pids

#TODO: Remove secrets from here!!
RANDOM_ADMIN_PASS=`python -c "import secrets;chars = 'abcdefghijklmnopqrstuvwxyz0123456789';print(''.join(secrets.choice(chars) for i in range(10)))"`

ADMIN_PASSWORD=${ADMIN_PASSWORD:-$RANDOM_ADMIN_PASS}


echo "Running migrations service"
python manage.py migrate
EXISTING_INSTALLATION=`echo "from users.models import User; print(User.objects.exists())" |python manage.py shell`
if [ "$EXISTING_INSTALLATION" = "True" ]; then 
    echo "Loaddata has already run"
else
    echo "Running loaddata and creating admin user"
    python manage.py loaddata fixtures/encoding_profiles.json
    python manage.py loaddata fixtures/categories.json

    # post_save, needs redis to succeed (ie. migrate depends on redis)
    DJANGO_SUPERUSER_PASSWORD=$ADMIN_PASSWORD python manage.py createsuperuser \
        --no-input \
        --username=$ADMIN_USER \
        --email=$ADMIN_EMAIL \
        --database=default || true
    echo "Created admin user with password: $ADMIN_PASSWORD"

fi

echo "Running collectstatic"
python manage.py collectstatic --noinput


# if [ X"$ENABLE_UWSGI" = X"yes" ] ; then
#     echo "Enabling uwsgi app server"
    
# fi


if [ X"$ENABLE_CELERY_BEAT" = X"yes" ] ; then
    echo "Enabling celery-beat scheduling server"
    celery beat -A cms --pidfile=/home/mediacms.io/mediacms/mediacmsfiles/pids/beat%n.pid --logfile=/home/mediacms.io/mediacms/mediacmsfiles/logs/beat%N.log --loglevel=INFO --workdir=/home/mediacms.io/mediacms/mediacmsfiles
fi

if [ X"$ENABLE_CELERY_WORKER" = X"yes" ] ; then
    echo "Enabling celery-short task worker"
    celery multi start short1 short2 -A cms --pidfile=/home/mediacms.io/mediacms/mediacmsfiles/pids/%n.pid --logfile=/home/mediacms.io/mediacms/mediacmsfiles/logs/%N.log --loglevel=INFO --soft-time-limit=300 -c10 --workdir=/home/mediacms.io/mediacms/mediacmsfiles -Q short_tasks
    
    echo "Enabling celery-long task worker"
    celery multi start long1 -A cms --pidfile=/home/mediacms.io/mediacms/mediacmsfiles/pids/%n.pid --logfile=/home/mediacms.io/mediacms/mediacmsfiles/logs/%N.log --loglevel=INFO -Ofair --prefetch-multiplier=1 --workdir=/home/mediacms.io/mediacms/mediacmsfiles -Q long_tasks
fi

pwd
ls /home/mediacms.io/mediacms/
uwsgi --ini /home/mediacms.io/mediacms/deploy/docker/uwsgi.ini