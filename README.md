# CT Keycloak IAM

This project extends the Keycloak authentication server to cover complicated enterprise use cases such as
multi-tenancy, custom storage, n-level resellers by extending Keycloak through its SPIs such as storage,
authentication, identity provider, etc.

## Versions

This project is running on:

- Keycloak 16.1.1
- MySQL JDBC Driver 8.0.29

## Features

### Custom login page

A custom theme "czetsuyatech" is configured when you run the container.

![Login Page](docs/img/login-page.png)

The theme is available at keycloak-docker-assembly/src/main/resources/themes/czetsuyatech and can easily be overriden.


### Multi-tenant

TODO

### N-reseller level

TODO

## WIKI

- [Development Guide](docs/development.md)
- [Production Guide](docs/production.md)
- [Troubleshooting Guide](docs/troubleshooting-guide.md)