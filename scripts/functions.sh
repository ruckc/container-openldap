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
    envsubst < "${1}" > "${DATA_SLAPDD}/${2}"
}

function slaptest() {
    "${OPENLDAP_SBIN}/slaptest" -F "${DATA_SLAPDD}" -u
}

function slapadd() {
    "${OPENLDAP_SBIN}/slapadd" -d "${DEBUG_LEVEL}" -F "${DATA_SLAPDD}" $@
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

function slapmodify() {
    slapmodify -n ${1} -d "${DEBUG_LEVEL}" -F "${DATA_SLAPDD}" < ${2}
}