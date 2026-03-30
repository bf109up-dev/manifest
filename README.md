# Wisenet Yocto Manifest

이 저장소는 `kas` 도구를 사용하여 Wisenet 프로젝트의 빌드 환경과 레이어를 관리합니다.
설정, 스크립트, 문서를 체계적으로 관리할 수 있도록 구조화되어 있습니다.

## 📂 디렉토리 구조
- **`kas/qemuarm64/`**: QEMU 64-bit ARM 가상머신 빌드 설정
- **`kas/lock/`**: 레이어 버전 고정을 위한 락(lock) 파일
- **`scripts/`**: 호스트 설정 및 비트베이크(BitBake) 관련 스크립트
- **`docs/`**: 상세 빌드 가이드 및 아키텍처 문서

## 🚀 빌드 시작하기

### 1. 호스트 환경 설정 (최초 1회)
빌드에 필요한 의존성 패키지를 설치합니다.
```bash
./scripts/setup-host.sh
```

### 2. 이미지 빌드
`kas` 도구를 사용하여 원하는 환경의 이미지를 빌드합니다.

**QEMU ARM64 일반 빌드:**
```bash
# 기본 설정을 사용한 빌드 (브랜치 최신 버전 사용)
kas build kas/qemuarm64/kas-qemuarm64.yml
```

**재현 가능한 빌드 (Lock 파일 사용):**
```bash
# 특정 시점의 레이어 커밋을 고정하여 빌드 (추천)
kas build kas/qemuarm64/kas-qemuarm64.yml:kas/lock/kas-project-lock.yml
```

**QEMU ARM64 특정 태그/버전 빌드:**
```bash
# 특정 릴리스 태그나 버전이 명시된 설정으로 빌드
kas build kas/qemuarm64/kas-qemuarm64-tag.yml
```

## 🛠️ 유지보수 가이드

### 락(Lock) 파일 업데이트
레이어의 현재 커밋 상태를 락 파일에 강제로 업데이트하려면 다음 명령어를 실행합니다:
```bash
kas dump --lock kas/qemuarm64/kas-qemuarm64.yml > kas/lock/kas-project-lock.yml
```

## 📖 상세 문서
더 자세한 정보는 `docs/` 디렉토리의 문서를 참고하세요:
- [빌드 가이드 (Build Guide)](docs/build-guide.md)
- [소프트웨어 아키텍처 (Software Architecture)](docs/architecture.md)
