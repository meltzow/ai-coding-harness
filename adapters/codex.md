# Codex Adapter

Codex should use `AGENTS.md` as the entrypoint and then read the core docs listed
in `harness.yml`.

Adapter-specific notes:

- Use repository-local scripts from `harness.yml`.
- Keep implementation changes small and reviewable.
- Report verification results from `harness/scripts/verify.sh`.
- Use `harness/core/openspec-workflows.md` for the workflow equivalents of
  Claude `/opsx:*` commands and OpenSpec skills.
- Optional generated Codex command reference:
  `harness/generated/codex/openspec-workflows.md`.
