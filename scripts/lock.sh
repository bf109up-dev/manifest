#!/bin/bash
DATE=$(date +%Y%m%d)
LOCK_FILE="kas/qemuarm64/kas-qemuarm64-lock.yml"
DATED_LOCK_FILE="kas/qemuarm64/kas-qemuarm64-lock-${DATE}.yml"

kas dump --update --lock kas/qemuarm64/kas-qemuarm64.yml > ${LOCK_FILE}
cp ${LOCK_FILE} ${DATED_LOCK_FILE}


