# Development

This product is using the following versions:
- Keycloak 16.1.1
- MySQL JDBC driver 8.0.29

**Start MySQL and the custom Keycloak server.**

```
docker-compose -f ./keycloak-docker-assembly/docker/docker-compose-dev.yml up --build
```

The --build parameter, makes sure that the docker image is rebuilt before launching it.

Stop the Keycloak server, add the -v parameter to delete the volumes

```
docker-compose -f ./keycloak-docker-assembly/docker/docker-compose-dev.yml down -v
```

## SubModules

This project is built such that the main project with customized Keycloak running on Docker is exposed to the public.
Its submodules are hosted on another repositories in private such as Keycloak SPIs, Spring Security, etc.

**Add the submodules to your project**

If you have access to the private repositories, you can check them out by running the following command.

```shell
git submodule add -b main git@github.com:czetsuya/ct-keycloak-spis.git
```

**If you already downloaded the sub modules and wanted to get an update**

```shell
// pull all the sub modules for the first time
git submodule update --init --recursive

// update the sub modules
git submodule update --recursive --remote
```