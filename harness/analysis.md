# Repository Harness Analysis

## Claude-Specific Files And Conventions

- `CLAUDE.md` is a Claude adapter that points to shared AI docs.
- `.claude/settings.json` configures Claude hooks for prompt context, pre-tool
  push checks, and stop-time validation.
- `.claude/hooks/*.sh` delegates to shared scripts under `scripts/ai/*`.
- `.claude/constraints/*.md` are compatibility adapters that point to
  `docs/ai/*`.
- `.claude/commands/opsx/*.md` contains Claude command UX for OpenSpec workflows.
- `.claude/skills/` exists for Claude-specific skills.

Reusable content from those files is the policy intent: shared docs and shared
checks own the rules. Claude-specific hook wiring remains adapter-only.

## Existing Build, Test, Lint, And Security Checks

- `scripts/ai/quality-gates.sh` runs Dart format checks, Flutter analyze, and
  Flutter tests.
- `scripts/ai/tdd-check.sh` enforces matching tests for selected provider/model
  paths under `lib/features`.
- `scripts/ai/security-secrets.sh` runs Trivy secret scanning when available.
- `scripts/ai/security-vuln.sh` scans `pubspec.lock` for high/critical
  dependency vulnerabilities when Trivy and the lockfile are available.
- `scripts/ai/pre-push-check.sh` composes the TDD, quality, secret, and
  vulnerability checks.
- `.githooks/pre-push` delegates to `scripts/ai/pre-push-check.sh`.

## Generalized Rules

- Requirements/specs first.
- Plan before implementation.
- Tests before or with implementation.
- Verify before done.
- Diff summary required.
- Secret/security scan before finalizing.
- Large changes require explicit justification.
- Tool-specific files are adapters, not canonical policy.

## Repo-Specific Rules

- OpenSpec plus `app-spec.yaml` are the behavior source of truth.
- Flutter/Dart checks are implemented by `scripts/ai/*`.
- Architecture follows the existing Flutter/Riverpod project structure and
  localization rules in `docs/ai/rules.md`.
- The current TDD path mapping is specific to this repository's `lib/features`
  and `test/features` layout.

## Claude Function Mapping

| Claude function | Files | Harness link | Codex link | Status |
| --- | --- | --- | --- | --- |
| Claude entrypoint | `CLAUDE.md` | Generated from `harness/templates/CLAUDE.md.template`; references `harness/core/*`, `docs/ai/*`, `app-spec.yaml`, `openspec`, and `harness/scripts/verify.sh`. | `AGENTS.md` is generated from `harness/templates/AGENTS.md.template` and references the same canonical sources. | Synced. |
| Prompt context hook | `.claude/settings.json` `UserPromptSubmit` | Generated from `harness/templates/claude/settings.json.template`; injects harness/core, docs/ai, OpenSpec, TDD, localization, and verify guidance. | Codex has no hook equivalent; the closest link is static instruction through `AGENTS.md`. | Claude generated; Codex static only. |
| Pre-tool push guard | `.claude/settings.json` `PreToolUse`, `.claude/hooks/pre-push-trivy.sh` | Generated from `harness/templates/claude/*`; hook delegates to `scripts/ai/security-secrets.sh`, which is also listed in `harness.yml` under `checks.verify`. | Codex has no automatic pre-tool hook. Codex is instructed through `AGENTS.md`/`harness/core/*` to run `harness/scripts/verify.sh`; no push interception exists. | Claude generated; shared underlying check. |
| Stop-time quality hooks | `.claude/settings.json` `Stop`, `.claude/hooks/quality-gates.sh`, `.claude/hooks/tdd-check.sh`, `.claude/hooks/trivy-secrets.sh`, `.claude/hooks/trivy-vuln.sh` | Generated from `harness/templates/claude/*`; each hook delegates to the shared scripts configured in `harness.yml`. | Codex is linked manually via `AGENTS.md` and `harness/scripts/verify.sh`; Codex does not run these automatically on stop. | Claude generated; shared checks synced. |
| Claude constraints | `.claude/constraints/*.md` | Constraints are compatibility adapters pointing to `docs/ai/*`; harness core now also references those docs and adds `harness/core/*`. | Codex reads `AGENTS.md`, which points to the same `docs/ai/*` and `harness/core/*`. | Synced at policy level. |
| OpenSpec command UX | `.claude/commands/opsx/*.md` | Generated from `harness/templates/claude/commands/opsx/*.template`; generalized workflow lives in `harness/core/openspec-workflows.md`. | Codex has generated reference `harness/generated/codex/openspec-workflows.md` and `AGENTS.md` points to core workflow docs. | Migrated to harness; Codex has non-slash-command equivalent. |
| OpenSpec skills | `.claude/skills/openspec-*` | Generated from `harness/templates/claude/skills/openspec-*`; generalized workflow lives in `harness/core/openspec-workflows.md`. | Codex has no native skill-file equivalent, but uses `harness/core/openspec-workflows.md` and generated Codex workflow reference. | Migrated to harness; Codex has documentation equivalent. |
| Claude local permissions | `.claude/settings.local.json` | Not linked to harness. This is local, user/tool-specific permission state and includes broad command/web/read allowances. | Codex has separate runtime permissions outside repo files; no mapping in harness. | Intentionally tool-local; do not put in core. |
| Hook cache | `.claude/hooks/.cache/*` | Not linked; transient cache. | No Codex link. | Ignore. |

## Codex Coverage Summary

Codex is currently linked to the harness through `AGENTS.md`, `harness/core/*`,
`docs/ai/*`, `harness.yml`, `harness/scripts/verify.sh`, and
`harness/generated/codex/openspec-workflows.md`.

Codex is not yet linked to Claude-specific automation surfaces:

- no automatic `UserPromptSubmit` equivalent,
- no automatic `PreToolUse` push guard,
- no automatic `Stop` hook execution,
- no native slash-command system equivalent to `/opsx:*`,
- no native skill-file system equivalent to Claude skills.

The shared checks, policies, and OpenSpec workflow content are synced. The
interactive/automatic Claude UX is represented for Codex as documented workflow,
not as runtime hooks.
