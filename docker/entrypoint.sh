#!/bin/bash
#Check if Psql, Redis and Celery are up


echo "Waiting for Postgres to Start..."

while ! nc -z db 5432; do
  sleep 0.1
done
echo "Postgres started"


echo "Waiting for Redis is running..."


while ! nc -z redis 6379; do
  sleep 0.1
done
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
echo "RUNNING COLLECTSTATIC"

python manage.py collectstatic --noinput

echo "Starting wsgi...."
uwsgi --ini /home/mediacms.io/mediacms/mediacmsfiles/deploy/docker/uwsgi.ini


APP_DIR="/home/mediacms.io/mediacms/mediacmsfiles"
CELERY_APP="cms"
CELERYD_LOG_LEVEL="INFO"

CELERYD_NODES="short1 short2"
CELERY_QUEUE="short_tasks"
CELERYD_OPTS="--soft-time-limit=300 -c10"
CELERYD_PID_FILE="/home/mediacms.io/mediacms/mediacmsfiles/pids/%n.pid"
CELERYD_LOG_FILE="/home/mediacms.io/mediacms/mediacmsfiles/logs/%N.log"

celery multi start ${CELERYD_NODES} -A ${CELERY_APP} --pidfile=${CELERYD_PID_FILE} --logfile=${CELERYD_LOG_FILE} --loglevel=${CELERYD_LOG_LEVEL} ${CELERYD_OPTS} --workdir=${APP_DIR} -Q ${CELERY_QUEUE}


CELERYD_NODES="long1"
CELERY_QUEUE="long_tasks"
CELERYD_OPTS="-Ofair --prefetch-multiplier=1"
CELERYD_PID_FILE="/home/mediacms.io/mediacms/mediacmsfiles/pids/%n.pid"
CELERYD_LOG_FILE="/home/mediacms.io/mediacms/mediacmsfiles/logs/%N.log"

celery multi start ${CELERYD_NODES} -A ${CELERY_APP} --pidfile=${CELERYD_PID_FILE} --logfile=${CELERYD_LOG_FILE} --loglevel=${CELERYD_LOG_LEVEL} ${CELERYD_OPTS} --workdir=${APP_DIR} -Q ${CELERY_QUEUE}


CELERYD_PID_FILE="/home/mediacms.io/mediacms/mediacmsfiles/pids/beat%n.pid"
CELERYD_LOG_FILE="/home/mediacms.io/mediacms/mediacmsfiles/logs/beat%N.log"

celery beat -A ${CELERY_APP} --pidfile=${CELERYD_PID_FILE} --logfile=${CELERYD_LOG_FILE} --loglevel=${CELERYD_LOG_LEVEL} ${CELERYD_OPTS} --workdir=${APP_DIR}