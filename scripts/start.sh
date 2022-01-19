#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. ${SCRIPT_DIR}/functions.sh

banner $0

set -e
set -x

$SLAPD -VVV

exec $SLAPD -h "${LDAP_URIS}" -d "${DEBUG_LEVEL}" -F "${DATA_SLAPDD}"