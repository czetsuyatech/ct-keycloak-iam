FROM registry.access.redhat.com/ubi8-minimal

ENV KEYCLOAK_VERSION 12.0.4
ENV JDBC_MYSQL_VERSION 8.0.11

ENV LAUNCH_JBOSS_IN_BACKGROUND 1
ENV PROXY_ADDRESS_FORWARDING false
ENV JBOSS_HOME /opt/jboss/keycloak
ENV LANG en_US.UTF-8

ENV KEYCLOAK_IMPORT /opt/jboss/keycloak_install_stage/realms/ct-realm.json

ARG KEYCLOAK_DIST_BASE=https://github.com/keycloak/keycloak/releases/download/$KEYCLOAK_VERSION/
ARG KEYCLOAK_DIST_FILE=keycloak-$KEYCLOAK_VERSION.tar.gz

ARG JDBC_MYSQL_JAR_BASE=https://repo1.maven.org/maven2/mysql/mysql-connector-java/$JDBC_MYSQL_VERSION/
ARG JDBC_MYSQL_JAR_FILE=mysql-connector-java-$JDBC_MYSQL_VERSION.jar

USER root

RUN microdnf update -y && microdnf install -y glibc-langpack-en gzip hostname java-11-openjdk-headless openssl tar which && microdnf clean all

ADD src/main/resources/tools /opt/jboss/tools
RUN chmod +x /opt/jboss/tools/*

#ADD src/main/resources/themes /opt/jboss/keycloak_install_stage/themes
#
#ADD src/main/resources/realms /opt/jboss/keycloak_install_stage/realms
#
#ADD src/main/resources/override /opt/jboss/keycloak_install_stage/override
#
#ADD downloads /opt/jboss/keycloak_install_stage/downloads

#ADD target/keycloak_providers /opt/jboss/keycloak_install_stage/keycloak_providers

RUN /opt/jboss/tools/build-keycloak.sh

USER 1000

EXPOSE 8080
EXPOSE 8443

ENTRYPOINT [ "/opt/jboss/tools/docker-entrypoint.sh" ]

CMD ["-b", "0.0.0.0"]