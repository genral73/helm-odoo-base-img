FROM debian:buster-slim

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG="C.UTF-8" \
    ODOO_LOG="/var/log/odoo-server.log" \
    ODOO_CONFIG="/etc/odoo-server.conf" \
    TZ="Asia/Riyadh"

ARG ODOO_USER=odoo
ARG ODOO_HOME=/home/$ODOO_USER
ARG ODOO_SERVER_DIR=$ODOO_HOME/server

# Use backports to avoid install some libs with pip
RUN echo 'deb http://deb.debian.org/debian stretch-backports main' > /etc/apt/sources.list.d/backports.list

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN set -x; \
        apt-get update \
        && apt-get install -y \
            ca-certificates \
            curl \
            dirmngr \
            fonts-noto-cjk \
            gnupg \
            libssl-dev \
            node-less \
            python3-num2words \
            python3-pip \
            python3-phonenumbers \
            python3-pyldap \
            python3-qrcode \
            python3-renderpm \
            python3-setuptools \
            python3-vobject \
            python3-watchdog \
            python3-xlwt \
            xz-utils \
            python3-venv python3-dev python3-wheel libxslt-dev libzip-dev \
            libldap2-dev libsasl2-dev \
            libpq-dev libffi-dev libxml2-dev \
            libxslt1-dev zlib1g-dev \
            procps vim git wget \
            &&  apt-get clean
            #python-pip python-setuptools  python-dev \

COPY ./resource/wkhtmltox_0.12.5-1.stretch_amd64.deb /tmp/            
RUN set -x; \
    apt-get install -y /tmp/wkhtmltox_0.12.5-1.stretch_amd64.deb \
    && rm -rf /tmp/wkhtmltox_0.12.5-1.stretch_amd64.deb

# install  postgresql-client v12
RUN set -x; \
        echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
        && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
        && apt-get update  \
        && apt-get install -y postgresql-client-12 \
        && rm -rf /var/lib/apt/lists/* 

# # # install  Redis Session Store  & S3 Storage SDK
RUN pip3 install --no-cache-dir redis boto3 num2words odooly
# #RUN pip install --no-cache-dir redis 
RUN adduser --system --quiet --shell=/bin/bash  --home=$ODOO_HOME  --group $ODOO_USER 

# Install Odoo
COPY server  $ODOO_SERVER_DIR

RUN pip3 install --no-cache-dir -r ${ODOO_SERVER_DIR}/requirements.txt \
    && chown $ODOO_USER:$ODOO_USER -R $ODOO_HOME