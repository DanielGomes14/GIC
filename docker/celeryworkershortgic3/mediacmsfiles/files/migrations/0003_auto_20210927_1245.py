# Generated by Django 3.1.12 on 2021-09-27 11:45

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('files', '0002_auto_20201201_0712'),
    ]

    operations = [
        migrations.AlterField(
            model_name='media',
            name='reported_times',
            field=models.IntegerField(default=0, help_text='how many time a media is reported'),
        ),
    ]
