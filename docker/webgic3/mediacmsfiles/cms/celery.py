from __future__ import absolute_import

import os
import time

from celery import Celery
from django.conf import settings

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "cms.settings")
app = Celery("cms", broker='redis://redis:6379/1')

app.config_from_object('django.conf:settings', namespace='CELERY')
app.autodiscover_tasks()

# app.conf.broker_url = settings.BROKER_URL

app.conf.beat_schedule = app.conf.CELERY_BEAT_SCHEDULE
app.conf.broker_transport_options = {"visibility_timeout": 60 * 60 * 24}  # 1 day
# http://docs.celeryproject.org/en/latest/getting-started/brokers/redis.html#redis-caveats

# setting this to settings.py file only is not respected. Setting here too
app.conf.task_always_eager = settings.CELERY_TASK_ALWAYS_EAGER


app.conf.worker_prefetch_multiplier = 1
