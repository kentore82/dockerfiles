FROM python:3.6

# Superset version
ARG SUPERSET_VERSION=0.33.0rc1

# Configure environment
ENV GUNICORN_BIND=0.0.0.0:8088 \
    GUNICORN_LIMIT_REQUEST_FIELD_SIZE=0 \
    GUNICORN_LIMIT_REQUEST_LINE=0 \
    GUNICORN_TIMEOUT=60 \
    GUNICORN_WORKERS=2 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONPATH=/etc/superset:/home/superset:$PYTHONPATH \
    SUPERSET_REPO=apache/incubator-superset \
# SherpaConsulting/incubator-superset \
    SUPERSET_VERSION=${SUPERSET_VERSION} \
    SUPERSET_HOME=/var/lib/superset
ENV GUNICORN_CMD_ARGS="--workers ${GUNICORN_WORKERS} --timeout ${GUNICORN_TIMEOUT} --bind ${GUNICORN_BIND} --limit-request-line ${GUNICORN_LIMIT_REQUEST_LINE} --limit-request-field_size ${GUNICORN_LIMIT_REQUEST_FIELD_SIZE}"

# Create superset user & install dependencies
RUN useradd -U -m superset && \
    mkdir /etc/superset  && \
    mkdir ${SUPERSET_HOME} && \
    chown -R superset:superset /etc/superset && \
    chown -R superset:superset ${SUPERSET_HOME} && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get update && \
    apt-get install -y \
        build-essential \
        curl \
        wget \
        tar \
        default-libmysqlclient-dev \
        freetds-dev \
        freetds-bin \
        libffi-dev \
        libldap2-dev \
        libpq-dev \
        libsasl2-dev \
        libssl1.0 \
        npm && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/* && \
    
    # Download custom superset repo
    wget https://github.com/${SUPERSET_REPO}/archive/${SUPERSET_VERSION}.tar.gz -O ${SUPERSET_VERSION}.tar.gz && \
    tar -xf ${SUPERSET_VERSION}.tar.gz && \
    pip install --no-cache-dir -r ./incubator-superset-${SUPERSET_VERSION}/requirements.txt && \
    pip install --no-cache-dir \
        flask-cors==3.0.3 \
        flask-mail==0.9.1 \
        flask-oauth==0.12 \
        flask_oauthlib==0.9.3 \
        gevent==1.2.2 \
        impyla==0.14.0 \
        infi.clickhouse-orm==1.0.2 \
        mysqlclient==1.3.7 \
        psycopg2==2.6.1 \
        pyhive==0.5.1 \
        pyldap==2.4.28 \
        pymssql==2.1.3 \
        redis==2.10.5 \
        sqlalchemy-clickhouse==0.1.5.post0 \
        sqlalchemy-redshift==0.7.1

# move superset install after js is ok.
# Build JS frontend
WORKDIR ./incubator-superset-${SUPERSET_VERSION}/superset/assets
RUN npm ci && \
    npm run build && \
    rm -rf node_modules

WORKDIR ../../../
RUN pip install --no-cache-dir ./incubator-superset-${SUPERSET_VERSION} 

# Configure Filesystem
COPY superset /usr/local/bin
RUN chown -R superset:superset /usr/local/bin/superset-init && \
    chown -R superset:superset /usr/local/bin/superset-demo && \
    chmod 0777 /usr/local/bin/superset-init && \
    chmod 0777 /usr/local/bin/superset-demo
VOLUME /home/superset \
       /etc/superset \
       /var/lib/superset
WORKDIR /home/superset

# Deploy application
EXPOSE 8088
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]
CMD ["gunicorn", "superset:app"]
#CMD ["/bin/bash"]
USER superset
