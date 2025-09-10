#!/usr/bin/env bash
set -euo pipefail

# Git Report: Generate repository status and contributor info
echo "=== Git Report Generation ==="

OUT=./evidence/GIT_REPORT.md
mkdir -p ./evidence

REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "Not configured")
BRANCH=$(git branch --show-current 2>/dev/null || echo "No branch")

{
    echo "# Git Repository Report"
    echo
    echo "## Repository Info"
    echo "- **Remote URL:** $REMOTE_URL"
    echo "- **Current Branch:** $BRANCH"
    echo "- **Last Commit:** $(git log -1 --oneline 2>/dev/null || echo 'No commits')"
    echo "- **Repository Status:** $(git status --porcelain | wc -l | tr -d ' ') changes"
    echo
    echo "## Recent Commits"
    git log --oneline -10 2>/dev/null || echo "No commit history"
    echo
    echo "## Contributors"
    git shortlog -sn --no-merges 2>/dev/null || echo "No contributors"
    echo
    echo "## File Statistics"
    echo "- **Total Files:** $(find . -type f -not -path './.git/*' -not -path './data/*' -not -path './evidence/*' | wc -l | tr -d ' ')"
    echo "- **Lines of Code:** $(find . -name '*.json' -o -name '*.js' -o -name '*.sh' -o -name '*.md' -o -name '*.sql' | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}' || echo 'N/A')"
    echo
    echo "*Generated on: $(date)*"
} > "$OUT"

echo "Git report saved to $OUT"
