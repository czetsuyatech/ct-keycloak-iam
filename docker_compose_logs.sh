#!/bin/bash

mode=$1
expr=$2

if [ "$mode" != "single"  ] && [ "$mode" != "cluster"  ]; then
    echo "usage: docker_compose_logs.sh single|cluster [expr]" 1>&2
    exit 1
fi

dockerComposeFile="./docker-assembly/docker/docker-compose-$mode.yml"

while true;
do

    docker-compose -f $dockerComposeFile logs -f | grep $expr

    echo 'Waiting for docker container to start...';
    sleep 5s

done
