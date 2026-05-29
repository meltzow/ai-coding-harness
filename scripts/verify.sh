#!/usr/bin/env bash
set -euo pipefail

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

ROOT_DIR="$(repo_root)"
cd "$ROOT_DIR"

CONFIG="${HARNESS_CONFIG:-harness.yml}"

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

[ -f "$CONFIG" ] || {
  echo "verify failed: $CONFIG not found" >&2
  exit 2
}

echo "Running harness verify..."
"$ROOT_DIR/harness/scripts/preflight.sh"

VERIFY_COMMANDS=()
while IFS= read -r cmd; do
  VERIFY_COMMANDS+=("$cmd")
done < <(nested_list checks verify)
if [ "${#VERIFY_COMMANDS[@]}" -eq 0 ]; then
  echo "No checks.verify commands configured in $CONFIG"
  exit 0
fi

for cmd in "${VERIFY_COMMANDS[@]}"; do
  [ -n "$cmd" ] || continue
  echo
  echo "Running: $cmd"
  bash -c "$cmd"
done

echo
echo "Harness verify passed"
