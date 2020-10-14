# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias hdfs='/usr/local/hadoop/bin/hdfs'

export JAVA_HOME="/usr/lib/jvm/jre-openjdk"
export HDFS_NAMENODE_USER="root"
export HDFS_DATANODE_USER="root"
export HDFS_SECONDARYNAMENODE_USER="root"

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi