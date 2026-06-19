# Codex OpenSpec Workflows - anchestral

Codex does not use Claude slash commands, but it should follow the same OpenSpec
workflows.

Canonical workflow:

- `harness/core/openspec-workflows.md`
- `harness/core/workflow.md`
- `harness/core/rules.md`

Behavior sources:

- `app-spec.yaml`
- `openspec`
- `README.md`
- `docs/winahnen-nextcloud-mvp.md`
- `docs/winahnen-validation.md`
- `docs/nextcloud-development-environment.md`
- `docs/implementation-status.md`

Spec mode: openspec. Treat the configured OpenSpec artifacts and app spec as the active requirements/specification source. Use OpenSpec propose/apply/archive workflows for behavior-changing work.

Equivalent Claude UX:

- `/opsx:explore` -> Explore workflow
- `/opsx:propose` -> Propose workflow
- `/opsx:apply` -> Apply workflow
- `/opsx:archive` -> Archive workflow

Before implementation, read the active requirements/specification artifacts for
the configured spec mode. Before finishing, run `./harness/scripts/verify.sh`.

Generated from harness.yml and harness/templates. Edit harness sources, then regenerate.
