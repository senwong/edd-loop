---
name: edd-loop
description: Evidence-driven autonomous development with a Developer and an independent Reviewer. Use when implementing a change that needs impact analysis, tests, regressions and repair/review cycles.
argument-hint: <feature or bug to implement and verify>
---

# EDD Loop: Developer → Independent Reviewer

Task: $ARGUMENTS

You (main Claude conversation) are the **Coordinator**. The required worker agents are named `edd-developer` and `edd-reviewer`. Read `references/protocol.md` next to this SKILL.md before starting, and follow its output contract.

## Invariants

- Use the Agent tool to invoke **two distinct non-fork custom subagents**. If either agent is missing/unavailable, report BLOCKED, not a simulated review.
- Run the Developer and Reviewer **serially**, never concurrently in the same working tree.
- In each round, start a **fresh `edd-reviewer`**. Do not resume a Developer or Reviewer conversation as Reviewer.
- Reviewer receives original user requirements, acceptance criteria, repository paths, baseline information, and current worktree; **do not pass Developer's report or conjectures until independent analysis is complete**.
- Require actual commands, outputs or reproducible runtime observations; static references alone do not establish runtime impact.
- Protect existing user changes. Never reset, discard, stage, commit, push, deploy, or touch secrets unless explicitly requested.
- Never claim success on missing evidence, missing tool access, or tests that were not run.

## Step 0 — establish contract

1. Read the user request. If $ARGUMENTS is empty, use the explicit feature request in the conversation. If neither exists, ask for the task.
2. Explore relevant repositories; capture `git rev-parse HEAD`, `git status --porcelain=v1 -uall`, and user changes. Treat untracked files and worktree changes as part of the code under review.
3. Define numbered, **testable** acceptance criteria (AC-1...). Identify baseline tests, affected entries, consumers, and existing failures.
4. Establish round=1, max_rounds=8. Before first edit, list protected pre-existing changes. Avoid unnecessary broad rewrites.

## Step 1 — Developer

Invoke Agent `edd-developer` with: original requirements, numbered ACs, repo paths, baseline / known user changes, and verified findings from the previous review (none in round 1).
Developer investigates execution paths, edits minimal code, runs related tests, and returns an Implementation Report with changed files, command/results, and remaining unknowns.
Wait for its completion before starting Reviewer. If it fails or can't be invoked, mark BLOCKED or retry if a transient tool failure can be resolved.

## Step 2 — independent Reviewer

Start a **new** Agent `edd-reviewer` with: original requirements, same ACs, code baseline and current repos, plus no Developer report.
Ask Reviewer to independently inspect **the real current worktree**, investigate run-time callers/consumers, execute representative tests and regressions, and return a structured Review Report.
On receiving the independent report, cross-check Developer's self-test record and reviewer findings yourself; any disputed finding requires new evidence and, if needed, another fresh review.

## Step 3 — gate

- PASS only if **all mandatory ACs** have evidence, appropriate target tests and regression checks passed, no P0/P1 findings remain, important blind spots are disclosed, and review covers the latest worktree.
- FAIL if there is a reproducible blocking defect. Assign finding IDs and pass the evidence to Developer for the next round.
- INCONCLUSIVE if there is insufficient evidence. Gather additional evidence or test coverage before declaring PASS. Never infer success from silence.
- BLOCKED if missing access, unavailable environments, permissions, or unresolved business assumptions prevent necessary progress; stop with actionable blockers.

## Step 4 — repeat or exit

After FAIL or a resolvable INCONCLUSIVE, rerun Step 1 with the specific verified findings, then start a **fresh** Step 2. A changed worktree invalidates the previous PASS.
Stop after eight rounds, or when the same blocking issue makes no progress for two rounds with no new evidence. Report INCOMPLETE rather than success.
No empty fix loops, fabricated tests, deletion of failing assertions, or unrequested scope expansion.

## Final output

Return: status (PASS / FAIL / INCONCLUSIVE / BLOCKED / INCOMPLETE), rounds, AC table with evidence, modified files, executed verification commands and exit codes, findings/resolutions, untested areas, and next steps.

Optional: Claude Code's `/goal` may keep the **outer conversation** pursuing the completion condition; this Skill defines the **inner workflow**. `/loop` is time-based scheduling, not a replacement for this immediate loop.

