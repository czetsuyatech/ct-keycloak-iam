#!/bin/bash -e

### ------------------------- Download Keycloak ------------------------- ###

cd /opt/jboss/

keycloakDistFile="/opt/jboss/keycloak_install_stage/downloads/$KEYCLOAK_DIST_FILE"
keycloakDistUrl="$KEYCLOAK_DIST_BASE$KEYCLOAK_DIST_FILE"

if [ -e $keycloakDistFile ];
then
    echo "Keycloak from downloads folder: $keycloakDistFile"
else
    echo "Keycloak from remote source: $keycloakDistUrl"
    keycloakDistFile = $keycloakDistUrl
fi

tar zxf ${keycloakDistFile}
mv /opt/jboss/keycloak-??.?.?* ${JBOSS_HOME}
rm ${keycloakDistFile}
chown -R jboss:0 ${JBOSS_HOME}
chmod -R g+rw ${JBOSS_HOME}

### ------------------------- Install Theme ------------------------- ###

mkdir -p /opt/jboss/keycloak/themes
cp -R /opt/jboss/keycloak_install_stage/themes/* /opt/jboss/keycloak/themes

### ------------------------- Create Database Modules ------------------------- ###

mkdir -p ${JBOSS_HOME}/modules/system/layers/base/com/mysql/main

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

cp /opt/jboss/modules/databases/mysql/module.xml ${JBOSS_HOME}/modules/system/layers/base/com/mysql/main
sed -i "s|\[MYSQL\_VERSION\]|${MYSQL_VERSION}|g" ${JBOSS_HOME}/modules/system/layers/base/com/mysql/main/module.xml

### ------------------------- Install Keycloak Providers ------------------------- ###

mkdir -p ${JBOSS_HOME}/providers
cp /opt/jboss/keycloak_install_stage/keycloak_providers/*.jar ${JBOSS_HOME}/providers

echo "Providers installed"
ls -laR ${JBOSS_HOME}/providers

### ------------------------- Cleanup ------------------------- ###

rm -rf ${JBOSS_HOME}/standalone/tmp/auth
rm -rf ${JBOSS_HOME}/domain/tmp/auth