#!/bin/bash

$mode=$1

echo "usage: standalone_keycloak.sh"

dockerComposeFile="./keycloak-docker-assembly/docker/docker-compose-$mode.yml"

while true; do

  mvn clean install
  if [[ "$?" -ne 0 ]]; then
    echo 'Build failed'
    read -p "Press any key to continue..." -n1 mavenContinueKey
    continue
  fi

  docker-compose -f $dockerComposeFile build

  if [ "$mode" == "cluster" ]; then
    docker-compose -f $dockerComposeFile up -d --scale ct-keycloak-iam=3
  else
    // single or dev
    docker-compose -f $dockerComposeFile up -d
  fi

  while true; do
    read -p "Continue (c) or Exit (x): " -n1 inputChar
    printf "\n"
    if [ "$inputChar" == "c" ] || [ "$inputChar" == "x" ]; then
      break
    fi
  done

  docker-compose -f $dockerComposeFile down -v

  docker container prune --force

  docker image prune --force

  if [ "$inputChar" == "x" ]; then
    exit 0
  fi

done
