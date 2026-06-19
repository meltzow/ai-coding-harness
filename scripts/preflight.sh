#!/usr/bin/env bash
set -euo pipefail

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

ROOT_DIR="$(repo_root)"
cd "$ROOT_DIR"

CONFIG="${HARNESS_CONFIG:-harness.yml}"

fail() {
  echo "preflight failed: $*" >&2
  exit 2
}

section_list() {
  local section="$1"
  awk -v section="$section" '
    $0 == section ":" { in_section=1; next }
    in_section && /^[^[:space:]#][^:]*:/ { exit }
    in_section && /^[[:space:]]*-[[:space:]]+/ {
      line=$0
      sub(/^[[:space:]]*-[[:space:]]+/, "", line)
      gsub(/^"|"$/, "", line)
      gsub(/^'\''|'\''$/, "", line)
      print line
    }
  ' "$CONFIG"
}

nested_list() {
  local parent="$1"
  local child="$2"
  awk -v parent="$parent" -v child="$child" '
    $0 == parent ":" { in_parent=1; next }
    in_parent && /^[^[:space:]#][^:]*:/ { exit }
    in_parent && $0 ~ "^[[:space:]]{2}" child ":" { in_child=1; next }
    in_child && /^[[:space:]]{2}[[:alnum:]_-]+:/ { exit }
    in_child && /^[[:space:]]{4}-[[:space:]]+/ {
      line=$0
      sub(/^[[:space:]]*-[[:space:]]+/, "", line)
      gsub(/^"|"$/, "", line)
      gsub(/^'\''|'\''$/, "", line)
      print line
    }
  ' "$CONFIG"
}

config_value() {
  local parent="$1"
  local key="$2"
  awk -v parent="$parent" -v key="$key" '
    $0 == parent ":" { in_parent=1; next }
    in_parent && /^[^[:space:]#][^:]*:/ { exit }
    in_parent && $0 ~ "^[[:space:]]{2}" key ":" {
      line=$0
      sub("^[[:space:]]{2}" key ":[[:space:]]*", "", line)
      gsub(/^"|"$/, "", line)
      gsub(/^'\''|'\''$/, "", line)
      print line
      exit
    }
  ' "$CONFIG"
}

echo "Running harness preflight..."

[ -f "$CONFIG" ] || fail "$CONFIG not found"
[ -d harness/core ] || fail "harness/core not found"
[ -d harness/templates ] || fail "harness/templates not found"
[ -d harness/scripts ] || fail "harness/scripts not found"
[ -d harness/adapters ] || fail "harness/adapters not found"

for required in \
  harness/core/rules.md \
  harness/core/workflow.md \
  harness/core/quality-gates.md \
  harness/core/openspec-workflows.md \
  harness/README.md \
  harness/templates/AGENTS.md.template \
  harness/templates/CLAUDE.md.template \
  harness/templates/claude/settings.json.template \
  harness/templates/codex/hooks.json.template \
  harness/templates/codex/commands/openspec.md.template \
  harness/templates/cursor-rules.template \
  harness/templates/copilot-instructions.template \
  harness/scripts/verify.sh \
  harness/scripts/preflight.sh \
  harness/scripts/test-codex-stop-check.sh \
  harness/scripts/test-spec-mode.sh \
  harness/scripts/init-repo.sh \
  harness/scripts/generate-agent-files.sh \
  harness/scripts/diff-review.sh
do
  [ -f "$required" ] || fail "$required not found"
done

while IFS= read -r path; do
  [ -n "$path" ] || continue
  [ -e "$path" ] || fail "configured behavior source not found: $path"
done < <(section_list behavior_sources)

while IFS= read -r path; do
  [ -n "$path" ] || continue
  [ -e "$path" ] || fail "configured core doc not found: $path"
done < <(section_list core_docs)

while IFS= read -r cmd; do
  [ -n "$cmd" ] || continue
  first_word="${cmd%% *}"
  if [[ "$first_word" == */* ]]; then
    [ -f "$first_word" ] || fail "configured verify command not found: $first_word"
  fi
done < <(nested_list checks verify)

SPEC_MODE="$(config_value spec mode)"
[ -n "$SPEC_MODE" ] || SPEC_MODE="optional"
case "$SPEC_MODE" in
  markdown|optional|openspec)
    ;;
  *)
    fail "unsupported spec.mode '$SPEC_MODE'; expected markdown, optional, or openspec"
    ;;
esac

if [ "$SPEC_MODE" = "openspec" ]; then
  [ -e app-spec.yaml ] || fail "spec.mode openspec requires app-spec.yaml"
  [ -d openspec ] || fail "spec.mode openspec requires openspec directory"
fi

bash -n harness/scripts/preflight.sh
bash -n harness/scripts/test-codex-stop-check.sh
bash -n harness/scripts/test-spec-mode.sh
bash -n harness/scripts/verify.sh
bash -n harness/scripts/init-repo.sh
bash -n harness/scripts/generate-agent-files.sh
bash -n harness/scripts/diff-review.sh
for hook_template in harness/templates/codex/hooks/*.sh.template; do
  bash -n "$hook_template"
done
"$ROOT_DIR/harness/scripts/test-codex-stop-check.sh"
"$ROOT_DIR/harness/scripts/test-spec-mode.sh"

echo "Harness preflight passed"
