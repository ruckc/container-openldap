function require_env() {
  echo "Checking for ${1} environment variable"
  if [ -z "${!1}" ]; then
    echo "Require ${1} environment variable"
    if [ -n "${2}" ]; then
        echo "${2}"
    fi
    exit 1
  fi
}

function banner() {
    echo "=============================================================================="
    echo "$@"
    echo "=============================================================================="
}

function copyfile() {
    envsubst < "${1}" > "${2}"
}

function slapcat() {
    $OPENLDAP_SBIN/slapcat -n ${1} -F "${DATA_SLAPDD}"
}

function slaptest() {
    "${OPENLDAP_SBIN}/slaptest" -F "${DATA_SLAPDD}" -u
}

function slapadd() {
    "${OPENLDAP_SBIN}/slapadd" -d "${DEBUG_LEVEL}" -F "${DATA_SLAPDD}" $@
}

function ldapadd() {
    "${OPENLDAP_BIN}/ldapadd" -d "${DEBUG_LEVEL}" -Y EXTERNAL -H ldapi:// $@
}

function slapadd_ldifs() {
    DB=$1
    DIR=$2

    if [ ! -d "${DIR}" ]; then
        return
    fi

    COUNT=$(find ${DIR} -type f -name \*.ldif | wc -l)
    if [ $COUNT -gt 0 ]; then
        for LDIF in ${DIR}/*.ldif; do
            echo "Loading ${LDIF}"
            slapadd -n ${DB} -l ${LDIF}
        done
    fi
}

function ldapadd_ldifs() {
    DIR=$1

    if [ ! -d "${DIR}" ]; then
        return
    fi

    COUNT=$(find ${DIR} -type f -name \*.ldif | wc -l)
    if [ $COUNT -gt 0 ]; then
        for LDIF in ${DIR}/*.ldif; do
            echo "Loading ${LDIF}"
            ldapadd -n ${DB} -f ${LDIF}
        done
    fi
}

function slapmodify() {
    ${OPENLDAP_SBIN}/slapmodify -n ${1} -d "${DEBUG_LEVEL}" -F "${DATA_SLAPDD}" < ${2}
}
