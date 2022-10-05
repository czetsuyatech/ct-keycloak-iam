# CT Keycloak IAM

This projects extends Keycloak to cover complicated enterprise grade use cases such as n-level resellers by 
extending Keycloak through it's SPIs such as storage, authentication, identity provider, etc.

## Development

Start MySQL and the custom Keycloak server.

```
docker-compose -f ./docker-assembly/docker/docker-compose-dev.yml up --build
```

The --build parameter, makes sure that the docker image is rebuilt before launching it.

Stop the Keycloak server, add the -v parameter to delete the volumes

```
docker-compose -f ./docker-assembly/docker/docker-compose-dev.yml down -v
```

## Production

```
docker run --name mysql_8 -e MYSQL_ROOT_PASSWORD=<xxx> -e MYSQL_USER=<xxx> -e MYSQL_PASSWORD=<xxx> -e 
MYSQL_DATABASE=keycloak -p 33306:3306 -d mysql:8.0.29
```

Or use a hosted MySQL installation.

Start the container.

```
docker-compose -f ./docker-assembly/docker/docker-compose-single.yml up
```

Add the --build parameter to rebuild the images.


Stop the containers.

```
docker-compose -f ./docker-assembly/docker/docker-compose-single.yml down
```

Add the -v parameter to remove the volumes.

## SubModules

### Add

```shell
git submodule add -b main git@github.com:czetsuya/ct-keycloak-spis.git
```

### Fetch

```shell
// pull all the sub modules for the first time
git submodule update --init --recursive

// update the sub modules
git submodule update --recursive --remote
```