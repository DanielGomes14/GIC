#!/bin/bash

echo "Waiting for Redis is running..."

while ! nc -z redis 6379; do
  sleep 0.1
done
echo "Redis started"

cd mediacms

mkdir logs
mkdir pids
mkdir -p media_files/hls

echo "Enabling celery-short task worker"
echo "Enabling celery-long task worker"

celery worker -A cms --pidfile=/home/mediacms.io/mediacms/pids/%h-%I.pid --logfile=/home/mediacms.io/mediacms/logs/%h-%I.log --loglevel=DEBUG --soft-time-limit=300 -c1 --workdir=/home/mediacms.io/mediacms -Q short_tasks -b  'redis://:'$REDIS_PASSWORD'@redis:6379/1'

tail -f /dev/null
