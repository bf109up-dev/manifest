#!/bin/bash

MACHINE=${1:-qemuarm64}

echo "Building for machine: ${MACHINE}"

mkdir -p output/${MACHINE}/build
KAS_BUILD_DIR=output/${MACHINE}/build kas build kas/${MACHINE}/kas-${MACHINE}.yml:kas/${MACHINE}/kas-${MACHINE}-lock.yml
