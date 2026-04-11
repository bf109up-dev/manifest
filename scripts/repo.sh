#!/bin/bash

# 스크립트 위치 기준 manifest 디렉토리로 이동
cd "$(dirname "$0")/.." || exit 1

# 첫 번째 인자가 없으면 기본값으로 qemuarm64 사용
# 두 번째 인자가 없으면 기본값으로 status 사용
MACHINE=${1:-qemuarm64}
COMMAND=${2:-status}

echo "--------------------------------------------------------"
echo "Machine: ${MACHINE}"
echo "Command: git ${COMMAND}"
echo "--------------------------------------------------------"

# kas를 사용하여 모든 저장소에서 명령어 실행
kas for-all-repos kas/${MACHINE}/kas-${MACHINE}.yml "git ${COMMAND}"
