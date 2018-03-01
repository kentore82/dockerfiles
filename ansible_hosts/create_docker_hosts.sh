#!/bin/bash

# Pull images
docker pull kentore82/centos7.4:base
docker pull kentore82/ubuntu16.04:base

hosts=( "ansible-router" "ansible-utility" "ansible-gateway" "ansible-data" )
os=( "ubuntu16.04:base" "centos7.4:base" "centos7.4:base" "centos7.4:base" )
ansible_host_file=( "kb0.yml" "kb1.yml" "kb2.yml" "kb3.yml" )

host_file_path=./host_vars

for ((i=0;i<${#hosts[@]};++i)); do
  echo Launching ${hosts[i]}-node on ${os[i]}
  docker run -d --name ${hosts[i]} kentore82/${os[i]}
  
  # Get container IP
  IP=$(docker inspect ${hosts[i]}|grep "\"IPAddress\": "|grep -Eo '[-1-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'|head -n1)
  
  echo Updating Ansible host var file ${ansible_host_file[i]}
  # Update Ansible hostfiles
  sed -i "/ip:/c\ip: $IP" ${host_file_path}/${ansible_host_file[i]}

done




