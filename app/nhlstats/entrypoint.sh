#!/bin/sh
python manage.py migrate
gunicorn nhlstats.wsgi:application --bind 0.0.0.0:8000
