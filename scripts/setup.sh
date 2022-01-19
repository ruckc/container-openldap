#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. ${SCRIPT_DIR}/functions.sh

banner $0

set -e
set -x

# initialize slapd.d
mkdir -pv "${DATA_SLAPDD}" "${DATA_DATABASE}"
pushd /opt/base/slapd.d
find * -type d -exec mkdir -pv "${DATA_SLAPDD}/{}" \;
for FILE in $(find * -type f); do
    copyfile "${FILE}" "${SLAPDD}/${FILE}"
done
popd

slaptest

# slapadd config ldifs
slapadd_ldifs 0 "${CUSTOM_CONFIG_LDIFS}"
slaptest

# ldapadd object ldifs
slapadd_ldifs 1 "${CUSTOM_OBJECT_LDIFS}"
slaptest

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