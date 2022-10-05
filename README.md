# ct-universal-signon

This project provide customized SSO on top of Keycloak framework and deployed on AWS ECS service.

## Development

Start MySQL docker container for testing.

```
docker run --name mysql_8 -e MYSQL_ROOT_PASSWORD=ipiel -e MYSQL_USER=keycloak_user -e MYSQL_PASSWORD=k3yc10@K -e MYSQL_DATABASE=keycloak -p 33306:3306 -d mysql:8.0.29
```

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
git submodule add -b main git@github.com:czetsuya/ct-keycloak-plugins.git
```

### Fetch

```shell
// pull all the sub modules for the first time
git submodule update --init --recursive

// update the sub modules
git submodule update --recursive --remote
```