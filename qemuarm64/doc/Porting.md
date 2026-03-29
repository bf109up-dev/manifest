# 포팅 및 패키지 관리 종합 가이드 (Scarthgap)

이 문서는 `qemuarm64` 타겟 시스템에 드라이버, 커널 모듈, 전용 어플리케이션을 포팅하고 배포판(Distro)의 패키지 구성을 최적화하는 절차를 기술합니다.

---

## 1. Kernel Configuration & Customization
Yocto의 `linux-yocto` 커널 설정을 변경하고 영구적으로 반영하는 정석 절차입니다.

### 🛠️ `menuconfig`를 활용한 동적 설정
1. **설정 도구 호출**:
   ```bash
   # KAS 환경 내에서 커널 설정 도구 실행
   KAS_BUILD_DIR=machine/qemuarm64/build kas shell manifest/qemuarm64/kas-qemuarm64.yml -c "bitbake -c menuconfig linux-yocto"
   ```
2. **설정 변경**: 필요한 옵션(예: `CONFIG_I2C_STUB`)을 활성화한 후 저장합니다.

### 💾 설정 내용 영구 반영 (`diffconfig`)
1. **변경분 추출**:
   ```bash
   KAS_BUILD_DIR=machine/qemuarm64/build kas shell manifest/qemuarm64/kas-qemuarm64.yml -c "bitbake -c diffconfig linux-yocto"
   ```
   * 실행 결과 `/tmp/fragment.cfg` 지점이 생성됩니다.
2. **레시피 업데이트**:
   - `meta-qemuarm64/recipes-kernel/linux/linux-yocto_%.bbappend` 파일을 생성(또는 수정)합니다.
   - 추출된 `fragment.cfg` 파일의 내용을 `defconfig`에 병합하거나 별도 파일로 추가합니다.

---

## 2. Driver Porting (Built-in & External Module)

### 🧩 Built-in Driver (i2c-dummy)
내장형 드라이버는 커널 이미지(`Image`) 내부에 직접 포함됩니다.
- **적용 레이어**: `meta-qemuarm64/recipes-kernel/linux/`
- **핵심 설정**: `defconfig` 파일에 `CONFIG_I2C_STUB=y`를 추가합니다. (빌트인 장치로 인식됨)
- **확인 방법**: 부팅 후 `dmesg | grep i2c` 실행 시 관련 초기화 메시지가 나타납니다.

### 📦 Module Driver (hello-mod)
외부 커널 모듈은 필요할 때 로드/언로드할 수 있는 `.ko` 파일 형태로 생성됩니다.
- **적용 레이어**: `meta-qemuarm64/recipes-kernel/hello-mod/`
- **레시피 상속**: `inherit module`
- **바이너리 위치**: `tmp/work/qemuarm64-poky-linux/hello-mod/0.1-r0/image/lib/modules/<kernel-version>/extra/hello.ko`
- **확인 방법**: `modprobe hello` -> `lsmod` 확인

---

## 3. Open Source & User Application Management

### ➕ 오픈소스 패키지 추가/삭제
배포판 구성 시 필요한 패키지를 추가하거나 불필요한 패키지를 제거합니다.
- **추가**: 이미지 레시피나 `local.conf`에 `IMAGE_INSTALL:append = " package-name"` (예: `python3`, `git` 등)
- **삭제**: `IMAGE_INSTALL:remove = " package-name"` (가장 확실한 방법)

### 🎚️ 이미지 수준 기능 제어 (`IMAGE_FEATURES`)
패키지 단위보다 더 큰 단위(기능 그룹)로 관리하여 용량을 최적화하거나 디버그 기능을 통합합니다.
- **기능 추가 예시**: `IMAGE_FEATURES += "ssh-server-openssh tools-debug"`
- **기능 그룹 삭제**: `IMAGE_FEATURES:remove = "ssh-server-dropbear"` (SSH 등 특정 기능 통합 해제 시 사용)

### 🚀 사용자 앱 (hello-app)
- **적용 레이어**: `meta-qemuarm64/recipes-app/hello/`
- **바이너리 빌드 위치**: `tmp/work/cortexa57-poky-linux/hello/1.0-r0/image/usr/bin/hello`
- **이미지 통합**: `product-test0.bb` 이미지 레시피에 `IMAGE_INSTALL += "hello"` 추가

---

## 4. 빌드 경로 가이드 (WORKDIR & Deploy)

빌드 과정에서 생성되는 중간 결과물과 최종 배포 파일의 위치입니다.

### 🏗️ 중간 빌드 디렉토리 (`WORKDIR`)
각 레시피의 소스 및 컴파일 결과물은 아래 경로에서 확인할 수 있습니다. (프로젝트 루트 기준)
`scarthgap/machine/qemuarm64/build/tmp/work/`

| 구분 | 상대 경로 예시 | 주요 내용 |
| :--- | :--- | :--- |
| **Kernel** | `qemuarm64-poky-linux/linux-yocto/<version>/` | 커널 소스 및 `.config` 파일 |
| **Module** | `qemuarm64-poky-linux/hello-mod/<version>/` | `hello.ko` 바이너리 생성 위치 |
| **App** | `cortexa57-poky-linux/hello/<version>/` | `hello` 실행 파일 생성 위치 |

> [!TIP]
> **컴파일 결과 확인**: 각 경로 하위의 `image/` 폴더는 최종 루트 파일시스템에 복사되기 직전의 파일 구조를 그대로 담고 있습니다.

### 🚀 최종 결과물 및 이미지 (`DEPLOY_DIR_IMAGE`)
모든 빌드가 성공하면 최종 결과물은 아래 경로에 전개(Deploy)됩니다:
`scarthgap/machine/qemuarm64/build/tmp/deploy/images/qemuarm64/`

| 파일 구분 | 파일명 예시 (Symlink 활용) | 설명 |
| :--- | :--- | :--- |
| **Kernel** | `Image` | `aarch64` 커널 이미지 바이너리 |
| **Full RootFS** | `product-test0-qemuarm64.rootfs.tar.bz2` | 전체 파일시스템 압축본 |
| **Disk Image** | `product-test0-qemuarm64.rootfs.ext4` | QEMU 부팅용 가상 디스크 이미지 |
| **QEMU Config** | `product-test0-qemuarm64.rootfs.qemuboot.conf` | `runqemu` 실행 설정 파일 |

---

> [!TIP]
> **Porting Verification**: 부팅 후 `root` 로그인(비밀번호 없음)을 하여 `/usr/bin/hello` 명령어를 실행해 보세요. "Hello, AI Agent Distro!"가 출력되면 포팅 및 설치가 완벽히 성공한 것입니다.
