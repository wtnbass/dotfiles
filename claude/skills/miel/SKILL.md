---
name: miel
description: Coordinate the miel human review loop for code changes. Use this skill when the user explicitly asks to review changes with miel, wait for or monitor miel review events, address a submitted miel review, or continue until the review is approved or cancelled. Do not use it merely because the repository or project is named miel, the user mentions miel generally, or code changes are being made in miel.
---

# Miel review loop

Start this loop only when the user has explicitly asked to use miel for review or to monitor its review events.

Use miel's commands as the protocol boundary. Do not edit miel's XDG state, event files, review history, temporary cursor, or done marker directly.

1. Run `miel wait` and wait for the Markdown event on stdout.
2. Read the `miel-event` field in the frontmatter.
3. Handle the event:
   - `review`: address every applicable comment, run proportionate verification, then run `miel done --message "<summary and verification>" --wait`. Cite the stable `comment-N` identifiers from the review where useful. During this review response, do not stage or commit changes. Read the next event from the command's stdout and return to step 2.
   - `approved`: end the review loop. Do not stage or commit automatically; follow a later explicit user instruction if they want git operations.
   - `cancelled`: end the review loop because HEAD changed. Do not treat cancellation as approval.

Keep a long-running `miel wait` or `miel done --wait` process active when the tool runner yields before the command exits. Resume the same process with the longest supported wait interval. Do not relaunch the command, add `--timeout`, or poll with `miel review`. Avoid progress messages for empty polls unless the host requires them.

Use `miel review` only as a read-only fallback when blocking commands are unavailable. Never run `miel done` unless a `review` event is active and its requested changes and verification are complete. Keep the message concise, but include both what changed and what verification ran.
