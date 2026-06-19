# AI Coding Harness

This directory contains a tool-independent AI coding harness for this repository.
It separates reusable policy from project configuration and tool-specific
adapters.

## Structure

- `harness/core/` contains reusable rules, workflow, and quality gate policy.
- `harness/templates/` contains generated entrypoint templates for different AI
  tools.
- `harness/adapters/` documents tool-specific behavior for Codex, Claude, Cursor,
  and future integrations.
- `harness/scripts/` contains repo-root runnable helper scripts.
- `harness/examples/` contains a reusable `harness.yml` starting point.
- `harness.yml` at the repository root is the project-specific configuration.

## Current Project Mapping

This repository keeps existing shared project rules in `docs/ai/*` and existing
checks in `scripts/ai/*`. The harness references those files instead of
duplicating their implementation.

Claude-specific compatibility files are intentionally isolated in `CLAUDE.md`
and `.claude/*`. Core harness files do not depend on Claude.

## Usage

From the repository root:

```bash
./harness/scripts/preflight.sh
./harness/scripts/verify.sh
./harness/scripts/generate-agent-files.sh
./harness/scripts/diff-review.sh
```

`preflight.sh` validates harness structure, configured docs, templates, and
configured commands.

`verify.sh` runs preflight and each command listed under `checks.verify` in
`harness.yml`. If a project check skips because a tool is unavailable, the
underlying check is responsible for explaining the skip.

`generate-agent-files.sh` renders `AGENTS.md` by default. Use
`--adapter claude`, `--adapter codex-full`, `--adapter cursor`,
`--adapter copilot`, or `--all` to render additional adapter outputs from the
same sources.

Use `--adapter claude-full` to render the complete Claude surface from harness
templates: `CLAUDE.md`, `.claude/settings.json`, `.claude/hooks`,
`.claude/constraints`, `.claude/commands/opsx`, and `.claude/skills`.

Use `--adapter codex-openspec` to generate the Codex-facing OpenSpec workflow
reference at `harness/generated/codex/openspec-workflows.md`.

Use `--adapter codex-full` to render the Codex hook surface from harness
templates: `.codex/hooks.json` and `.codex/hooks`.

`diff-review.sh` prints a compact status and diff summary suitable for final AI
responses or human review.

## Reuse In Other Repositories

Use a Git submodule as the default integration method. A submodule keeps the
shared harness pinned to an explicit upstream commit while making updates
reviewable across repositories.

Recommended setup:

```bash
git submodule add git@github.com:meltzow/ai-coding-harness.git harness
git commit -m "Add AI coding harness submodule"
```

After adding the submodule, install the repo-local harness surface:

1. Create a root `harness.yml` from `harness/examples/harness.yml.example`.
2. Replace the example `project.name`, `behavior_sources`, and
   `checks.verify` entries with paths that exist in the consuming repository.
3. Add project-local check scripts such as `scripts/ai/quality-gates.sh`,
   `scripts/ai/tdd-check.sh`, `scripts/ai/security-secrets.sh`, and
   `scripts/ai/security-vuln.sh` when the selected adapters reference them.
4. Generate adapter outputs from the repository root:

   ```bash
   ./harness/scripts/generate-agent-files.sh --all
   ```

5. Run the complete configured verification flow:

   ```bash
   ./harness/scripts/verify.sh
   ```

6. Commit the project-local files, generated adapter outputs, `.gitmodules`, and
   the `harness` gitlink update in the consuming repository.

Keep these parts project-specific in the consuming repository:

- Root `harness.yml`
- Existing project docs referenced by `harness.yml`
- Existing project-specific check scripts
- Generated adapter outputs such as `AGENTS.md` or `CLAUDE.md`

For repositories that cannot use submodules, the reusable harness parts can be
packaged or vendored instead: `harness/core`, `harness/templates`,
`harness/scripts`, `harness/adapters`, and `harness/examples`. Keep repo-specific
commands and file paths in `harness.yml` so the core remains portable.

## AI Install Prompts

Use one of these prompts when asking an AI coding agent to install the harness in
a repository.

For a new repository with no harness yet:

```text
Install git@github.com:meltzow/ai-coding-harness.git as a Git submodule at
harness/. Add a repo-specific harness.yml from the example, wire it to the
existing project docs and verification commands, generate all adapter outputs,
run ./harness/scripts/verify.sh, and leave unrelated working tree changes
untouched.
```

For a repository where `harness/` already exists:

```text
Install the new harness from the harness directory. Treat harness/ as the shared
harness source, create or update the root harness.yml for this repository,
generate the adapter outputs with ./harness/scripts/generate-agent-files.sh
--all, add any missing scripts/ai check wrappers required by the generated
hooks, run ./harness/scripts/verify.sh, and keep unrelated local changes
untouched.
```

For an update to a newer harness commit:

```text
Update the harness submodule to the current upstream main branch, regenerate
repo-local adapter outputs, update harness.yml only if the new harness requires
it, run ./harness/scripts/verify.sh, and keep the submodule commit separate from
unrelated project changes.
```

## Design Rules

- Core is tool-independent.
- Project config lives in `harness.yml`.
- Tool-specific output lives in templates and adapters.
- Existing Claude files may be analyzed and wrapped, but not required by core.
- Scripts must run from the repository root and avoid hardcoded absolute paths.
- Claude's local permission file `.claude/settings.local.json` is intentionally
  not templated because it is user-local runtime state rather than portable
  project policy.

## Open TODOs

- Add a richer YAML parser if nested command metadata becomes necessary.
- Add an install/update command for sharing the harness across repositories.
- Add optional generated hook templates for additional tools if desired.
- Add CI examples for repositories that do not already have their own checks.
