#!/bin/bash

MACHINE=${1:-qemuarm64}
DATE=$(date +%Y%m%d)

echo "Updating kas lock file for machine: ${MACHINE}"

LOCK_FILE="kas/${MACHINE}/kas-${MACHINE}-lock.yml"
DATED_LOCK_FILE="kas/${MACHINE}/kas-${MACHINE}-lock-${DATE}.yml"

kas dump --update --lock kas/${MACHINE}/kas-${MACHINE}.yml > ${LOCK_FILE}
cp ${LOCK_FILE} ${DATED_LOCK_FILE}


