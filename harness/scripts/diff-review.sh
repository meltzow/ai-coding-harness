#!/usr/bin/env bash
set -euo pipefail

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

ROOT_DIR="$(repo_root)"
cd "$ROOT_DIR"

echo "Git status:"
git status --short

echo
echo "Changed files:"
git diff --name-only
git diff --cached --name-only

echo
echo "Diff stat:"
git diff --stat
git diff --cached --stat

echo
echo "Review checklist:"
echo "- Requirements/specs updated if behavior changed"
echo "- Tests added or updated with real assertions"
echo "- Verification run and results recorded"
echo "- Security scan run or explicit skip/failure documented"
echo "- Large changes justified"
