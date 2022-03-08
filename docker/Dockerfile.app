FROM python:3.9-alpine

ENV PYTHONDONTWRITEBYTECODE 1

ENV PYTHONUNBUFFERED 1

COPY ./app/nhlstats/requirements.txt /tmp/

RUN \
 apk update && \
 apk add --no-cache mysql-client \
   mariadb-dev \
   mariadb-connector-c-dev \
   curl \
   stress-ng &&\
 apk add --no-cache --virtual .build-deps gcc \
   musl-dev \
   python3-dev &&\
 pip install --no-cache-dir -U pip && \
 pip install --no-cache-dir -r /tmp/requirements.txt && \
 apk --purge del .build-deps && \
 addgroup -S app && \
 adduser -D -G app app

USER app

WORKDIR /nhlstats

COPY --chown=app:app ./app/nhlstats/ .

EXPOSE 8000

ENTRYPOINT ["/nhlstats/entrypoint.sh"]
