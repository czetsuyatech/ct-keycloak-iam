#!/bin/bash -e

###############################
# Download and Build Keycloak #
###############################

cd /opt/jboss/

keycloakDistLocalFile="/opt/jboss/keycloak_install_stage/downloads/$KEYCLOAK_DIST_FILE"
keycloakDistUrl="$KEYCLOAK_DIST_BASE$KEYCLOAK_DIST_FILE"

if [ -e $keycloakDistLocalFile ];
then
    echo "Keycloak from downloads folder: $keycloakDistLocalFile"
    tar zxf $keycloakDistLocalFile
else
    echo "Keycloak from remote source: $keycloakDistUrl"
    curl -L $keycloakDistUrl | tar zx
fi

mv /opt/jboss/keycloak-??.?.?* /opt/jboss/keycloak

###########################
# Create Database Modules #
###########################

mkdir -p /opt/jboss/keycloak/modules/system/layers/base/com/mysql/jdbc/main
cd /opt/jboss/keycloak/modules/system/layers/base/com/mysql/jdbc/main

mysqlConnectorLocalFile="/opt/jboss/keycloak_install_stage/downloads/$JDBC_MYSQL_JAR_FILE"
mysqlConnectorUrl="$JDBC_MYSQL_JAR_BASE$JDBC_MYSQL_JAR_FILE"
if [ -e $mysqlConnectorLocalFile ];
then
    echo "MySql connector from downloads folder: $mysqlConnectorLocalFile"
    cp $mysqlConnectorLocalFile .
else
    echo "MySql connector from remote source: $mysqlConnectorUrl"
    curl -O "$mysqlConnectorUrl"
fi

cp /opt/jboss/modules/databases/mysql/module.xml .

###################
# Set Permissions #
###################

echo "jboss:x:1000:jboss" >> /etc/group
echo "jboss:x:1000:1000:JBoss user:/opt/jboss:/sbin/nologin" >> /etc/passwd
chown -R jboss:jboss /opt/jboss
chmod -R g+rw /opt/jboss

rm -rf /opt/jboss/keycloak/standalone/tmp/auth
rm -rf /opt/jboss/keycloak/domain/tmp/auth