FROM centos:7.8.2003

MAINTAINER Ken Tore Tallakstad <tallakstad@gmail.com>

ARG python_version="3.6"
ARG hadoop_version="3.2.1"
ARG spark_version="2.4.7"
ARG spark_hadoop_version="2.7"
ARG openjdk_version="1.8.0"
ARG py4j_version="0.10.7"
ARG spark_checksum="0F5455672045F6110B030CE343C049855B7BA86C0ECB5E39A075FF9D093C7F648DA55DED12E72FFE65D84C32DCD5418A6D764F2D6295A3F894A4286CC80EF478"

ENV container docker

ENV PYTHON_VERSION="${python_version}"

RUN yum -y update; yum clean all

RUN yum -y swap -- remove systemd-container systemd-container-libs -- install systemd systemd-libs dbus fsck.ext4 passwd sudo initscripts

RUN yum install -y gcc 
RUN yum install -y gcc-c++

RUN yum install -y vim wget

# Set timezone
RUN rm -f /etc/localtime
RUN ln -s /usr/share/zoneinfo/Europe/Oslo /etc/localtime

# Python 3
RUN yum install -y python${PYTHON_VERSION//.} python${PYTHON_VERSION//.}-libs python${PYTHON_VERSION//.}-devel python${PYTHON_VERSION//.}-pip

RUN yum clean all

RUN pip${PYTHON_VERSION} install setuptools \
                                 avro \
                                 coverage \
                                 redis \
                                 protobuf \
                                 snakebite-py3 \
                                 jsonpath \
                                 numpy \
                                 pandas \
                                 requests \
                                 psycopg2-binary \
                                 sqlalchemy \
                                 cityhash \
                                 avro_json_serializer \
                                 pyproj \
                                 shapely \
                                 wheel \
                                 jupyterlab \
                                 pytest

# Jupyterhub config
RUN mkdir /root/.jupyter
RUN echo $'c.NotebookApp.ip = \'0.0.0.0\'  \n\
c.NotebookApp.allow_root=True' > /root/.jupyter/jupyter_notebook_config.py

# Spark dependencies
# Default values can be overridden at build time
# (ARGS are in lower case to distinguish them from ENV)

ENV APACHE_SPARK_VERSION="${spark_version}" \
    SPARK_HADOOP_VERSION="${spark_hadoop_version}" \
    HADOOP_VERSION="${hadoop_version}"

RUN yum install -y "java-${openjdk_version}-openjdk-headless"

# Spark installation
WORKDIR /tmp
# Using the preferred mirror to download Spark
# hadolint ignore=SC2046
RUN wget -q $(wget -qO- https://www.apache.org/dyn/closer.lua/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION}.tgz\?as_json | \
    python -c "import sys, json; content=json.load(sys.stdin); print(content['preferred']+content['path_info'])") && \
    echo "${spark_checksum} *spark-${APACHE_SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION}.tgz" | sha512sum -c - && \
    tar xzf "spark-${APACHE_SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION}.tgz" -C /usr/local --owner root --group root --no-same-owner && \
    rm "spark-${APACHE_SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION}.tgz"

WORKDIR /usr/local
RUN ln -s "spark-${APACHE_SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION}" spark



# Configure Spark
ENV SPARK_HOME=/usr/local/spark
ENV PYTHONPATH="${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-${py4j_version}-src.zip" \
    SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info" \
    PATH=$PATH:$SPARK_HOME/bin

# Permanently put pyspark on PYTHON_PATH
RUN printf "${SPARK_HOME}/python\n${SPARK_HOME}/python/lib/py4j-${py4j_version}-src.zip\n" > /usr/local/lib/python${PYTHON_VERSION}/site-packages/spark_bindings.pth

# Set spark env and conf
ADD spark-env.sh ${SPARK_HOME}/conf/spark-env.sh
ADD spark-defaults.conf ${SPARK_HOME}/conf/spark-defaults.conf

# HDFS
RUN wget "https://apache.uib.no/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz"  -P /tmp && \
    tar xzf "/tmp/hadoop-${HADOOP_VERSION}.tar.gz" -C /usr/local --owner root --group root --no-same-owner && \
    rm -f "/tmp/hadoop-${HADOOP_VERSION}.tar.gz"

ADD ./hdfs-site.xml /usr/local/hadoop-${HADOOP_VERSION}/etc/hadoop/hdfs-site.xml
ADD ./core-site.xml /usr/local/hadoop-${HADOOP_VERSION}/etc/hadoop/core-site.xml

RUN ln -s "/usr/local/hadoop-${HADOOP_VERSION}" /usr/local/hadoop

# HDFS tmp and conf dir
RUN mkdir /tmp/hadoop && \
    mkdir -p /etc/hadoop/conf

# HDFS symlink hadoop conf
RUN ln -s /usr/local/hadoop-${HADOOP_VERSION}/etc/hadoop/* /etc/hadoop/conf

ADD ./.bashrc /root/.bashrc

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

# Setup passwordless ssh
RUN ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa && \
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys && \
    chmod 0600 /root/.ssh/authorized_keys

# emable dbus, hostname, sshd, jupyter service
ADD dbus.service /etc/systemd/system/dbus.service
ADD jupyter.service /etc/systemd/system/jupyter.service
RUN systemctl enable dbus.service
RUN systemctl enable systemd-hostnamed.service
RUN systemctl enable sshd.service
RUN systemctl enable jupyter.service

# Start HDFS
ENV JAVA_HOME="/usr/lib/jvm/jre-openjdk"
ENV HDFS_NAMENODE_USER="root"
ENV HDFS_DATANODE_USER="root"
ENV HDFS_SECONDARYNAMENODE_USER="root"
RUN /usr/local/hadoop-${HADOOP_VERSION}/bin/hdfs namenode -format
ADD hdfs.service /etc/systemd/system/hdfs.service
RUN systemctl enable hdfs.service

# Enable prev command search for root
ADD .inputrc /root/.inputrc

# expose ssh system port
EXPOSE 22

CMD ["/usr/sbin/init"]
