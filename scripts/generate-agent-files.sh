#!/usr/bin/env bash
set -euo pipefail

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

ROOT_DIR="$(repo_root)"
cd "$ROOT_DIR"

CONFIG="${HARNESS_CONFIG:-harness.yml}"
ADAPTER="agents"

usage() {
  cat <<'USAGE'
Usage: harness/scripts/generate-agent-files.sh [--adapter agents|claude|claude-full|codex-full|codex-openspec|cursor|copilot] [--all]
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --adapter)
      ADAPTER="${2:-}"
      shift 2
      ;;
    --all)
      ADAPTER="all"
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

[ -f "$CONFIG" ] || {
  echo "generate failed: $CONFIG not found" >&2
  exit 2
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

bullet_list() {
  sed 's/^/- `/' | sed 's/$/`/'
}

PROJECT_NAME="$(config_value project name)"
[ -n "$PROJECT_NAME" ] || PROJECT_NAME="unknown-project"

CORE_DOCS="$(section_list core_docs | bullet_list)"
BEHAVIOR_SOURCES="$(section_list behavior_sources | bullet_list)"
VERIFY_COMMANDS="$(nested_list checks verify | bullet_list)"
GENERATED_NOTICE="Generated from harness.yml and harness/templates. Edit harness sources, then regenerate."

render() {
  local template="$1"
  local output="$2"
  local line

  [ -f "$template" ] || {
    echo "template not found: $template" >&2
    exit 2
  }

  mkdir -p "$(dirname "$output")"
  : > "$output"
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      *"{{CORE_DOCS}}"*)
        printf '%s\n' "$CORE_DOCS" >> "$output"
        ;;
      *"{{BEHAVIOR_SOURCES}}"*)
        printf '%s\n' "$BEHAVIOR_SOURCES" >> "$output"
        ;;
      *"{{VERIFY_COMMANDS}}"*)
        printf '%s\n' "$VERIFY_COMMANDS" >> "$output"
        ;;
      *)
        line="${line//\{\{PROJECT_NAME\}\}/$PROJECT_NAME}"
        line="${line//\{\{GENERATED_NOTICE\}\}/$GENERATED_NOTICE}"
        printf '%s\n' "$line" >> "$output"
        ;;
    esac
  done < "$template"

  echo "Generated $output"
}

generate_adapter() {
  case "$1" in
    agents)
      render "harness/templates/AGENTS.md.template" "AGENTS.md"
      ;;
    claude)
      render "harness/templates/CLAUDE.md.template" "CLAUDE.md"
      ;;
    claude-full)
      render "harness/templates/CLAUDE.md.template" "CLAUDE.md"
      render "harness/templates/claude/settings.json.template" ".claude/settings.json"
      render "harness/templates/claude/hooks/pre-push-trivy.sh.template" ".claude/hooks/pre-push-trivy.sh"
      render "harness/templates/claude/hooks/quality-gates.sh.template" ".claude/hooks/quality-gates.sh"
      render "harness/templates/claude/hooks/tdd-check.sh.template" ".claude/hooks/tdd-check.sh"
      render "harness/templates/claude/hooks/trivy-secrets.sh.template" ".claude/hooks/trivy-secrets.sh"
      render "harness/templates/claude/hooks/trivy-vuln.sh.template" ".claude/hooks/trivy-vuln.sh"
      render "harness/templates/claude/constraints/INDEX.md.template" ".claude/constraints/INDEX.md"
      render "harness/templates/claude/constraints/architecture.md.template" ".claude/constraints/architecture.md"
      render "harness/templates/claude/constraints/code-quality.md.template" ".claude/constraints/code-quality.md"
      render "harness/templates/claude/constraints/design-system.md.template" ".claude/constraints/design-system.md"
      render "harness/templates/claude/constraints/localization.md.template" ".claude/constraints/localization.md"
      render "harness/templates/claude/commands/opsx/apply.md.template" ".claude/commands/opsx/apply.md"
      render "harness/templates/claude/commands/opsx/archive.md.template" ".claude/commands/opsx/archive.md"
      render "harness/templates/claude/commands/opsx/explore.md.template" ".claude/commands/opsx/explore.md"
      render "harness/templates/claude/commands/opsx/propose.md.template" ".claude/commands/opsx/propose.md"
      render "harness/templates/claude/skills/openspec-apply-change/SKILL.md.template" ".claude/skills/openspec-apply-change/SKILL.md"
      render "harness/templates/claude/skills/openspec-archive-change/SKILL.md.template" ".claude/skills/openspec-archive-change/SKILL.md"
      render "harness/templates/claude/skills/openspec-explore/SKILL.md.template" ".claude/skills/openspec-explore/SKILL.md"
      render "harness/templates/claude/skills/openspec-propose/SKILL.md.template" ".claude/skills/openspec-propose/SKILL.md"
      chmod +x .claude/hooks/pre-push-trivy.sh .claude/hooks/quality-gates.sh .claude/hooks/tdd-check.sh .claude/hooks/trivy-secrets.sh .claude/hooks/trivy-vuln.sh
      ;;
    codex-openspec)
      render "harness/templates/codex/commands/openspec.md.template" "harness/generated/codex/openspec-workflows.md"
      ;;
    codex-full)
      render "harness/templates/codex/hooks.json.template" ".codex/hooks.json"
      render "harness/templates/codex/hooks/pre-push-trivy.sh.template" ".codex/hooks/pre-push-trivy.sh"
      render "harness/templates/codex/hooks/stop-check.sh.template" ".codex/hooks/stop-check.sh"
      render "harness/templates/codex/hooks/quality-gates.sh.template" ".codex/hooks/quality-gates.sh"
      render "harness/templates/codex/hooks/tdd-check.sh.template" ".codex/hooks/tdd-check.sh"
      render "harness/templates/codex/hooks/trivy-secrets.sh.template" ".codex/hooks/trivy-secrets.sh"
      render "harness/templates/codex/hooks/trivy-vuln.sh.template" ".codex/hooks/trivy-vuln.sh"
      chmod +x .codex/hooks/pre-push-trivy.sh .codex/hooks/stop-check.sh .codex/hooks/quality-gates.sh .codex/hooks/tdd-check.sh .codex/hooks/trivy-secrets.sh .codex/hooks/trivy-vuln.sh
      ;;
    cursor)
      render "harness/templates/cursor-rules.template" ".cursor/rules/ai-harness.md"
      ;;
    copilot)
      render "harness/templates/copilot-instructions.template" ".github/copilot-instructions.md"
      ;;
    *)
      echo "unknown adapter: $1" >&2
      exit 2
      ;;
  esac
}

if [ "$ADAPTER" = "all" ]; then
  generate_adapter agents
  generate_adapter claude-full
  generate_adapter codex-full
  generate_adapter codex-openspec
  generate_adapter cursor
  generate_adapter copilot
else
  generate_adapter "$ADAPTER"
fi
