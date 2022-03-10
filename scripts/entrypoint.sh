#!/bin/bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. ${SCRIPT_DIR}/functions.sh

require_env ADMIN_PASSWORD
require_env LDAP_SUFFIX
echo "Checking if TLS is enabled"
if [ -n "${LDAPS_PORT}" ]; then
  require_env LDAP_TLS_CA_FILE
  require_env LDAP_TLS_CERT_FILE
  require_env LDAP_TLS_KEY_FILE
fi

if [ -n "${DEBUG_SCRIPTS}" ]; then
  set -x
fi

export DATA_DIR="/data"
export INITIALIZED_FILE="${DATA_DIR}/.initialized"
export DATA_SLAPDD="${DATA_DIR}/slapd.d"
export DATA_DATABASE="${DATA_DIR}/db"
export ROOT_DN="${ADMIN_DN:-cn=admin,${LDAP_SUFFIX}}"
export ROOT_PASSWORD="$(echo -n ${ADMIN_PASSWORD} | base64)"
export DEBUG_LEVEL="${DEBUG:-0}"
export CONFIG_LDIFS="${CUSTOM_CONFIG_LDIFS:-/ldifs/config}"
export OBJECT_LDIFS="${CUSTOM_OBJECT_LDIFS:-/ldifs/objects}"

export OPENLDAP_BASE="/opt/openldap"
export OPENLDAP_BIN="${OPENLDAP_BASE}/bin"
export OPENLDAP_LIBEXEC="${OPENLDAP_BASE}/libexec"
export OPENLDAP_SBIN="${OPENLDAP_BASE}/sbin"
export SLAPD="${OPENLDAP_LIBEXEC}/slapd"

LDAP_URIS="ldapi://"
if [ -n "${LDAP_PORT}" ]; then
  LDAP_URIS="${LDAP_URIS} ldap://:${LDAP_PORT}"
fi
if [ -n "${LDAPS_PORT}" ]; then
  LDAP_URIS="${LDAP_URIS} ldaps://:${LDAPS_PORT}"
fi
export LDAP_URIS

if [ ! -f "${INITIALIZED_FILE}" ]; then
  /scripts/setup.sh
fi
exec /scripts/start.sh
