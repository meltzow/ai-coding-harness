# Core Quality Gates

The harness supports these gates through `harness.yml` and project scripts:

- Requirements first
- Plan before implementation
- Tests before or with implementation
- Verify before done
- Diff summary required
- Security/basic secret scan
- No large changes without explicit justification

## Gate Mapping

Core defines the gates. `harness.yml` maps them to project-specific files and
commands. Adapters may render tool-specific instructions, but they must not own
canonical policy.

## Expected Command Flow

- `harness/scripts/preflight.sh` checks harness structure and configuration.
- `harness/scripts/verify.sh` runs preflight and configured project checks.
- `harness/scripts/diff-review.sh` prints a review-focused diff summary.
