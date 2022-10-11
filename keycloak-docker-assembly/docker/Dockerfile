#################################################################
#####                 Build ct-keycloak-iam                 #####
#################################################################

FROM openjdk:11.0.7-jdk-slim-buster

### ------------------------- Environment Variables ------------------------- ###

ENV KEYCLOAK_VERSION 16.1.1
ENV JDBC_MYSQL_VERSION 8.0.29
ENV JDBC_POSTGRES_VERSION 42.5.0

ENV LAUNCH_JBOSS_IN_BACKGROUND 1
ENV PROXY_ADDRESS_FORWARDING false
ENV JBOSS_HOME /opt/jboss/keycloak
ENV LANG en_US.UTF-8
ENV KEYCLOAK_IMPORT /opt/jboss/keycloak_install_stage/realms/ct-realm-dev.json

### ------------------------- Bash Arguments ------------------------- ###

ARG KEYCLOAK_DIST_BASE=https://github.com/keycloak/keycloak/releases/download/$KEYCLOAK_VERSION/
ARG KEYCLOAK_DIST_FILE=keycloak-$KEYCLOAK_VERSION.tar.gz
ARG JDBC_MYSQL_JAR_BASE=https://repo1.maven.org/maven2/mysql/mysql-connector-java/$JDBC_MYSQL_VERSION/
ARG JDBC_MYSQL_JAR_FILE=mysql-connector-java-$JDBC_MYSQL_VERSION.jar

ARG JDBC_POSTGRESQL_JAR_BASE=https://repo1.maven.org/maven2/org/postgresql/postgresql/$JDBC_POSTGRES_VERSION/
ARG JDBC_POSTGRESQL_JAR_FILE=postgresql-$JDBC_POSTGRES_VERSION.jar

### ------------------------- Base ------------------------- ###

USER root

# Install the necessary packages

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-transport-https ca-certificates curl jsvc unzip \
# git
        git \
# procps : for 'free' command
        procps \
# iputils-ping : for 'ping' command
        iputils-ping \
# iproute2 : for 'ip' command
        iproute2 \
# java.lang.UnsatisfiedLinkError: /usr/local/openjdk-11/lib/libfontmanager.so: libfreetype.so.6: cannot open shared object file: No such file or directory
# java.lang.NoClassDefFoundError: Could not initialize class sun.awt.X11FontManager
# https://github.com/docker-library/openjdk/pull/235#issuecomment-424466077
        fontconfig libfreetype6 \
    && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

RUN groupadd -r jboss -g 1000 \
    && useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss User" jboss \
    && chown -R jboss:jboss /opt/jboss \
    && chmod -R g+rw /opt/jboss

### ------------------------- Configurations ----------------------------- ###

COPY --chown=jboss:jboss src/main/resources/build /opt/jboss/build

RUN chmod +x /opt/jboss/build/*

COPY --chown=jboss:jboss  downloads /opt/jboss/keycloak_install_stage/downloads

COPY --chown=jboss:jboss  src/main/resources/modules /opt/jboss/modules

COPY --chown=jboss:jboss  src/main/resources/realms /opt/jboss/keycloak_install_stage/realms

COPY --chown=jboss:jboss  src/main/resources/themes /opt/jboss/keycloak_install_stage/themes

#ADD src/main/resources/override /opt/jboss/keycloak_install_stage/override

COPY --chown=jboss:jboss  target/keycloak_providers /opt/jboss/keycloak_install_stage/keycloak_providers

### ------------------------- Build Keycloak ----------------------------- ###

RUN /opt/jboss/build/build-keycloak.sh

### ------------------------- Start Keycloak ------------------------- ###

USER jboss

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

# Expose Keycloak ports
EXPOSE 8080 8443 9990

ENTRYPOINT [ "/opt/jboss/build/docker-entrypoint.sh" ]

CMD ["-b", "0.0.0.0"]