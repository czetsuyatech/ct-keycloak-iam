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
    val="$(<"${!fileVar}")"
  fi

  if [[ -n $val ]]; then
    export "$var"="$val"
  fi

  unset "$fileVar"
}

SYS_PROPS=""

#####################
# Create Admin User #
#####################

file_env 'KEYCLOAK_USER'
file_env 'KEYCLOAK_PASSWORD'

if [[ -n ${KEYCLOAK_USER:-} && -n ${KEYCLOAK_PASSWORD:-} ]]; then
  /opt/jboss/keycloak/bin/add-user-keycloak.sh --user "$KEYCLOAK_USER" --password "$KEYCLOAK_PASSWORD"
fi

#########
# Debug #
#########

if [[ -n ${DEBUG_PORT:-} ]]; then
  SYS_PROPS+=" --debug $DEBUG_PORT"
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

echo "========================================================================="
echo ""
echo "  Using $DB_NAME database with vendor $DB_VENDOR"
echo ""
echo "========================================================================="
echo ""

/bin/sh /opt/jboss/tools/databases/change-database.sh $DB_VENDOR

exec /opt/jboss/keycloak/bin/standalone.sh $SYS_PROPS $@
exit $?