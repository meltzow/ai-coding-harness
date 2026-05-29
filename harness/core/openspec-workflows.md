# OpenSpec Workflows

These workflows are tool-independent. Claude slash commands and skills, Codex
instructions, and future adapters should point here instead of owning separate
process rules.

## Explore

Use when requirements, scope, risks, or design options are unclear.

- Read relevant existing code and OpenSpec artifacts.
- Do not implement product code while exploring.
- Capture decisions in proposal, design, specs, or tasks when the user asks.
- Surface tradeoffs, risks, and unknowns before recommending a path.

## Propose

Use when starting a new behavior-changing change.

- Derive or ask for a kebab-case change name.
- Create the OpenSpec change with the project OpenSpec CLI.
- Generate required artifacts in dependency order.
- Read completed dependency artifacts before creating the next artifact.
- Stop when the change is apply-ready.

## Apply

Use when implementing an existing OpenSpec change.

- Select the target change explicitly or infer it only when unambiguous.
- Read `openspec status --change "<name>" --json`.
- Read `openspec instructions apply --change "<name>" --json`.
- Read all listed context files before editing code.
- Implement pending tasks in small steps.
- Mark task checkboxes complete immediately after each completed task.
- Pause if the task is unclear, design is invalidated, or a blocker appears.

## Archive

Use when finalizing a completed OpenSpec change.

- Select the change explicitly.
- Check artifact and task completion.
- Warn and confirm before archiving incomplete work.
- Assess delta spec sync before moving the change.
- Archive to `openspec/changes/archive/YYYY-MM-DD-<change-name>/`.
- Report archive path, schema, sync status, and any warnings.

## Adapter Notes

- Claude exposes these workflows as `.claude/commands/opsx/*` and
  `.claude/skills/openspec-*`.
- Codex exposes the same workflows through `AGENTS.md` and
  `harness/adapters/codex.md`.
- Core policy is in this file plus `harness/core/workflow.md`; adapter files may
  add tool-specific UX only.
