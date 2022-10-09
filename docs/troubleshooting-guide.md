# Troubleshooting Guide

In the unfortunate event that the container won't start, for example if connection to the remote sources failed, try 
the following fixes.

1. Docker container won't start.

Rebuild the container and start again.

```
// delete the volume
docker-compose -f ./keycloak-docker-assembly/docker/docker-compose-dev.yml down -v

// rebuild and start the container
docker-compose -f ./keycloak-docker-assembly/docker/docker-compose-dev.yml up --build
```