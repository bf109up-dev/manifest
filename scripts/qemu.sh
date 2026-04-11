#!/bin/bash
# Wisenet Yocto QEMU 실행 스크립트

MACHINE=${1:-qemuarm64}

echo "Starting runqemu for machine: ${MACHINE}"

# 빌드 디렉토리 경로 지정
export KAS_BUILD_DIR="output/${MACHINE}/build"

# 빌드 디렉토리 존재 여부 확인
if [ ! -d "${KAS_BUILD_DIR}" ]; then
    echo "Error: Build directory ${KAS_BUILD_DIR} not found."
    echo "Please run './scripts/build.sh ${MACHINE}' first."
    exit 1
fi

# kas shell을 통한 runqemu 실행
kas shell kas/${MACHINE}/kas-${MACHINE}.yml -c "runqemu nographic slirp"
