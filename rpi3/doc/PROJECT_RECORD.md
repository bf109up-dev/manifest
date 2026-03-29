# Raspberry Pi 3 (scarthgap) Yocto 빌드 환경 구축 기록

이 문서는 AI 환경 내에서 지금까지 사용자와 함께 구축하고 결정했던 모든 Yocto 빌드 과정과 아키텍처 설정 계획을 요약한 마크다운 기록입니다.

## 1. 프로젝트 기본 목표
- **타겟 머신**: `raspberrypi3-64` (Raspberry Pi 3)
- **GUI 여부**: Headless 전용 (`product-test0` 타겟 사용)
- **Yocto 브랜치**: `scarthgap`
- **구축 방식**: 시스템 패키지 매니저(`kas`) 파이썬 유틸리티를 통한 자동화(Configuration as Code)

## 2. 사용된 레이어 (Layers) 구조
Yocto의 안정적인 구동 및 의존성 해결을 위해 다음 세 가지 핵심 레이어를 `kas-rpi3.yml`을 통해 관리했습니다.
1. `poky` (기본 Yocto 레퍼런스 및 Bitbake 빌드 엔진)
2. `meta-openembedded` (Python, Networking, Multimedia 파편화된 필수 유틸리티 모음)
3. `meta-raspberrypi` (Broadcom 칩셋 및 RPI3 Board Support Package)

## 3. 발생했던 문제와 해결 과정 (Troubleshooting)

### 3.1. 라이선스 미동의 문제
- **증상**: 첫 빌드 시 의존성 트리 파싱 단계에서 `linux-firmware-rpidistro-bcm43455` 빌드 실패
- **조치**: Raspberry Pi Bluetooth/WIFI 통합 칩셋 전용 펌웨어 라이선스에 동의하기 위해, 설정 파일에 `LICENSE_FLAGS_ACCEPTED = "synaptics-killswitch"` 를 추가하여 해결.

### 3.2. CPU 자원 점유 최적화
- **요구사항**: 터미널 전체 및 호스트 PC 마비를 방지하기 위해 CPU를 0~8번 코어 이내로만 사용하도록 제한.
- **조치 (2중 방어망 구축)**:
  1. Yocto 측면: `BB_NUMBER_THREADS="9"`, `PARALLEL_MAKE="-j 9"` 를 주입.
  2. OS(Linux) 측면: `kas build` 실행 시 맨 앞에 `taskset -c 0-8` 명령어를 선언하여 프로세스 친화성(CPU Affinity)을 물리적으로 고정.

## 4. 미러 서버(Mirror) 통합 환경 조성
- **요구사항**: 빌드하면서 다운로드/생성되는 소스파일(Source) 및 SState 캐시 파일들을 자체적인 로컬 미러로 활용(다른 PC 재사용 및 공유 목적).
- **조치**:
  1. 파편화되었던 `build/downloads`와 `build/sstate-cache` 디렉토리를 상위 레벨인 `rpi3/mirror/` 폴더 하위로 완전히 분리/마이그레이션.
  2. `kas-rpi3.yml`에 `DL_DIR` 및 `SSTATE_DIR` 환경 변수를 해당 절대 경로로 수동 지정.
  3. 다른 HTTP 미러 서버에 곧바로 복사 및 업로드할 수 있도록 소스 파일을 tarball 압축 생성(`BB_GENERATE_MIRROR_TARBALLS = "1"`)하도록 옵션 활성화.

## 5. 실행의 재현성 보장 (Git ID Pinning / Lockfile)
- **요구사항**: `scarthgap` 브랜치가 향후 외부에서 업데이트되더라도 언제든 동일한 소스코드를 보장하여 안정적으로 빌드할 수 있는 완전 고정(Pinning) 환경 구성.
- **조치**: 현재 다운로드되어 파싱된 완전한 시점의 모든 Git Commit 해시값을 고정하는 `kas-rpi3-lock.yml` 파일을 자동 생성(`kas dump`). 언제든 외부 수정에 흔들리지 않고 재구성할 수 있습니다.

## 6. 빌드 실행 명령어 (참고용)
위의 모든 환경이 맞춰진 상태에서 최종적으로 실행되는 일반 최신화 빌드 커맨드는 다음과 같습니다.
```bash
cd /home/yang/work/yocto/ai-agent_test0/rpi3
taskset -c 0-8 ~/.local/bin/kas build kas-rpi3.yml
```
> 영원히 변하지 않는 고정된(Pinned) Git 해시 상태로 100% 동일한 성공적 재현을 보장하려면, 콜론(`:`)을 이용해 원본 파일과 Lock 파일을 함께 연결하여(`overrides` 적용) 빌드를 실행해야 합니다.
> ```bash
> taskset -c 0-8 ~/.local/bin/kas build kas-rpi3.yml:kas-rpi3-lock.yml
> ```

## 7. 완료 산출물 검증 위치 (빌드 성공 후)
SD 카드에 플래싱할 타겟 이미지(`.wic.bz2` 포맷)는 수 시간 빌드 완료 후 다음 경로에 생성됩니다.
`rpi3/build/tmp/deploy/images/raspberrypi3-64/product-test0-raspberrypi3-64*.wic*`

## 8. 디스크 용량 모니터링 및 예상 요구 사항 (Disk Usage)
Yocto 빌드는 특성상 소스 다운로드부터 로컬 통합 교차 컴파일 툴체인들을 전부 자체 구축하므로 막대한 디스크 공간이 필요합니다.
- **예상 최종 요구 용량**: `product-test0` 기기 타겟 기준 약 **40GB ~ 60GB**
- **모니터링 현황 점검 (최초 빌드 도중 7% 진행 기준)**: 
  - `build/`: 14GB (오브젝트 빌드 임시 파일, 툴체인 등)
  - `mirror/`: 4.9GB (Source 다운로드 타볼, 공용 SState Cache 등 통합 저장소)
  - 기타 레이어 소스: 0.5GB 미만
- (현재 빌드 서버의 구동 디스크 공간이 1.2TB 이상 넉넉히 남아있어 용량 부족으로 인한 실패 확률은 없음이 검증되었습니다.)
