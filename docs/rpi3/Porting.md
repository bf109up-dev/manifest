# RPI3 포팅 및 패키지 관리 종합 가이드 (Scarthgap)

이 문서는 `raspberrypi3-64` 타겟 시스템에 드라이버, 커널 모듈, 전용 어플리케이션을 포팅하고 배포판(Distro)의 패키지 구성을 최적화하는 절차를 기술합니다.

---

## 1. Kernel Configuration & Customization
RPI3 전용 커널인 `linux-raspberrypi` 설정을 변경하고 영구적으로 반영하는 절차입니다.

### 🛠️ `menuconfig`를 활용한 동적 설정
1. **설정 도구 호출**:
   ```bash
   # KAS 환경 내에서 RPI3 커널 설정 도구 실행
   KAS_BUILD_DIR=output/rpi3/build kas shell kas/rpi3/kas-rpi3.yml -c "bitbake -c menuconfig linux-raspberrypi"
   ```
2. **설정 변경**: 필요한 옵션을 활성화한 후 저장합니다.

### 💾 설정 내용 영구 반영 (`diffconfig`)
1. **변경분 추출**:
   ```bash
   KAS_BUILD_DIR=output/rpi3/build kas shell kas/rpi3/kas-rpi3.yml -c "bitbake -c diffconfig linux-raspberrypi"
   ```
   * 실행 결과 `/tmp/fragment.cfg` 지점이 생성됩니다.
2. **레시피 업데이트**:
   - `meta-rpi3/recipes-kernel/linux/linux-raspberrypi_%.bbappend` 파일을 생성하여 해당 설정을 반영합니다.

---

## 2. Driver Porting (Built-in & External Module)

### 🧩 Built-in Driver
커널 내부 레이어(`meta-raspberrypi`) 설정을 통해 빌트인 드라이버를 활성화합니다.
- **적용 레이어**: `meta-rpi3`
- **확인 방법**: 부팅 후 `dmesg | grep kernel` 또는 `zcat /proc/config.gz` 확인

### 📦 Module Driver (hello-mod)
공범 프로젝트 공용 레이어(`meta-product`)에 위치한 커널 모듈을 사용합니다.
- **적용 레이어**: `meta-product/recipes-kernel/modules/hello-mod/`
- **레시피 상속**: `inherit module`
- **바이너리 위치**: `output/rpi3/build/tmp/work/raspberrypi3_64-poky-linux/hello-mod/0.1-r0/image/lib/modules/<kernel-version>/extra/hello.ko`
- **확인 방법**: `modprobe hello` -> `lsmod` 확인

---

## 3. Open Source & User Application Management

### ➕ 오픈소스 패키지 추가/삭제
배포판 구성 시 필요한 패키지를 추가하거나 불필요한 패키지를 제거합니다.
- **추가**: 이미지 레시피나 `kas-rpi3.yml`에 `IMAGE_INSTALL:append = " package-name"` (예: `python3`, `git` 등)

### 🚀 사용자 앱 (hello)
- **적용 레이어**: `meta-product/recipes-app/hello/` (공용 이전 완료)
- **바이너리 빌드 위치**: `output/rpi3/build/tmp/work/cortexa53-poky-linux/hello/1.0-r0/image/usr/bin/hello`
- **이미지 통합**: `kas/rpi3/kas-rpi3.yml`에서 `IMAGE_INSTALL:append = " hello"` 활성화 확인

---

## 4. 빌드 경로 가이드 (WORKDIR & Deploy)

빌드 과정에서 생성되는 중간 결과물과 최종 배포 파일의 위치입니다.

### 🏗️ 중간 빌드 디렉토리 (`WORKDIR`)
`manifest/output/rpi3/build/tmp/work/`

| 구분 | 상대 경로 예시 | 주요 내용 |
| :--- | :--- | :--- |
| **Kernel** | `raspberrypi3_64-poky-linux/linux-raspberrypi/<version>/` | RPI3 커널 소스 및 `.config` |
| **Module** | `raspberrypi3_64-poky-linux/hello-mod/<version>/` | `hello.ko` 커널 모듈 바이너리 |
| **App** | `cortexa53-poky-linux/hello/<version>/` | `hello` 실행 파일 생성 위치 |

### 🚀 최종 결과물 및 이미지 (`DEPLOY_DIR_IMAGE`)
`manifest/output/rpi3/build/tmp/deploy/images/raspberrypi3-64/`

| 파일 구분 | 파일명 예시 (Symlink 활용) | 설명 |
| :--- | :--- | :--- |
| **SD Image** | `product-test0-raspberrypi3-64.wic.bz2` | **실제 SD 카드에 구울 최종 이미지** |
| **BMap File** | `product-test0-raspberrypi3-64.wic.bmap` | `bmaptool`용 고속 기록 메타데이터 |
| **Kernel** | `Image` | `aarch64` 커널 이미지 바이너리 |
| **Full RootFS** | `product-test0-raspberrypi3-64.tar.bz2` | 전체 파일시스템 압축본 |

---

> [!TIP]
> **실제 구동 확인**: 부팅 후 `root` 로그인(비밀번호 없음)을 하여 `/usr/bin/hello` 명령어를 실행해 보세요. "Hello, AI Agent Distro!"가 출력되면 포팅 및 설치가 완벽히 성공한 것입니다.
