#!/usr/bin/env bash
# blocked な agent の terminal に順番にフォーカスを移す
set -euo pipefail

t=$(
  herdr agent list | jq -r '
    .result.agents as $a
    | [$a[] | select(.agent_status == "blocked").terminal_id] as $b
    | [$a[] | select(.focused).terminal_id][0] as $f
    | if $b == []
      then empty
      else $b[((($b | index($f)) // -1) + 1) % ($b | length)]
      end
  '
)
if [ -n "$t" ]; then
  herdr agent focus "$t"
fi
