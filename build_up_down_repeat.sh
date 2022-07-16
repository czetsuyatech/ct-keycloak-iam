#!/bin/bash

mode=$1

if [ "$mode" != "single"  ] && [ "$mode" != "cluster"  ]; then
    echo "usage: build_up_down_repeat.sh single|cluster" 1>&2
    exit 1
fi

dockerComposeFile="./docker-assembly/docker/docker-compose-$mode.yml"

while true;
do

    mvn clean install
    if [[ "$?" -ne 0 ]] ;
    then
        echo 'Maven build failed !!!';
        read -p "Press any key to continue..." -n1 mavenContinueKey
        continue
    fi

    docker-compose -f $dockerComposeFile build

    if [ "$mode" == "cluster" ]; then
        docker-compose -f $dockerComposeFile up -d --scale ct-universal-signon=2
    else
        docker-compose -f $dockerComposeFile up -d
    fi

    while true;
    do
        read -p "Continue (c) or Exit (e): " -n1 commandChar
        printf "\n"
        if [ "$commandChar" == "c" ] || [ "$commandChar" == "e" ];
        then
            break
        fi
    done

    docker-compose -f $dockerComposeFile down -v

    docker container prune --force

    docker image prune --force

    if [ "$commandChar" == "e" ];
    then
        exit 0
    fi

done