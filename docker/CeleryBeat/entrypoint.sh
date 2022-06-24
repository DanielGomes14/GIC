#!/bin/bash

echo "Waiting for Redis is running..."

while ! nc -z redis 6379; do
  sleep 0.1
done
echo "Redis started"

cd mediacms

mkdir logs
mkdir pids

echo "Enabling celery-beat scheduling server"
celery beat -A cms --pidfile=/home/mediacms.io/mediacms/pids/beat.pid --logfile=/home/mediacms.io/mediacms/logs/beat.log --loglevel=DEBUG --workdir=/home/mediacms.io/mediacms -b 'redis://:'$REDIS_PASSWORD'@redis:6379/1'

tail -f /dev/null
