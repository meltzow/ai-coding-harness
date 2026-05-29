# Core AI Coding Rules

These rules are tool-independent. They apply to Codex, Claude, Cursor, Copilot,
and future adapters.

## Source Of Truth

- Read the configured behavior sources before changing behavior.
- Update requirement/spec artifacts before behavior-changing implementation.
- Keep project-specific rule files as inputs, not hard dependencies in core.

## Scope Control

- Work in small, reviewable steps.
- Keep changes focused on the requested behavior.
- Do not mix unrelated refactors with feature or bug-fix work.
- Large or cross-cutting changes require an explicit reason in the plan or diff
  summary.

## Implementation Quality

- Prefer the repository's existing architecture, naming, and helper APIs.
- Add abstractions only when they reduce real complexity or match established
  project patterns.
- Keep generated artifacts committed when the project expects them.
- Do not leave debug output, placeholder code, or TODO-only implementation.

## Testing

- Tests are required before or alongside implementation.
- Placeholder tests are not acceptable. Tests must assert real behavior.
- If a test cannot be added, document the reason and residual risk.

## Security

- Never commit secrets, tokens, credentials, or private keys.
- Run the configured secret scan before finalizing implementation.
- Dependency vulnerability findings must be fixed or explicitly risk-accepted.

## Final Response

- Include a concise diff summary.
- Mention which verification commands ran and whether any checks were skipped or
  failed.
- Call out open TODOs and risks that remain.
