#!/bin/bash
#Check if Psql, Redis and Celery are up


echo "Waiting for Postgres to Start..."

while ! nc -z postgres-svc 5432; do
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
# echo "Running loaddata and creating admin user"
# python manage.py loaddata fixtures/encoding_profiles.json
# python manage.py loaddata fixtures/categories.json

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

echo "Enabling uwsgi app server"
uwsgi --ini /home/mediacms.io/mediacms/mediacmsfiles/deploy/docker/uwsgi.ini

