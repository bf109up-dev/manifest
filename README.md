# Wisenet Yocto Manifest (Scarthgap)

이 저장소는 `kas` 도구를 사용하여 Wisenet 프로젝트의 빌드 환경과 레이어를 관리합니다. 
**QEMU ARM64** 에뮬레이터와 **Raspberry Pi 3 (64-bit)** 실물 보드를 모두 지원하도록 구조화되어 있습니다.

---

## 📂 디렉토리 구조

- **`kas/`**: 타겟별 kas 빌드 설정 디렉토리
    - `qemuarm64/`: 에뮬레이터용 설정 및 락 파일
    - `rpi3/`: 라즈베리 파이 3용 설정 및 락 파일
- **`meta-*/`**: 커스텀 레이어 그룹
    - `meta-product`: 제품 이미지(`product-test0`) 정의 및 공용 패키지(`hello`, `hello-mod`)
    - `meta-qemuarm64`: QEMU 전용 BSP 래퍼
    - `meta-rpi3`: RPI3 전용 BSP 래퍼
    - `meta-raspberrypi`: 라즈베리 파이 공식 BSP
- **`scripts/`**: 빌드 자동화 스크립트 (`build.sh`, `lock.sh`)
- **`docs/`**: 타겟별 상세 빌드 및 포팅 가이드 문서
- **`output/`**: 빌드 중간 결과물이 저장되는 폴더 (타겟별로 분리 관리)

---

## 🚀 빌드 시작하기

시스템 빌드를 위해 미리 작성된 자동화 스크립트(`scripts/`)를 사용합니다.

### 1. 전용 스크립트로 빌드 실행
기본값은 `qemuarm64`이며, 인자로 대상 머신을 지정할 수 있습니다.

```bash
# QEMU ARM64 빌드 (기본값)
./scripts/build.sh

# Raspberry Pi 3 빌드
./scripts/build.sh rpi3
```

### 2. 락(Lock) 파일 업데이트
레시피의 커밋 해시를 현재 상태로 고정하여 재현성을 확보합니다.

```bash
# 특정 머신의 락 갱신
./scripts/lock.sh rpi3
```

---

## 🪞 통합 미러(Unified Mirror) 설정

본 프로젝트는 중복 다운로드를 방지하고 빌드 시간을 단축하기 위해 **통합 글로벌 미러**를 사용합니다.

- **미러 경로**: `/home/yang/work/yocto/mirror/github/manifest/r202604051543/`
- **구조**:
    - `downloads/`: 모든 타겟의 오픈소스 소스코드 통합 보관
    - `sstate-cache/`: 빌드 바이너리 캐시 공유 (QEMU와 RPI3 간 호환 가능한 태스크 공유)

> [!TIP]
> 새로운 환경에서 빌드 시, 상기 미러 경로가 유효한지 확인하십시오. 각 타겟의 `.yml` 파일 내 `SOURCE_MIRROR_URL` 및 `SSTATE_MIRRORS` 변수가 이 경로를 참조합니다.

---

## 📖 상세 상세 가이드
각 타겟에 대한 구체적인 포팅 및 이미지 플래싱 방법은 아래 문서를 참고하십시오.

- **QEMU ARM64**: [docs/qemuarm64/README.md](docs/qemuarm64/README.md)
- **Raspberry Pi 3**: [docs/rpi3/README.md](docs/rpi3/README.md)

---
**Maintainer**: AI Agent Team
**Status**: Stable (scarthgap branch)