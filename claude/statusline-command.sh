#!/bin/sh
# Claude Code status line
# Line 1: 📁 dir-basename  🌿 git-branch  🏷️ session-name
#   The session name is the peer-messaging name (e.g. "misc-a1") that other
#   sessions use with SendMessage. It is read from the session registry at
#   ~/.claude/sessions/<pid>.json, matched by .session_id from the payload
#   (falling back to $CLAUDE_PID). Omitted if it cannot be resolved.
#   The branch part (and its leading separator) is omitted entirely when the
#   current directory is not inside a git work tree.
# Line 2: 🤖 Model (effort)  🧠 Context: X%  ⏱️ 5h: Y%  📅 7d: Z%
#   The effort part is omitted when .effort.level is absent (the model does
#   not support the effort parameter).
#   Each usage segment (context window, 5-hour rate limit, 7-day rate limit)
#   is only shown when the corresponding field is actually present in the
#   status line JSON payload:
#     - .context_window.used_percentage   (null until the first API response)
#     - .rate_limits.five_hour.used_percentage  (only present for subscribers
#       with an active 5-hour window, after the first API response)
#     - .rate_limits.seven_day.used_percentage  (only present for subscribers
#       with an active 7-day window, after the first API response)
#   If a field is absent, its segment is silently omitted rather than guessed.

input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name')
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir')
effort=$(printf '%s' "$input" | jq -r '.effort.level // empty')

session_id=$(printf '%s' "$input" | jq -r '.session_id // empty')

dir_name=$(basename "$cwd")

session_name=""
sessions_dir="$HOME/.claude/sessions"
if [ -d "$sessions_dir" ]; then
  if [ -n "$session_id" ]; then
    session_name=$(jq -r --arg sid "$session_id" \
      'select(.sessionId == $sid) | .name // empty' \
      "$sessions_dir"/*.json 2>/dev/null | head -n 1)
  fi
  if [ -z "$session_name" ] && [ -n "$CLAUDE_PID" ] && [ -f "$sessions_dir/$CLAUDE_PID.json" ]; then
    session_name=$(jq -r '.name // empty' "$sessions_dir/$CLAUDE_PID.json" 2>/dev/null)
  fi
fi

branch=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

line1="📁 $dir_name"
if [ -n "$branch" ]; then
  line1="$line1  🌿 $branch"
fi
if [ -n "$session_name" ]; then
  line1="$line1  🏷️ $session_name"
fi

context_used=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
five_hour=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

line2="🤖 $model"
if [ -n "$effort" ]; then
  line2="$line2 ($effort)"
fi

if [ -n "$context_used" ]; then
  line2="$line2  🧠 $(printf '%.0f' "$context_used")%"
fi

if [ -n "$five_hour" ]; then
  line2="$line2  ⏱️ $(printf '%.0f' "$five_hour")%"
fi

if [ -n "$seven_day" ]; then
  line2="$line2  📅 $(printf '%.0f' "$seven_day")%"
fi

printf '%s\n%s\n' "$line1" "$line2"
