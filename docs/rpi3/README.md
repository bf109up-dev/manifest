# Raspberry Pi 3 (64-bit scarthgap) Yocto Project Guide

본 저장소는 `kas` 툴을 활용하여 Raspberry Pi 3 타겟의 Headless Yocto 빌드 환경(`product-test0`)을 구축, 빌드하고 테스트하는 방법을 안내합니다.

---

## 🚀 1. 초기 빌드 (Initial Build)

아직 아무런 소스/캐시가 다운로드되지 않은 초기 상태에서 Yocto 전체 시스템을 빌드하는 방법입니다. 코어 수 제한을 두어 시스템 마비를 방지할 수 있습니다.

```bash
cd rpi3

# kas 패키지가 없다면 설치
pip3 install --user kas 

# 0~8 물리 코어만 사용하여 전체 시스템 빌드 실행 (Raspberry Pi 3 타겟)
taskset -c 0-8 ~/.local/bin/kas build kas-rpi3.yml

# QEMU ARM64 에뮬레이터 타겟 빌드 시
# taskset -c 0-8 ~/.local/bin/kas build kas-qemuarm64.yml
```

> **📌 진행 상황 로깅 & 모니터링 팁**
> 터미널에 빌드 과정을 계속 띄워두고 싶지 않다면, 백그라운드로 넘기고 로그로 뺄 수 있습니다.
> ```bash
> taskset -c 0-8 kas build kas-rpi3.yml:kas-rpi3-lock.yml > console-latest.log 2>&1 &
> tail -f console-latest.log
> ```
> *빌드가 다 끝나면 `rpi3/build/tmp/deploy/images/raspberrypi3-64/` 위치에 이미지 파일이 생성됩니다.* 

---

## ⚡ 2. 캐시 빌드 (Cache Build / Re-build)

Yocto 환경은 `rpi3/mirror/` 경로 하위에 소스 압축 파일(`downloads/`)과 빌드 인스턴스 결과물(`sstate-cache/`)을 별도로 보관합니다. 다른 PC나 컨테이너에서 이 폴더를 동기화한 뒤 동일하게 빌드를 누르면 95% 이상 캐시 히트가 터지며 빌드 시간이 파격적으로 줄어듭니다.

- **안전한 Lockfile 기반 재현 빌드**: 
  이전에 성공했던 완벽히 동일한 환경(Git 커밋 해시 고정)으로 캐시를 융합해서 빌드하고 싶다면, 원본과 `.lock` 파일을 콜론(`:`)으로 합쳐 실행합니다.
  ```bash
  taskset -c 0-8 kas build kas-rpi3.yml:kas-rpi3-lock.yml
  ```
  *(수정된 코드가 있다면 이 단계를 5분 이내에 끝내고 펌웨어 이미지를 재조립합니다.)*

---

## 💻 3. QEMU 가상 머신 테스트 (QEMU Emulation)

SD 카드에 굽기 전에 먼저 QEMU 유틸리티를 활용해서 시뮬레이션 환경에서 부팅과 프로그램 상태를 점검할 수 있습니다. 본 환경은 `kas-rpi3.yml`에 `IMAGE_CLASSES += "qemuboot"` 설정을 적용하여 곧바로 에뮬레이션 부팅이 가능합니다.

```bash
# kas shell에서 제공하는 runqemu 명령어를 통해 빌드된 이미지 부팅 실행
~/.local/bin/kas shell kas-qemuarm64.yml -c "runqemu nographic"
```

> **종료 방법**: QEMU 가상머신 테스트를 끝낼 때 커맨드 모드라면 `root` 로그인 후 `poweroff`를 입력하거나, `Ctrl+A` 누르고 `X`를 입력하면 가상머신 테스트가 즉시 종료됩니다.

---

## 💾 4. SD 카드 플래싱 (SD Fusing)

빌드가 완료된 최종 이미지를(확장자 `.wic.bz2`) 실제 Raspberry Pi 3 구동을 위해 SD 카드에 복사하는 단계입니다.
`rpi3/build/tmp/deploy/images/raspberrypi3-64/` 디렉토리를 참조합니다.

> ⚠️ [주의] 아래 명령어의 `/dev/sdX` 부분을 자신의 실제 SD 카드 마운트 드라이브명(`lsblk` 명령어로 확인. 예: `/dev/sdb`, `/dev/mmcblk0` 등)으로 정확하게 변경해야 합니다! 파티션 경로(`/dev/sdb1`)가 아니라 **디바이스 풀 경로(`/dev/sdb`)**를 써주세요.

### 옵션 A) 기본 방식: `dd` 명령어 사용 (가장 범용적)
Ubuntu 및 Mac 등 기본 내장 툴을 사용한 Fusing 방법입니다.
```bash
# bz2 압축을 풀면서 동시에 지정한 장치에 블록 단위로 기록
bzcat build/tmp/deploy/images/raspberrypi3-64/product-test0-raspberrypi3-64*.wic.bz2 | sudo dd of=/dev/sdX bs=4M status=progress

# 버퍼가 모두 디스크에 정상 쓰여졌는지 확인 (Sync)
sudo sync
```

### 옵션 B) 초고속 방식: `bmaptool` 사용 (권장)
Yocto 환경에서는 비어있는 디스크 공간을 건너뛰고 오직 기록된 파일만 전송하는 bmap 메타데이터 파일(`.wic.bmap`)을 함께 생성합니다. `dd` 명령어보다 10배 이상 빠르고 안전합니다.

```bash
# Ubuntu의 경우: sudo apt install bmap-tools 
sudo bmaptool copy build/tmp/deploy/images/raspberrypi3-64/product-test0-raspberrypi3-64*.wic.bz2 /dev/sdX
```

---
**유지보수 기록**
- 프로젝트 루트: `rpi3/`
- Target Board: Raspberry Pi 3 (`raspberrypi3-64`) & QEMU ARM64 (`qemuarm64`)
- Yocto Branch: `scarthgap`
- CPU Limits: `taskset -c 0-8` 및 `BB_NUMBER_THREADS="9"` 강제
