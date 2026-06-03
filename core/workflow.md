# Core AI Coding Workflow

This workflow is independent of any specific AI coding tool.

1. Read the project entrypoint and configured core docs.
2. Read behavior sources before behavior-changing work.
3. State a short plan before implementation.
4. Write or update the smallest focused test for the required behavior.
5. Run the focused test and confirm it fails for the expected reason. This is
   the red step.
6. Implement the smallest coherent change needed to pass that test.
7. Run the same focused test and confirm it passes. This is the green step.
8. Run configured verification.
9. Review the diff and summarize user-visible behavior, tests, and risks.

## Requirements First

For behavior changes, align specs, requirements, or accepted task artifacts
before implementation. If the repository uses OpenSpec, OpenSpec plus the
project app spec is the behavior source of truth.

## Plan Before Implementation

The plan should be short and specific enough to review. Update it if discovery
changes the approach.

## Verify Before Done

Use `harness/scripts/verify.sh` from the repository root. If a configured check
is unavailable, the verify output must explain what is missing.

## Red-Green TDD

For behavior changes, implementation must not start until a focused failing test
has been added or updated and run. The failing result must match the behavior
gap being addressed. After implementation, rerun the same focused test to show
the red test has turned green before running broader verification.
