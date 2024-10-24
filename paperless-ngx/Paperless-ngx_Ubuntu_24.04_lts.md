# Requirement

## Install Libraries

    apt install python3 python3-pip python3-dev imagemagick fonts-liberation gnupg libpq-dev default-libmysqlclient-dev pkg-config libmagic-dev libzbar0 poppler-utils

    apt install unpaper ghostscript icc-profiles-free qpdf liblept5 libxml2 pngquant zlib1g tesseract-ocr

    apt install build-essential python3-setuptools python3-wheel

    apt install redis

    #apt install celery

## Install postgresql and configure a database

    apt install postgresql postgresql-contrib

### Configure postgresql

    sudo -u postgres psql

    	CREATE DATABASE paperless;
    	CREATE USER paperlessuser WITH PASSWORD 'password';
    	ALTER ROLE paperlessuser SET client_encoding TO 'utf8';
    	ALTER ROLE paperlessuser SET default_transaction_isolation TO 'read committed';
    	ALTER ROLE paperlessuser SET timezone TO 'UTC';
    	ALTER DATABASE paperless OWNER TO paperlessuser;
    	GRANT ALL PRIVILEGES ON DATABASE paperless TO paperlessuser;
    	\q

# Deploy Bare Metal

First install [Requirement](#Requirement)

## Configure paperless

Create user paperless

    adduser paperless --system --home /opt/paperless --group

Go to /opt/paperless, and execute the following commands:

    tar -xf paperless-ngx-v1.10.2.tar.xz

    sudo -Hu paperless mkdir -p consume media data
    sudo chown -R paperless:paperless /opt/paperless/*

    sudo -Hu paperless pip3 install -r requirements.txt --break-system-packages

Go to /opt/paperless/src, and execute the following commands:
This creates the database schema.

    sudo -Hu paperless python3 manage.py migrate
    sudo -Hu paperless python3 manage.py createsuperuser

Optional: Test that paperless is working by executing:

    sudo -Hu paperless python3 manage.py runserver

## Configure systemd to autostart gunicorn etc

copy script services to systemd

    cp scripts/*.service scripts/*.socket /etc/systemd/system

Then to uncomment Require=paperless-webserver.socket from paperless-webserver.service to start server 80 port

Then start services

    sudo systemctl enable paperless-webserver.service --now
    sudo systemctl enable paperless-consumer.service --now
    sudo systemctl enable paperless-scheduler.service --now
    sudo systemctl enable paperless-task-queue.service --now

# Development

## FrontEnd

    cd src-ui
    npm install
    ng serve
    ng build
    ng build --configuration production

### Configuration

    npm install -g @angular/cli

## BackEnd

    pipenv shell

### Configuration

    pip install psycopg2-binary
    cd src
    #Apply migrations and create a superuser for your development instance:
    python3 manage.py migrate
    python3 manage.py createsuperuser

### Launching debug

    sudo service redis-server restart
    sudo fuser -k 8000/tcp

    cd src/

    python3 manage.py runserver & \
    python3 manage.py document_consumer & \
    celery --app paperless worker -l DEBUG

## Manual Building

    ng build --configuration production
    python3 manage.py collectstatic
    pipenv requirements > requirements.txt

## Create deployable artificat

This script create a deployable artificat in dist folder

    ./scripts/create_deploy.sh  0.0.1
