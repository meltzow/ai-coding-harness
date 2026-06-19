#!/usr/bin/env bash
set -euo pipefail

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

usage() {
  cat <<'USAGE'
Usage: harness/scripts/init-repo.sh [--spec-mode markdown|optional|openspec] [--no-generate]

Initializes or updates the repo-local harness.yml spec mode.

Spec modes:
  markdown  Use configured project docs as the active requirements/spec source.
  optional  Use configured project docs now; enable OpenSpec only when requested.
  openspec  Use app-spec.yaml plus openspec/ as the active spec source.
USAGE
}

ROOT_DIR="$(repo_root)"
cd "$ROOT_DIR"

CONFIG="${HARNESS_CONFIG:-harness.yml}"
SPEC_MODE=""
GENERATE=1

while [ "$#" -gt 0 ]; do
  case "$1" in
    --spec-mode)
      SPEC_MODE="${2:-}"
      shift 2
      ;;
    --no-generate)
      GENERATE=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
done

validate_spec_mode() {
  case "$1" in
    markdown|optional|openspec)
      ;;
    *)
      echo "init failed: unsupported spec mode '$1'" >&2
      echo "supported values: markdown, optional, openspec" >&2
      exit 2
      ;;
  esac
}

prompt_spec_mode() {
  cat <<'PROMPT'
Use OpenSpec for this repository?
  1) markdown - use project docs as requirements/spec sources
  2) optional - keep OpenSpec available, but inactive until requested
  3) openspec - initialize app-spec.yaml and openspec/ as active spec sources
PROMPT
  printf 'Select spec mode [1-3, default 2]: '
  read -r choice
  case "${choice:-2}" in
    1|markdown)
      SPEC_MODE="markdown"
      ;;
    2|optional)
      SPEC_MODE="optional"
      ;;
    3|openspec)
      SPEC_MODE="openspec"
      ;;
    *)
      echo "init failed: invalid selection '$choice'" >&2
      exit 2
      ;;
  esac
}

project_name() {
  basename "$ROOT_DIR"
}

write_default_config() {
  local name="$1"
  local mode="$2"
  local source_block

  case "$mode" in
    openspec)
      source_block="  - app-spec.yaml
  - openspec"
      ;;
    markdown|optional)
      source_block="  - README.md"
      ;;
  esac

  cat > "$CONFIG" <<EOF
project:
  name: $name
  description: Tool-independent AI coding harness configuration.

harness:
  version: 0.1.0
  root: harness
  agent_entrypoint: AGENTS.md

spec:
  mode: $mode
  app_spec: app-spec.yaml
  openspec_dir: openspec

behavior_sources:
$source_block

core_docs:
  - harness/core/rules.md
  - harness/core/workflow.md
  - harness/core/quality-gates.md
  - harness/core/openspec-workflows.md

checks:
  preflight:
    - harness/scripts/preflight.sh
  verify:
    - scripts/ai/tdd-check.sh
    - scripts/ai/quality-gates.sh
    - scripts/ai/security-secrets.sh
    - scripts/ai/security-vuln.sh

templates:
  agents: harness/templates/AGENTS.md.template
  claude: harness/templates/CLAUDE.md.template
  claude_full: harness/templates/claude
  codex_full: harness/templates/codex
  codex_openspec: harness/templates/codex/commands/openspec.md.template
  cursor: harness/templates/cursor-rules.template
  copilot: harness/templates/copilot-instructions.template

adapters:
  codex:
    output: AGENTS.md
    template: harness/templates/AGENTS.md.template
    hooks: harness/templates/codex/hooks.json.template
  claude:
    output: CLAUDE.md
    template: harness/templates/CLAUDE.md.template

policies:
  requirements_first: true
  plan_before_implementation: true
  red_green_tdd: true
  verify_before_done: true
  diff_summary_required: true
  security_secret_scan: true
  large_changes_require_reason: true
EOF
}

set_spec_mode() {
  local mode="$1"
  local tmp

  if grep -q '^spec:' "$CONFIG"; then
    tmp="$(mktemp)"
    awk -v mode="$mode" '
      $0 == "spec:" {
        print
        in_spec=1
        done=0
        next
      }
      in_spec && /^[^[:space:]#][^:]*:/ {
        if (!done) {
          print "  mode: " mode
          done=1
        }
        in_spec=0
      }
      in_spec && /^[[:space:]]{2}mode:/ {
        print "  mode: " mode
        done=1
        next
      }
      { print }
      END {
        if (in_spec && !done) {
          print "  mode: " mode
        }
      }
    ' "$CONFIG" > "$tmp"
    mv "$tmp" "$CONFIG"
  else
    {
      printf '\n'
      printf 'spec:\n'
      printf '  mode: %s\n' "$mode"
      printf '  app_spec: app-spec.yaml\n'
      printf '  openspec_dir: openspec\n'
    } >> "$CONFIG"
  fi
}

ensure_openspec_scaffold() {
  mkdir -p openspec/specs openspec/changes/archive
  if [ ! -f app-spec.yaml ]; then
    cat > app-spec.yaml <<EOF
app:
  name: $(project_name)
  description: TODO: describe the application behavior source of truth.

requirements:
  source: openspec
EOF
  fi
}

if [ -z "$SPEC_MODE" ]; then
  if [ -t 0 ]; then
    prompt_spec_mode
  else
    echo "init failed: --spec-mode is required when stdin is not interactive" >&2
    usage >&2
    exit 2
  fi
fi

validate_spec_mode "$SPEC_MODE"

if [ -f "$CONFIG" ]; then
  set_spec_mode "$SPEC_MODE"
  echo "Updated $CONFIG spec.mode to $SPEC_MODE"
else
  write_default_config "$(project_name)" "$SPEC_MODE"
  echo "Created $CONFIG with spec.mode $SPEC_MODE"
fi

if [ "$SPEC_MODE" = "openspec" ]; then
  ensure_openspec_scaffold
  echo "Initialized app-spec.yaml and openspec/ scaffold"
fi

if [ "$GENERATE" -eq 1 ]; then
  ./harness/scripts/generate-agent-files.sh --all
fi

echo "Harness repo initialization complete"
