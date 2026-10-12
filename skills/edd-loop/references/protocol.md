# EDD Loop Evidence Protocol

## Roles

- Coordinator: main conversation, owns ACs, baseline, round counter, handoffs and final verdict.
- Developer: changes code and runs self-checks. Cannot self-approve.
- Reviewer: **fresh non-fork subagent** with read/search/Bash tools; independently checks functional changes, consumers, regressions and test results. Does not intentionally edit sources.

## Revision identity

Before each review record `git rev-parse HEAD`, `git status --porcelain=v1 -uall` and a summary of `git diff HEAD` **for every involved repo**. New/untracked files are not included in git diff and must be read and reviewed separately.
After executing tests, capture status again. If source contents changed, require re-review of that newer state. Generated/ignored artifacts should be reported if material.
For robust evidence, include hashes or copies of changed/untracked source files when feasible. Never label `HEAD` alone as the reviewed revision if the tree is dirty.

## Acceptance matrix

| ID | Criterion | Status | Evidence |
| --- | --- | --- | --- |
| AC-1 | Observable behavior | PASS/FAIL/UNKNOWN | command / test / file:line / runtime output |

UNKNOWN is neither PASS nor failure; it blocks final PASS when the criterion is mandatory.

## Finding format

- `ID`: F-001, F-002...
- `Severity`: P0/P1 blocking; P2 nonblocking unless AC requires it.
- `Location`: path:line or concrete runtime entry.
- `Expected` and `Actual`: observable difference.
- `Evidence`: command, exact test failure, or trace with reproducible input.
- `Reproduce`: actionable steps.
- `Impact`: specifically affected consumer or path.
- `Status`: OPEN/RESOLVED/DISPUTED with later confirming evidence.

## Verification evidence

Every claimed check should include: exact command, execution context (repo, runtime/env where relevant), exit code, observed output/result, and the behavior it covers.
Distinguish assertion failure, environment failure, skipped check, baseline failure, and blocked access. Never convert unrun/failed checks to PASS.
For web UI, browser E2E, hardware, live services or multi-repo consumers, record what actually ran and what was only investigated.

## Independent review

Reviewer first receives original requirement, ACs and code state **without Developer's analysis or implementation summary**. Reviewer independently checks behavior and execution paths and returns a report.
Coordinator can then reconcile with Developer's separate report; disagreements get a new targeted reproduction, not a majority vote.

## Loop state machine

- `PASS`: all mandatory ACs evidenced, current worktree reviewed, no blocking findings.
- `FAIL`: reproducible mandatory behavioral mismatch or P0/P1 issue.
- `INCONCLUSIVE`: evidence incomplete; continue investigation when feasible.
- `BLOCKED`: tool, environment or business dependency cannot be resolved autonomously.
- `INCOMPLETE`: round/stall limit reached with unresolved items.

Max eight rounds; two consecutive rounds with no new relevant evidence or progress imply halt. No pseudo-progress rewrites.

