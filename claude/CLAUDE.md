## Rules

- Think in English but speak in Japanese.
- Keep auto-memory to a minimum. Do not write a memory just because you were corrected; write one only when asked, or for facts that cannot be derived from the repository or skills.
- Never create a branch from a remote-tracking branch (e.g. `origin/develop`). Update the local base branch first (`git switch develop && git pull --ff-only`), then branch from the local one.
- Commit messages describe what changed and why. Never mention reviews or how the change came about (e.g. 「レビュー指摘に対応」「再レビュー対応」「review fixes」).
