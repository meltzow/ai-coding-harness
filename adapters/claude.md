# Claude Adapter

Claude-specific files may exist for compatibility, including `CLAUDE.md`,
`.claude/settings.json`, `.claude/hooks`, `.claude/commands`, and `.claude/skills`.

Canonical rules remain tool-independent:

- `harness/core/rules.md`
- `harness/core/workflow.md`
- `harness/core/quality-gates.md`
- Project docs listed in `harness.yml`

Claude hooks should delegate to shared project or harness scripts. Do not move
Claude-only hook behavior into `harness/core`.

Generated Claude adapter sources live under `harness/templates/claude/`:

- `settings.json.template`
- `hooks/*.template`
- `constraints/*.template`
- `commands/opsx/*.template`
- `skills/openspec-*/SKILL.md.template`

Use `./harness/scripts/generate-agent-files.sh --adapter claude-full` to render
the complete Claude surface from harness sources.
