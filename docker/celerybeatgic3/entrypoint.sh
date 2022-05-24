#!/bin/bash



echo "Waiting for Redis is running..."


while ! nc -z redis 6379; do
  sleep 0.1
done
echo "Redis started"

cd mediacmsfiles

mkdir logs
mkdir pids




echo "Enabling celery-beat scheduling server"
celery beat -A cms --pidfile=/home/mediacms.io/mediacms/mediacmsfiles/pids/beat.pid --logfile=/home/mediacms.io/mediacms/mediacmsfiles/logs/beat.log --loglevel=DEBUG --workdir=/home/mediacms.io/mediacms/mediacmsfiles -b 'redis://redis:6379/1'



tail -f /dev/null
