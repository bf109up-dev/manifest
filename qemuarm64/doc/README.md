# AI Agent Distro - QEMU ARM64 (Scarthgap)

이 저장소는 `qemuarm64` 에뮬레이터 환경을 위한 **AI Agent Distro 1.0.0** 빌드 및 개발 환경을 관리합니다. `kas` 툴을 활용하여 선언적이고 재현 가능한 빌드 환경을 제공합니다.

---

## 🚀 1. 빠른 시작 (Quick Start)

본 프로젝트는 동적 경로(`${TOPDIR}`) 기능을 지원하므로, 프로젝트 루트 어디서든 안정적으로 빌드가 가능합니다.

### 시스템 빌드
```bash
# 프로젝트 루트(scarthgap)로 이동
cd /home/yang/work/yocto/ai-agent_test0/scarthgap

# 10개의 코어(0-9)를 사용하여 빌드 실행
KAS_BUILD_DIR=machine/qemuarm64/build taskset -c 0-9 ~/.local/bin/kas build manifest/qemuarm64/kas-qemuarm64.yml
```

### 에뮬레이터 실행 (QEMU)
```bash
# 빌드 완료 후 nographic 모드로 부팅
KAS_BUILD_DIR=machine/qemuarm64/build ~/.local/bin/kas shell manifest/qemuarm64/kas-qemuarm64.yml -c "runqemu nographic slirp"
```
*   **로그인**: `root` (비밀번호 없음 - `debug-tweaks` 적용됨)
*   **종료**: `Ctrl + A` 누른 후 `X`

---

## 🛠️ 2. 주요 커스텀 기능 (Custom Features)

현재 이미지(`product-test0`)에는 개발 및 테스트를 위한 다음 기능들이 포함되어 있습니다.

1.  **Built-in Driver**: `i2c-stub` (커널 내장 드라이버 활성화)
2.  **External Module**: `hello-mod` (부팅 시 자동 로드 확인용 커널 모듈)
3.  **User Application**: `hello` (C 기반 "Hello, AI Agent Distro!" 출력 어플리케이션)
4.  **Dev-Friendly**: 비밀번호 없는 root 로그인 및 SSH 접근 환경

---

## 📚 3. 개발 및 포팅 가이드 (Documentation)

상세한 개발 절차 및 시스템 구조는 `doc/` 디렉토리의 전용 가이드를 참조하십시오.

- **[포팅 및 패키지 관리 종합 가이드 (Porting.md)](./Porting.md)**
    - 커널 `menuconfig` 및 `diffconfig` 활용법
    - 신규 드라이버 및 앱 레시피 작성법
    - `IMAGE_FEATURES` 및 `IMAGE_INSTALL`을 통한 패키지 최적화
    - **WORKDIR** 및 **Deploy** 바이너리 물리 경로 안내

---

## 📁 4. 프로젝트 및 빌드 디렉토리 구조 (Directory Structure)

본 프로젝트는 `kas` 설정을 통해 소스, 캐시, 빌드 결과물을 체계적으로 관리합니다.

### 🍱 소스 및 설정 레이어 (Source Layers)
| 경로 | 구분 | 상세 역할 |
| :--- | :--- | :--- |
| **`manifest/qemuarm64/`** | 프로젝트 설정 | 빌드 선언서(`.yml`) 및 공식 문서(`doc/`) 보관 |
| **`meta-qemuarm64/`** | 보드 지원 (BSP) | qemuarm64 전용 드라이버 및 어플리케이션 레시피 |
| **`meta-product/`** | 제품 사양 | 제품 이미지(`product-test0`) 정의 및 공통 환경 설정 |
| **`poky/`, `meta-oe/`** | 표준 레이어 | Yocto/OpenEmbedded 표준 업스트림 레이어 |

### 🏗️ 빌드 및 캐시 인프라 (Build & Mirror)
빌드 수행 시 `machine/` 디렉토리에 작업 공간이 동적으로 생성됩니다.

| 구분 | 물리적 경로 | 주요 내용 및 용도 | 용량(예상) |
| :--- | :--- | :--- | :--- |
| **Main Build** | `machine/qemuarm64/build/` | 비트베이크 빌드가 실제로 일어나는 핵심 공간 | **~60 GB** |
| **Deploy** | `.../build/tmp/deploy/images/` | 커널, RootFS 등 **최종 결과물**이 생성되는 곳 | **~300 MB** |
| **WORKDIR** | `.../build/tmp/work/` | 각 패키지별 컴파일/패키징 중간 작업 공간 | (Build 포함) |
| **Log** | `.../build/tmp/log/` | 빌드 전체 프로세스의 통합 실행 로그 | < 100 MB |
| **Downloads** | `machine/qemuarm64/mirror/downloads/` | 모든 오픈소스 원천 소스 보관 (`DL_DIR`) | **~10 GB** |
| **SState Cache** | `machine/qemuarm64/mirror/sstate-cache/` | 빌드 결과물 바이너리 캐시 (`SSTATE_DIR`) | **~5 GB** |

### 🔍 Yocto 주요 변수 설명 (Variable Mapping)
`kas` 설정파일에서 핵심적으로 사용된 Yocto 변수들의 상세 역할과 활용 범위입니다.

| 변수명 | 상세 설명 및 역할 | 활용 위치 (Scope) |
| :--- | :--- | :--- |
| **`DL_DIR`** | 소스 코드(tarball, git 등)가 다운로드되어 수집되는 통합 저장소 | **Global** (전체 Fetching 단계) |
| **`SSTATE_DIR`** | 빌드 가속을 위한 **Shared State** 파일(바이너리 캐시) 저장 폴더 | **Global** (재빌드 시간 단축) |
| **`TMPDIR`** | 비트베이크 빌드 시 실제 산출물이 전개되는 내부 작업 공간 | **Global** (Build Artifacts) |
| **`IMAGE_INSTALL`** | 전용 이미지 레시피에 **추가로 설치할 패키지** 목록 정의 | **Image Recipe** (`product-test0.bb`) |
| **`IMAGE_CLASSES`** | 가상 머신(QEMU) 부팅을 위한 메타데이터 생성 기능을 이미지에 추가 | **Image Recipe** (`runqemu` 연동) |
| **`PREFERRED_PROVIDER`** | `virtual/kernel` 등 가상 타겟에 대해 실제로 사용할 커널 레시피 지정 | **Machine Config** (커널 선택) |
| **`BB_NUMBER_THREADS`** | 비트베이크가 동시에 수행할 **태스크(Job)**의 최대 개수 | **Global** (Job Scheduling) |

---
**Maintainer**: AI Agent Team
**Target**: qemuarm64 (scarthgap branch)
