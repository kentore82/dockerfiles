#!/bin/bash

# Pull images
#docker pull kentore82/centos7.4:base
#docker pull kentore82/ubuntu16.04:base

hosts=( "ansible-utility" "ansible-gateway" "ansible-data" )
os="centos7.4:base"

ansible_host_file=( "kb1" "kb2" "kb3" )

# get domain from ansible inventory
out=$(cat ./hosts.yml |grep domain:)
host_domain=${out##*\ }

host_file_path=./host_vars

# Setup DNS server on Ubuntu
echo Launching ansible-router-node on ubuntu16.04:base

docker run -d --cap-add SYS_ADMIN --security-opt seccomp:unconfined -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /tmp/$(mktemp -d):/run --privileged -h kb0.${host_domain} --name ansible-router kentore82/ubuntu16.04:base

# Get container IP
DNSIP=$(docker inspect ansible-router|grep "\"IPAddress\": "|grep -Eo '[-1-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'|head -n1)

# Update Ansible hostfiles
echo Updating Ansible hosts.yml
sed -i "/    router_default_gw:/c\    router_default_gw: $DNSIP" hosts.yml

# Clear ssh-known hosts
ssh-keygen -f ~/.ssh/known_hosts -R $DNSIP

for ((i=0;i<${#hosts[@]};++i)); do
  echo Launching ${hosts[i]}-node on ${os}
  docker run -d --cap-add SYS_ADMIN --security-opt seccomp:unconfined \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /tmp/$(mktemp -d):/run --privileged \
  -h ${ansible_host_file[i]}.${host_domain} \
  --name ${hosts[i]} \
  --dns=$DNSIP --dns=8.8.8.8 --dns=8.8.4.4 kentore82/${os}
  
  # Get container IP
  IP=$(docker inspect ${hosts[i]}|grep "\"IPAddress\": "|grep -Eo '[-1-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'|head -n1)
  
  echo Updating Ansible host var file ${ansible_host_file[i]}
  # Update Ansible hostfiles
  sed -i "/ip:/c\ip: $IP" ${host_file_path}/${ansible_host_file[i]}.yml

  # Clear ssh-known hosts
  ssh-keygen -f ~/.ssh/known_hosts -R $IP

done



