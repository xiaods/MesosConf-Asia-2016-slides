#!/bin/bash

USE_ALIYUN_MIRROR=1

MANAGER_IP=$1
NODE_IP=$2
TOKEN=`cat /vagrant/worker_token`


if ! which docker >/dev/null 2>&1; then
	if [ -n "$USE_ALIYUN_MIRROR" ]
	then
    curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    curl -sSL http://acs-public-mirror.oss-cn-hangzhou.aliyuncs.com/docker-engine/internet | sh -
    sudo cp -n /lib/systemd/system/docker.service /etc/systemd/system/docker.service
    sudo sed -i "s|ExecStart=/usr/bin/dockerd|ExecStart=/usr/bin/dockerd --registry-mirror=https://vwrzfgqh.mirror.aliyuncs.com|g" /etc/systemd/system/docker.service
    sudo systemctl daemon-reload
    sudo service docker restart
  else
		curl -sSL https://get.docker.com/ | sh
	fi
	gpasswd -a vagrant docker
	docker swarm join --listen-addr ${NODE_IP}:2377 --advertise-addr ${NODE_IP} --token=$TOKEN ${MANAGER_IP}:2377
fi
