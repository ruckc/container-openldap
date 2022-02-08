#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. ${SCRIPT_DIR}/functions.sh

banner $0

catcherr() {
    echo "An error occurred at line $1"
    if [ -n "${DEBUG_SCRIPTS}" ]; then
      sleep 1500
    fi
    exit 1
}
trap 'catcherr $LINENO' ERR

set -o pipefail
if [ -n "${DEBUG_SCRIPTS}" ]; then
  set -x
fi

# initialize slapd.d
mkdir -pv "${DATA_SLAPDD}" "${DATA_DATABASE}"
find $DATA_SLAPDD -type f
pushd /opt/base/slapd.d
find * -type d -exec mkdir -pv "${DATA_SLAPDD}/{}" \;
for FILE in $(find * -type f); do
    copyfile "${FILE}" "${DATA_SLAPDD}/${FILE}"
done
popd

find $DATA_SLAPDD -type f

banner "loading config ldifs"
# slapadd config ldifs
for DIR in ${CUSTOM_CONFIG_LDIFS//,/ }; do
  slapadd_ldifs 0 "${DIR}"
done
slaptest
find $DATA_SLAPDD -type f

banner "loading object ldifs"
# ldapadd object ldifs
for DIR in ${CUSTOM_OBJECT_LDIFS//,/ }; do
slapadd_ldifs 1 "${DIR}"
done
slaptest
find $DATA_SLAPDD -type f

# configure TLS
if [ -n "${LDAPS_PORT}" ]; then
slapmodify 0 /dev/stdin << EOF
dn: cn=config
changetype: modify
replace: olcTLSCACertificateFile
olcTLSCACertificateFile: ${LDAP_TLS_CA_FILE}
-
replace: olcTLSCertificateFile
olcTLSCertificateFile: ${LDAP_TLS_CERT_FILE}
-
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: ${LDAP_TLS_KEY_FILE}
EOF
fi


# mark initialized
touch "${INITIALIZED_FILE}"
