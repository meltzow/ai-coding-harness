#!/usr/bin/env bash
set -euo pipefail

HARNESS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

cd "$TMP_DIR"
ln -s "$HARNESS_DIR" harness
printf '# Test Repo\n' > README.md

./harness/scripts/init-repo.sh --spec-mode optional --no-generate
grep -q '^  mode: optional$' harness.yml

./harness/scripts/generate-agent-files.sh --adapter agents
grep -q 'Spec mode: optional' AGENTS.md
grep -q 'Use OpenSpec workflows only when an OpenSpec tree/change exists' AGENTS.md

./harness/scripts/init-repo.sh --spec-mode openspec --no-generate
grep -q '^  mode: openspec$' harness.yml
[ -f app-spec.yaml ]
[ -d openspec ]

./harness/scripts/generate-agent-files.sh --adapter agents
grep -q 'Spec mode: openspec' AGENTS.md
grep -q 'Use OpenSpec propose/apply/archive workflows' AGENTS.md

echo "Harness spec mode tests passed"
