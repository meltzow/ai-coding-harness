# Codex OpenSpec Workflows - deck-ng

Codex does not use Claude slash commands, but it should follow the same OpenSpec
workflows.

Canonical workflow:

- `harness/core/openspec-workflows.md`
- `harness/core/workflow.md`
- `harness/core/rules.md`

Behavior sources:

- `app-spec.yaml`
- `openspec`

Equivalent Claude UX:

- `/opsx:explore` -> Explore workflow
- `/opsx:propose` -> Propose workflow
- `/opsx:apply` -> Apply workflow
- `/opsx:archive` -> Archive workflow

Before implementation, read the active OpenSpec artifacts. Before finishing, run
`./harness/scripts/verify.sh`.

Generated from harness.yml and harness/templates. Edit harness sources, then regenerate.
