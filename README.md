# Wisenet Yocto Manifest

이 저장소는 `kas` 도구를 사용하여 Wisenet 프로젝트의 빌드 환경과 레이어를 관리합니다.
설정, 스크립트, 문서를 체계적으로 관리할 수 있도록 구조화되어 있습니다.

## 📂 디렉토리 구조
- **`kas/`**: kas 빌드 설정 파일 (`kas-qemuarm64.yml`, 락 파일 등) 디렉토리
- **`meta-*/`**: `meta-product`, `meta-qemuarm64`, `meta-rauc` 등 커스텀 및 관련 Yocto 레이어 디렉토리
- **`poky/`**: Yocto/OpenEmbedded 코어 및 빌드 시스템 참조
- **`scripts/`**: 빌드 및 유지보수를 위한 자동화 스크립트 모음 (`build.sh`, `lock.sh`)
- **`docs/`**: 상세 빌드 가이드 및 아키텍처 문서
- **`output/`**: 빌드된 결과물 및 미러(다운로드, sstate-cache)가 저장되는 기본 디렉토리
- **`lock.md`**: 레이어 버전 및 락 정보에 대한 히스토리 문서

## 🚀 빌드 시작하기

### 지원 스크립트 (`scripts/`)
빌드 및 유지보수 편의를 위해 미리 작성된 스크립트를 제공합니다.

- **`scripts/build.sh`**: 
  - `kas` 환경에서 `qemuarm64` 머신을 대상으로 기본 빌드를 수행합니다. 내부적으로 락 파일(`kas-qemuarm64-lock.yml`)을 참조하여 일관된 빌드를 보장합니다.
- **`scripts/lock.sh`**:
  - 현재 빌드 환경에 대한 의존성 버전 해시(commit hash)를 고정하여 새로운 락 파일을 생성합니다. 생성된 파일은 날짜와 함께 저장되어 형상 관리에 유용합니다.

**빌드 실행 예시:**
```bash
./scripts/build.sh
```

## 🪞 미러(Mirror) 설정 가이드

Yocto 빌드 속도를 크게 향상시키기 위해 소스 코드 다운로드 미러와 SState 캐시 미러를 설정할 수 있습니다. 
기본 `kas-qemuarm64.yml` 파일 내에 아래와 같이 구성되어 있으며, 로컬 환경에 맞게 경로를 조정하여 사용할 수 있습니다.

```yaml
local_conf_header:
  qemuarm64_mirror: |
    # 로컬 다운로드 미러를 위해 own-mirrors 클래스 사용
    INHERIT += "own-mirrors"
    # 소스 tarball 로컬 경로 지정
    SOURCE_MIRROR_URL = "file:///path/to/your/mirror/downloads"
    # SState 캐시 미러 지정
    SSTATE_MIRRORS ?= "file://.* file:///path/to/your/mirror/sstate-cache/PATH"
```

위 설정을 통해 인터넷을 통해 소스 코드를 다시 다운로드하는 것을 방지하고 빌드 시간을 대폭 줄일 수 있습니다. 기본 설정상 빌드 및 미러 저장소는 `output/` 레이어 하의 경로가 잡혀있습니다.

## 🛠️ 유지보수 가이드

### 락(Lock) 파일 업데이트
레이어의 현재 커밋 상태를 락 파일에 강제로 업데이트하려면 제공된 스크립트를 실행합니다:
```bash
./scripts/lock.sh
```
실행 완료 시, 날짜가 포함된 버전이 생성되며, 이를 통해 이전 빌드 상태로 언제든 롤백 가능합니다. 추가 정보는 `lock.md`를 참고하세요.

## 📖 상세 문서
더 자세한 정보는 `docs/` 디렉토리의 문서를 참고하세요.
- [빌드 스크립트 (Build Script)](scripts/build.sh)
- [락 파일 업데이트 (Lock Script)](scripts/lock.sh)