#!/bin/bash

# 스크립트 위치 기준으로 프로젝트 루트 디렉토리(manifest)로 이동
cd "$(dirname "$0")/.." || exit 1
PROJECT_ROOT=$(pwd)

# 출력 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 커밋 메시지 설정 (인자가 없으면 기본 자동 메시지 사용)
COMMIT_MSG=${1:-"Auto-commit: update manifest/meta layers at $(date '+%Y-%m-%d %H:%M:%S')"}

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE} Starting Git Status & Interactive Push${NC}"
echo -e "${BLUE} Default Commit Message: \"$COMMIT_MSG\"${NC}"
echo -e "${BLUE}==================================================${NC}"

# 공통 Git 동기화 함수
sync_git_repo() {
    local target_dir="$1"
    local repo_name="$2"

    if [ ! -d "$target_dir" ] || [ ! -d "$target_dir/.git" ]; then
        return
    fi

    echo -e "\n${YELLOW}▶ Processing: $repo_name${NC}"
    cd "$target_dir" || return

    # 현재 브랜치 이름 확인
    BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [ -z "$BRANCH" ]; then
        echo -e "  ${RED}✗ No active branch detected (Detached HEAD?)${NC}"
        cd "$PROJECT_ROOT" || exit 1
        return
    fi
    echo "  Current Branch: $BRANCH"

    # 변경 사항(status) 검사
    CHANGES=$(git status --porcelain)

    if [ -z "$CHANGES" ]; then
        echo -e "  ${GREEN}✓ Clean (No changes)${NC}"
    else
        echo -e "  ${YELLOW}⚠ Changes detected in $repo_name:${NC}"
        echo -e "${BLUE}--------------------------------------------------${NC}"
        # git status 결과 전체 출력 (가독성을 위해 들여쓰기 처리)
        git status | sed 's/^/  /'
        echo -e "${BLUE}--------------------------------------------------${NC}"

        # 사용자에게 Commit & Push 확인 요청
        echo -e -n "  ${BLUE}Commit & Push these changes for $repo_name? (y/N): ${NC}"
        read -r confirm
        
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            # 1. 파일 추가/변경 사항 스테이징
            git add .

            # 2. 커밋 실행
            if git commit -m "$COMMIT_MSG"; then
                echo -e "  ${GREEN}✓ Committed successfully${NC}"
                
                # 3. 원격 저장소로 푸시
                echo "  Pushing to origin/$BRANCH..."
                if git push origin "$BRANCH"; then
                    echo -e "  ${GREEN}✓ Pushed successfully!${NC}"
                else
                    echo -e "  ${RED}✗ Push failed (check remote / conflict)${NC}"
                fi
            else
                echo -e "  ${RED}✗ Commit failed${NC}"
            fi
        else
            echo -e "  ${YELLOW}➔ Skipped $repo_name${NC}"
        fi
    fi

    # 안전하게 루트 디렉토리로 이동
    cd "$PROJECT_ROOT" || exit 1
}

# 1. manifest (루트 디렉토리) 처리
sync_git_repo "." "manifest"

# 2. meta-* 디렉토리 처리
for dir in meta-*; do
    if [ -d "$dir" ] && [ -d "$dir/.git" ]; then
        sync_git_repo "$dir" "$dir"
    fi
done

echo -e "\n${BLUE}==================================================${NC}"
echo -e "${BLUE} Process completed.${NC}"
echo -e "${BLUE}==================================================${NC}"
