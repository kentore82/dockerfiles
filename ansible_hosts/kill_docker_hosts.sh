#!/bin/bash

hosts=( "ansible-router" "ansible-utility" "ansible-gateway" "ansible-data" )
os=( "ubuntu16.04:base" "centos7.4:base" "centos7.4:base" "centos7.4:base" )
ansible_host_file=( "kb0.yml" "kb1.yml" "kb2.yml" "kb3.yml" )

host_file_path=./host_vars

for ((i=0;i<${#hosts[@]};++i)); do
  echo Stopping  ${hosts[i]}-node on ${os[i]}
  docker container stop ${hosts[i]}
  echo Killing...
  docker container rm ${hosts[i]}
done

