# Wisenet Yocto Manifest

이 저장소는 `kas` 도구를 사용하여 Wisenet 프로젝트의 빌드 환경과 레이어를 관리합니다.
설정, 스크립트, 문서를 체계적으로 관리할 수 있도록 구조화되어 있습니다.

## 📂 디렉토리 구조
- **`kas/`**: 빌드 설정 파일 (`base`, `dev`, `prod`)
- **`scripts/`**: 호스트 설정 및 보드 관리 스크립트
- **`docs/`**: 상세 빌드 가이드 및 아키텍처 문서
- **`.github/`**: CI/CD 자동화 워크플로우

## 🚀 빌드 시작하기

### 1. 호스트 환경 설정 (최초 1회)
빌드에 필요한 의존성 패키지를 설치합니다.
```bash
./scripts/setup-host.sh
```

### 2. 이미지 빌드
`kas` 도구를 사용하여 원하는 환경의 이미지를 빌드합니다.

**개발용(Development) 빌드:**
```bash
kas build kas/wisenet-dev.yml
```

**운영용(Production) 빌드:**
```bash
kas build kas/wisenet-prod.yml
```

## 📖 상세 문서
더 자세한 정보는 `docs/` 디렉토리의 문서를 참고하세요:
- [빌드 가이드 (Build Guide)](docs/build-guide.md)
- [소프트웨어 아키텍처 (Software Architecture)](docs/architecture.md)
