#!/bin/bash
set -eou pipefail

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
    local var="$1"
    local fileVar="${var}_FILE"
    local def="${2:-}"
    if [[ ${!var:-} && ${!fileVar:-} ]]; then
        echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
        exit 1
    fi
    local val="$def"
    if [[ ${!var:-} ]]; then
        val="${!var}"
    elif [[ ${!fileVar:-} ]]; then
        val="$(< "${!fileVar}")"
    fi

    if [[ -n $val ]]; then
        export "$var"="$val"
    fi

    unset "$fileVar"
}

SYS_PROPS=""

##################
# Add admin user #
##################

file_env 'KEYCLOAK_USER'
file_env 'KEYCLOAK_PASSWORD'

if [[ -n ${KEYCLOAK_USER:-} && -n ${KEYCLOAK_PASSWORD:-} ]]; then
    /opt/jboss/keycloak/bin/add-user-keycloak.sh --user "$KEYCLOAK_USER" --password "$KEYCLOAK_PASSWORD"
fi

#########
# DEBUG #
#########

if [[ -n ${DEBUG_PORT:-} ]]; then
    SYS_PROPS+=" --debug $DEBUG_PORT"
fi

############
# Hostname #
############

if [[ -n ${KEYCLOAK_FRONTEND_URL:-} ]]; then
    SYS_PROPS+=" -Dkeycloak.frontendUrl=$KEYCLOAK_FRONTEND_URL"
fi

if [[ -n ${KEYCLOAK_HOSTNAME:-} ]]; then
    SYS_PROPS+="-Dkeycloak.hostname.provider=fixed -Dkeycloak.hostname.fixed.hostname=$KEYCLOAK_HOSTNAME"

    if [[ -n ${KEYCLOAK_HTTP_PORT:-} ]]; then
        SYS_PROPS+=" -Dkeycloak.hostname.fixed.httpPort=$KEYCLOAK_HTTP_PORT"
    fi

    if [[ -n ${KEYCLOAK_HTTPS_PORT:-} ]]; then
        SYS_PROPS+=" -Dkeycloak.hostname.fixed.httpsPort=$KEYCLOAK_HTTPS_PORT"
    fi

    if [[ -n ${KEYCLOAK_ALWAYS_HTTPS:-} ]]; then
            SYS_PROPS+=" -Dkeycloak.hostname.fixed.alwaysHttps=$KEYCLOAK_ALWAYS_HTTPS"
    fi
fi

################
# Realm import #
################

if [[ -n ${KEYCLOAK_IMPORT:-} ]]; then
    SYS_PROPS+=" -Dkeycloak.import=$KEYCLOAK_IMPORT"
fi

########################
# JGroups bind options #
########################

if [[ -z ${BIND:-} ]]; then
    BIND=$(hostname --all-ip-addresses)
fi
if [[ -z ${BIND_OPTS:-} ]]; then
    for BIND_IP in $BIND
    do
        BIND_OPTS+=" -Djboss.bind.address=$BIND_IP -Djboss.bind.address.private=$BIND_IP "
    done
fi
SYS_PROPS+=" $BIND_OPTS"

#########################################
# Expose management console for metrics #
#########################################

if [[ -n ${KEYCLOAK_STATISTICS:-} ]] ; then
    SYS_PROPS+=" -Djboss.bind.address.management=0.0.0.0"
fi

#################
# Configuration #
#################

# If the server configuration parameter is not present, append the HA profile.
if echo "$@" | grep -E -v -- '-c |-c=|--server-config |--server-config='; then
    SYS_PROPS+=" -c=standalone-ha.xml"
fi

############
# DB setup #
############

file_env 'DB_USER'
file_env 'DB_PASSWORD'

export DB_VENDOR="mysql"
DB_NAME="MySQL"

# Append '?' in the beginning of the string if JDBC_PARAMS value isn't empty
JDBC_PARAMS=$(echo "${JDBC_PARAMS:-}" | sed '/^$/! s/^/?/')
export JDBC_PARAMS

# Convert deprecated DB specific variables
function set_legacy_vars() {
  local suffixes=(ADDR DATABASE USER PASSWORD PORT)
  for suffix in "${suffixes[@]}"; do
    local varname="$1_$suffix"
    if [[ -n ${!varname:-} ]]; then
      echo WARNING: "$varname" variable name is DEPRECATED replace with DB_"$suffix"
      export DB_"$suffix=${!varname}"
    fi
  done
}
set_legacy_vars "$(echo "$DB_VENDOR" | tr "[:upper:]" "[:lower:]")"

# Configure DB

echo "========================================================================="
echo ""
echo "  Using $DB_NAME database"
echo ""
echo "========================================================================="
echo ""


/bin/sh /opt/jboss/tools/databases/change-database.sh $DB_VENDOR

#/opt/jboss/tools/x509.sh
#/opt/jboss/tools/jgroups.sh
#/opt/jboss/tools/infinispan.sh
#/opt/jboss/tools/statistics.sh
#/opt/jboss/tools/autorun.sh
#/opt/jboss/tools/vault.sh

##################
# Start Keycloak #
##################

exec /opt/jboss/keycloak/bin/standalone.sh $SYS_PROPS $@
exit $?
