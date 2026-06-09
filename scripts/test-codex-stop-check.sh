#!/usr/bin/env bash
set -euo pipefail

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

ROOT_DIR="$(repo_root)"
cd "$ROOT_DIR"

fail() {
  echo "codex stop-check test failed: $*" >&2
  exit 1
}

[ -x .codex/hooks/stop-check.sh ] || fail ".codex/hooks/stop-check.sh is not executable"

PASSING_CHECK="$(mktemp "${TMPDIR:-/tmp}/codex-stop-pass.XXXXXX")"
FAILING_CHECK="$(mktemp "${TMPDIR:-/tmp}/codex-stop-fail.XXXXXX")"
STOP_ACTIVE_CHECK="$(mktemp "${TMPDIR:-/tmp}/codex-stop-active.XXXXXX")"
trap 'rm -f "$PASSING_CHECK" "$FAILING_CHECK" "$STOP_ACTIVE_CHECK"' EXIT

cat >"$PASSING_CHECK" <<'SH'
#!/usr/bin/env bash
echo "passing output should stay hidden"
exit 0
SH
chmod +x "$PASSING_CHECK"

cat >"$FAILING_CHECK" <<'SH'
#!/usr/bin/env bash
echo "focused failure"
exit 7
SH
chmod +x "$FAILING_CHECK"

cat >"$STOP_ACTIVE_CHECK" <<'SH'
#!/usr/bin/env bash
echo "still failing"
exit 9
SH
chmod +x "$STOP_ACTIVE_CHECK"

PASS_OUTPUT="$(printf '{}' | .codex/hooks/stop-check.sh "Passing check" "$PASSING_CHECK")"
[ -z "$PASS_OUTPUT" ] || fail "passing checks must not emit hook output"

FAIL_OUTPUT="$(printf '{}' | .codex/hooks/stop-check.sh "Focused check" "$FAILING_CHECK")"
export FAIL_OUTPUT
python3 - <<'PY'
import json
import os
import sys

payload = json.loads(os.environ["FAIL_OUTPUT"])
if payload.get("decision") != "block":
    sys.exit("missing top-level decision=block")
reason = payload.get("reason", "")
if "Focused check failed with exit code 7" not in reason:
    sys.exit("missing focused failure summary")
if "focused failure" not in reason:
    sys.exit("missing captured command output")
if "hookSpecificOutput" in payload:
    sys.exit("Stop hook decision must not be nested in hookSpecificOutput")
PY

ACTIVE_OUTPUT="$(printf '{"stop_hook_active":true}' | .codex/hooks/stop-check.sh "Active check" "$STOP_ACTIVE_CHECK")"
export ACTIVE_OUTPUT
python3 - <<'PY'
import json
import os
import sys

payload = json.loads(os.environ["ACTIVE_OUTPUT"])
if payload.get("decision") == "block":
    sys.exit("active stop hooks must not block again")
message = payload.get("systemMessage", "")
if "already active" not in message:
    sys.exit("missing active stop-hook system message")
PY

echo "Codex stop-check tests passed"
