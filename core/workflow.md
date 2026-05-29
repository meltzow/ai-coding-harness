# Core AI Coding Workflow

This workflow is independent of any specific AI coding tool.

1. Read the project entrypoint and configured core docs.
2. Read behavior sources before behavior-changing work.
3. State a short plan before implementation.
4. Write or update tests before or with implementation.
5. Implement the smallest coherent change.
6. Run configured verification.
7. Review the diff and summarize user-visible behavior, tests, and risks.

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
