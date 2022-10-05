#!/bin/bash
set -eou pipefail

# Saves the value of an environment variable into a file. Use by Docker's secrets.
# Usage: file_env VAR [DEFAULT]
#    ie: file_env 'DB_PASSWORD' 'secret'
#        Will save the value 'secret' into DB_PASSWORD_FILE file.
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
    val="$(<"${!fileVar}")"
  fi

  if [[ -n $val ]]; then
    export "$var"="$val"
  fi

  unset "$fileVar"
}

KEYCLOAK_ARGS=""

#####################
# Create Admin User #
#####################

file_env 'KEYCLOAK_USER'
file_env 'KEYCLOAK_PASSWORD'

if [[ -n ${KEYCLOAK_USER:-} && -n ${KEYCLOAK_PASSWORD:-} ]]; then
  /opt/jboss/keycloak/bin/add-user-keycloak.sh --user "$KEYCLOAK_USER" --password "$KEYCLOAK_PASSWORD"
fi

##################
# Set Debug Port #
##################

if [[ -n ${DEBUG_PORT:-} ]]; then
  KEYCLOAK_ARGS+=" --debug $DEBUG_PORT"
fi

##########################
# Database Configuration #
##########################

file_env 'DB_USER'
file_env 'DB_PASSWORD'

export DB_VENDOR="mysql"
DB_NAME="MySQL"

# Append '?' in the beggining of the string if JDBC_PARAMS value isn't empty
JDBC_PARAMS=$(echo "${JDBC_PARAMS:-}" | sed '/^$/! s/^/?/')
export JDBC_PARAMS

echo "========================================================================="
echo ""
echo "  Using $DB_NAME database with vendor $DB_VENDOR"
echo ""
echo "========================================================================="
echo ""

/bin/sh /opt/jboss/build/set-database.sh $DB_VENDOR

exec /opt/jboss/keycloak/bin/standalone.sh $KEYCLOAK_ARGS $@
exit $?
