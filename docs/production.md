# Production

## Database

Keycloak supports many databases. This example is for using MySQL.

### You can run your database

```
docker run --name mysql_8 -e MYSQL_ROOT_PASSWORD=<xxx> -e MYSQL_USER=<xxx> -e MYSQL_PASSWORD=<xxx> -e 
MYSQL_DATABASE=keycloak -p 33306:3306 -d mysql:8.0.29
```

### Using a hosted database solution

If you don't want to spin your database, you can use a hosted solution from different cloud providers. For
example AWS RDS.

## Custom Keycloak Docker Container

Start the container.

```
docker-compose -f ./docker-assembly/docker/docker-compose-single.yml up
```

Add the --build parameter to rebuild the images.

Stop the containers.

```
docker-compose -f ./keycloak-docker-assembly/docker/docker-compose-single.yml down
```

Add the -v parameter to remove the volumes.

## Required Environment Variables

You will need to set the following environment variables correctly.

- DB_ADDR
- DB_PORT
- DB_DATABASE
- DB_USER
- DB_PASSWORD
- DB_JDBC_PARAMS
- KEYCLOAK_IMPORT - uncomment this parameter in the docker-compose file

## Compatibility Version Tested

| Keycloak | MySQL  |
|----------|--------|
| 16.1.1   | 8.0.29 |
| 12.0.4   | 8.0.22 |

_*These values can be changed in the Dockerfile file._