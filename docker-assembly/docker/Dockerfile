FROM quay.io/keycloak/keycloak:latest as builder

# Add configs, resources

COPY src/main/resources/conf /opt/keycloak/conf

RUN ls -l /opt/keycloak/conf

# Install custom providers
#RUN curl -sL https://github.com/aerogear/keycloak-metrics-spi/releases/download/2.5.3/keycloak-metrics-spi-2.5.3.jar -o /opt/keycloak/providers/keycloak-metrics-spi-2.5.3.jar
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/
WORKDIR /opt/keycloak

# for demonstration purposes only, please make sure to use proper certificates in production instead
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias \
    server -ext "SAN:c=DNS:localhost,IP:127.0.0.1,IP:192.168.1.18" -keystore conf/server.keystore
# change these values to point to a running datastore instance

ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "-cf keycloak.conf", "start"]