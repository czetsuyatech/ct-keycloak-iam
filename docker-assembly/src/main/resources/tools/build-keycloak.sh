#!/bin/bash -e

###########################
# Download and Build Keycloak
###########################

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

#####################
# Create DB modules #
#####################

#mkdir -p /opt/jboss/keycloak/modules/system/layers/base/com/mysql/jdbc/main
#cd /opt/jboss/keycloak/modules/system/layers/base/com/mysql/jdbc/main
#
#mysqlConnectorLocalFile="/opt/jboss/keycloak_install_stage/downloads/$JDBC_MYSQL_JAR_FILE"
#mysqlConnectorUrl="$JDBC_MYSQL_JAR_BASE$JDBC_MYSQL_JAR_FILE"
#if [ -e $mysqlConnectorLocalFile ];
#then
#    echo "MySql connector from [local download]: $mysqlConnectorLocalFile"
#    cp $mysqlConnectorLocalFile .
#else
#    echo "MySql connector from [download]: $mysqlConnectorUrl"
#    curl -O "$mysqlConnectorUrl"
#fi
#
#cp /opt/jboss/tools/databases/mysql/module.xml .

######################
# Configure Keycloak #
######################

#cd /opt/jboss/keycloak
#
#bin/jboss-cli.sh --file=/opt/jboss/tools/cli/standalone-configuration.cli
#rm -rf /opt/jboss/keycloak/standalone/configuration/standalone_xml_history
#
#bin/jboss-cli.sh --file=/opt/jboss/tools/cli/standalone-ha-configuration.cli
#rm -rf /opt/jboss/keycloak/standalone/configuration/standalone_xml_history

########################
# Install CX providers #
########################

#ls -l /opt/jboss/keycloak_install_stage/keycloak_providers
#
#mkdir -p /opt/jboss/keycloak/providers
#cp /opt/jboss/keycloak_install_stage/keycloak_providers/*.jar /opt/jboss/keycloak/providers
#
#ls -laR /opt/jboss/keycloak/providers

##########################
# Copy CX template files #
##########################

#ls -laR /opt/jboss/keycloak_install_stage/themes
#
#mkdir -p /opt/jboss/keycloak/themes
#cp -R /opt/jboss/keycloak_install_stage/themes/* /opt/jboss/keycloak/themes
#
#ls -laR /opt/jboss/keycloak/themes

##########################
# Copy override files    #
##########################

#ls -laR /opt/jboss/keycloak/modules/system/layers/keycloak/org/keycloak/keycloak-services/main
#
#cp -Rf /opt/jboss/keycloak_install_stage/override/keycloak-services-8.0.2.jar /opt/jboss/keycloak/modules/system/layers/keycloak/org/keycloak/keycloak-services/main/keycloak-services-8.0.2.jar
#
#ls -laR /opt/jboss/keycloak/modules/system/layers/keycloak/org/keycloak/keycloak-services/main

###################
# Set permissions #
###################

echo "jboss:x:1000:jboss" >> /etc/group
echo "jboss:x:1000:1000:JBoss user:/opt/jboss:/sbin/nologin" >> /etc/passwd
chown -R jboss:jboss /opt/jboss
chmod -R g+rw /opt/jboss
ls /opt/jboss/tools
rm -rf /opt/jboss/keycloak/standalone/tmp/auth
rm -rf /opt/jboss/keycloak/domain/tmp/auth