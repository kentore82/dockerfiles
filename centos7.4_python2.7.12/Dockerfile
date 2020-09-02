FROM centos:7.8.2003

MAINTAINER Ken Tore Tallakstad <tallakstad@gmail.com>

ARG spark_version="2.4.6"
ARG hadoop_version="2.7"
ARG openjdk_version="1.8.0"
ARG py4j_version="0.10.7"
ARG spark_checksum="3A9F401EDA9B5749CDAFD246B1D14219229C26387017791C345A23A65782FB8B25A302BF4AC1ED7C16A1FE83108E94E55DAD9639A51C751D81C8C0534A4A9641"

ENV container docker

RUN yum -y update; yum clean all

RUN yum -y swap -- remove systemd-container systemd-container-libs -- install systemd systemd-libs dbus fsck.ext4 passwd sudo vim initscripts


### Python 2.7.12
RUN yum install -y epel-release
RUN yum install -y https://repo.ius.io/ius-release-el7.rpm
RUN yum -y update
RUN yum install -y wget python-pip
RUN mkdir /tmp/python2.7.12
WORKDIR /tmp/python2.7.12
RUN wget http://weespey.com/downloads/python-2.7.12-centos7-x86_64.tar.gz
RUN tar -xvf python-2.7.12-centos7-x86_64.tar.gz
RUN yum localinstall -y --nogpgcheck python-libs-2.7.12-8.el7.centos.x86_64.rpm python-2.7.12-8.el7.centos.x86_64.rpm python-devel-2.7.12-8.el7.centos.x86_64.rpm tkinter-2.7.12-8.el7.centos.x86_64.rpm python-tools-2.7.12-8.el7.centos.x86_64.rpm
###

RUN yum install -y gcc 
RUN yum install -y gcc-c++

RUN yum install -y vim wget

# Python 3
RUN yum install -y python3 python3-libs python3-devel python3-pip

RUN yum clean all


RUN pip2.7 install setuptools==44.0.0 avro==1.8.2 coverage redis protobuf==3.9.2 snakebite jsonpath numpy==1.16.4 pandas==0.24.2 requests psycopg2-binary sqlalchemy cityhash pyhwschema avro_json_serializer pyproj==2.2.1 wheel pip==20.2.2

RUN pip3 install setuptools avro==1.8.2 coverage redis protobuf snakebite jsonpath numpy pandas requests psycopg2-binary sqlalchemy cityhash avro_json_serializer pyproj wheel jupyterlab

RUN pip2.7 install ipykernel==4.10.1



# Jupyterhub config
RUN mkdir /root/.jupyter
RUN echo $'c.NotebookApp.ip = \'0.0.0.0\'  \n\
c.NotebookApp.allow_root=True' > /root/.jupyter/jupyter_notebook_config.py

RUN rm -f /usr/share/jupyter/kernels/python2/kernel.json
RUN echo $'{"display_name":"Python 2","language":"python","argv":["python2","-m","ipykernel_launcher","-f","{connection_file}"]}' > /usr/share/jupyter/kernels/python2/kernel.json

# Spark
RUN pip2.7 install pyspark==${spark_version}
RUN pip3 install pyspark==${spark_version}

# Spark dependencies
# Default values can be overridden at build time
# (ARGS are in lower case to distinguish them from ENV)

ENV APACHE_SPARK_VERSION="${spark_version}" \
    HADOOP_VERSION="${hadoop_version}"

RUN yum install -y "java-${openjdk_version}-openjdk-headless"
 
# Spark installation
WORKDIR /tmp
# Using the preferred mirror to download Spark
# hadolint ignore=SC2046
RUN wget -q $(wget -qO- https://www.apache.org/dyn/closer.lua/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz\?as_json | \
    python -c "import sys, json; content=json.load(sys.stdin); print(content['preferred']+content['path_info'])") && \
    echo "${spark_checksum} *spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" | sha512sum -c - && \
    tar xzf "spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" -C /usr/local --owner root --group root --no-same-owner && \
    rm "spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz"

WORKDIR /usr/local
RUN ln -s "spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}" spark

# Configure Spark
ENV SPARK_HOME=/usr/local/spark
ENV PYTHONPATH="${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-${py4j_version}-src.zip" \
    SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info" \
    PATH=$PATH:$SPARK_HOME/bin





ADD ./start.sh /start.sh



RUN systemctl mask dev-mqueue.mount dev-hugepages.mount \
    systemd-remount-fs.service sys-kernel-config.mount \
    sys-kernel-debug.mount sys-fs-fuse-connections.mount \
    display-manager.service graphical.target systemd-logind.service


RUN yum -y install openssh-server sudo openssh-clients
RUN sed -i 's/#PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config

# set UseDNS=no so avooid slow ssh login
RUN sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config

RUN ssh-keygen -q -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa && \
    ssh-keygen -q -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa && \
    ssh-keygen -q -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519
RUN echo 'root:root' | chpasswd

# emable dbus, hostname, sshd, jupyter service
ADD dbus.service /etc/systemd/system/dbus.service
ADD jupyter.service /etc/systemd/system/jupyter.service
RUN systemctl enable dbus.service
RUN systemctl enable systemd-hostnamed.service
RUN systemctl enable sshd.service
RUN systemctl enable jupyter.service

WORKDIR /
RUN chmod 755 /start.sh
RUN ./start.sh

# expose ssh system port
EXPOSE 22

CMD ["/usr/sbin/init"]
