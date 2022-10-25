#!/bin/bash
ipv4=$1
image=registry:2
docker=/usr/bin/docker
echo "Starting registry"
$docker volume ls | grep ks_registry
volume=$?
if [ $volume -eq 1 ]
then
	echo $docker volume create ks_registry
fi
$docker ps -a | grep registry2
exist=$?
if [ ! $exist -eq 0 ];
then
	echo "Creating docker registry with IP ${ipv4}"
	$docker run -d --name registry2 \
		-v ks_registry:/var/lib/registry \
		-p ${ipv4}:5000:5000 ${image}
else
	echo "Registry already exists"
	$docker start registry2
fi


