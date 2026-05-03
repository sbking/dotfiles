# Global Agent Notes

Prefer source-backed answers when practical. For tools we rely on, keep local
reference clones under `~/Projects/refs/github.com/<owner>/<repo>` so agents can
read upstream source and docs directly instead of guessing from stale search
results.

For code changes, prefer small stacked branches that are independently
reviewable. Treat stacking as a coordination protocol: each branch should carry
one coherent idea, have an explicit parent, and be easy for humans or agents to
review, revise, rebase, and merge.
