#!/usr/bin/env bash
export JAVA_HOME="/usr/lib/jvm/jre-openjdk"

# for pyspark
export PYSPARK_PYTHON="/usr/bin/python3"
# for driver, defaults to PYSPARK_PYTHON
export PYSPARK_DRIVER_PYTHON="/usr/bin/python3"

export HADOOP_HOME="/user/local/hadoop"

HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
export HADOOP_CONF_DIR

export SPARK_HOME=/usr/local/spark