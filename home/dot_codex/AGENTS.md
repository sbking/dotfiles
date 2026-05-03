# Global Agent Notes

## Source-Backed Answers

Prefer source-backed answers when practical. For tools we rely on, keep local
reference clones under `~/Projects/refs/github.com/<owner>/<repo>` so agents can
read upstream source and docs directly instead of guessing from stale search
results.

## Think Stackly

As agents make code generation cheap and massively parallel, the hard part
becomes safely understanding, reviewing, integrating, deploying, and operating
change. Stacked workflows address that by decomposing work into atomic changes
with clear intent, then arranging them by dependency, sequence, and
deployability.

Smallness is not the goal; separability and reviewable intent are. If a change
can live independently, default to splitting unless there is a strong reason not
to. Intent is the identity of a change; diffs, commits, branches, PRs, and
descriptions are mutable carriers.

PR review is a synchronization mechanism. Stacked workflows reduce global lock
contention by preserving causality and optionality: each accepted change creates
a better base for the next change.

Deployments and environments are first-class parts of the change graph. Safe
rollout often requires phased stacks such as expand/coexist/migrate/contract,
feature-flag/canary/rollout/cleanup, or other transitions where each phase
creates a safe base for the next.

## Stacked Change Practice

For code changes, prefer stacked branches that are independently reviewable.
Treat stacking as a coordination protocol: each branch should carry one coherent
intent, have an explicit parent, and be easy for humans or agents to review,
revise, rebase, deploy, and merge.

When downstream work reveals that an earlier change is not quite right, update
the earliest change whose intent requires the fix instead of adding a compensating
patch above it. Then restack and revalidate descendants so newer understanding
propagates through the stack.
