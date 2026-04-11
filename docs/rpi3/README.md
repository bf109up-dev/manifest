# AI Agent Distro - Raspberry Pi 3 (64-bit scarthgap)

이 저장소는 `raspberrypi3-64` 하드웨어 환경을 위한 **AI Agent Distro 1.0.0** 빌드 및 개발 환경을 관리합니다. `kas` 툴을 활용하여 선언적이고 재현 가능한 빌드 환경을 제공하며, QEMU 에뮬레이터와 물리 보드 모두를 지원합니다.

---

## 🚀 1. 빠른 시작 (Quick Start)

본 프로젝트는 통합 캐시 및 미러 설정을 지원하므로, 초기 빌드 시에도 매우 빠른 속도로 빌드가 가능합니다.

### 시스템 빌드
```bash
# 프로젝트 루트(manifest)로 이동
# 프로젝트 루트(manifest)로 이동
cd /home/yang/work/yocto/test-20260409/manifest

# 전용 빌드 스크립트를 사용하여 빌드 실행 (RPI3 타겟)
./scripts/build.sh rpi3
```

> **참고**: 직접 `kas` 명령어를 사용하려면 아래와 같이 실행합니다.
> ```bash
> kas build kas/rpi3/kas-rpi3.yml
> ```

---

## 🛠️ 2. 주요 커스텀 기능 (Custom Features)

현재 RPI3 이미지(`product-test0`)에는 개발 및 테스트를 위한 다음 기능들이 포함되어 있습니다.

1.  **Kernel**: `linux-raspberrypi` (공식 라즈베리 파이 커널 6.6 기반)
2.  **External Module**: `hello-mod` (부팅 시 자동 로드 확인용 커널 모듈 - `meta-product` 공용)
3.  **User Application**: `hello` (C 기반 "Hello, AI Agent Distro!" 출력 어플리케이션 - `meta-product` 공용)
4.  **Dev-Friendly**: 비밀번호 없는 root 로그인 및 SSH 접근 환경

---

## 💾 3. SD 카드 플래싱 (SD Fusing)

빌드가 완료된 최종 이미지(`.wic.bz2`)를 실제 보드 구동을 위해 SD 카드에 기록하는 방법입니다.

### 권장 방식: `bmaptool` 사용
```bash
# 빌드 결과물 경로로 이동
cd output/rpi3/build/tmp/deploy/images/raspberrypi3-64/

# SD 카드 드라이브(/dev/sdX)에 고속 기록
sudo bmaptool copy product-test0-raspberrypi3-64.wic.bz2 /dev/sdX
```

---

## 📚 4. 개발 및 포팅 가이드 (Documentation)

상세한 개발 절차 및 RPI3 특화 시스템 구조는 `docs/rpi3/` 디렉토리의 가이드를 참조하십시오.

- **[RPI3 포팅 및 패키지 관리 종합 가이드 (Porting.md)](./Porting.md)**
    - 커널 설정 및 디렉토리 구조 안내
    - 신규 드라이버 및 앱 레시피 적용법
    - **DEPLOY** 및 **WORKDIR** 물리 경로 안내

---

## 📁 5. 프로젝트 및 빌드 디렉토리 구조 (Directory Structure)

### 🍱 소스 및 설정 레이어 (Source Layers)
| 경로 | 구분 | 상세 역할 |
| :--- | :--- | :--- |
| **`kas/rpi3/`** | 프로젝트 설정 | RPI3용 빌드 선언서(`.yml`) 및 락 파일 보관 |
| **`meta-rpi3/`** | 보드 지원 (Wrapper) | RPI3 특화 설정 및 래퍼 레이어 |
| **`meta-raspberrypi/`** | 공식 BSP | 라즈베리 파이 공식 보드 지원 레이어 |
| **`meta-product/`** | 제품 사양 | 제품 이미지 정의 및 공통 패키지(`hello` 등) 관리 |

### 🏗️ 빌드 및 캐시 인프라 (Unified Mirror)
본 프로젝트는 **통합 글로벌 미러(`r202604051543`)**를 사용하여 QEMU와 RPI3 간 캐시를 공유합니다.

| 구분 | 물리적 경로 | 주요 내용 및 용도 |
| :--- | :--- | :--- |
| **Main Build** | `output/rpi3/build/` | 비트베이크 빌드가 실제로 일어나는 작업 공간 |
| **Deploy** | `.../build/tmp/deploy/images/` | 커널 및 SD 카드용 **최종 이미지** 생성 위치 |
| **Global Mirror** | `/home/yang/work/yocto/mirror/.../r202604051543/` | 통합 다운로드 및 SState 캐시 저장소 |

---
**Maintainer**: AI Agent Team
**Target**: Raspberry Pi 3 (scarthgap branch)
