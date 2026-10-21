#!/usr/bin/env bash
# レビュー用 worktree ランチャー
#   origin のリモートブランチを fzf で選び、herdr の worktree workspace として開く。
#   herdr の config.toml から popup コマンドとして呼ばれる想定（prefix+alt+r）。
set -uo pipefail

hold() { printf '\n続けるには何かキーを押してください...'; read -r -n1 _ </dev/tty || true; printf '\n'; }
die()  { printf '\n\033[31m%s\033[0m\n' "$*" >&2; hold; exit 1; }

command -v fzf >/dev/null || die "fzf が見つかりません"

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) \
  || die "git リポジトリ内で実行してください (cwd: $PWD)"

# linked worktree から呼ばれてもメイン checkout を基準にする（グループ化のため）
main_root=$(git -C "$repo_root" worktree list --porcelain 2>/dev/null \
  | sed -n '1s/^worktree //p')
[ -n "$main_root" ] || main_root="$repo_root"

printf '\033[2mfetching origin...\033[0m\n'
git -C "$repo_root" fetch --prune origin >/dev/null 2>&1 \
  || die "git fetch origin に失敗しました"

base_ref=$(git -C "$repo_root" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
[ -n "$base_ref" ] || base_ref="HEAD"

branches=$(git -C "$repo_root" for-each-ref --sort=-committerdate refs/remotes/origin \
  --format='%(refname:lstrip=3)	%(committerdate:relative)	%(authorname)	%(contents:subject)' \
  | grep -v '^HEAD	')
[ -n "$branches" ] || die "origin にブランチが見つかりません"

preview="git -C '$repo_root' log --color=always --pretty='%C(auto)%h %s %C(dim)(%an, %ar)' -30 '$base_ref'..origin/{1}"
preview="$preview; echo; git -C '$repo_root' diff --stat --color=always '$base_ref'...origin/{1}"

selected=$(printf '%s\n' "$branches" | fzf \
  --delimiter='\t' --with-nth=1,2,3,4 --nth=1,3,4 \
  --prompt='review branch> ' \
  --header="base: $base_ref  |  Enter: worktree を開く  Ctrl-C: 中止" \
  --preview="$preview" --preview-window=down,60%,wrap \
  --ansi --no-multi) || exit 0
[ -n "$selected" ] || exit 0

branch=$(printf '%s' "$selected" | cut -f1)
create_args=(--branch "$branch" --base "origin/$branch")

if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch"; then
  # 同名ローカルブランチあり: --base は無視されるので状態を確認する
  create_args=(--branch "$branch")

  # 既に checkout 済みの worktree があるならそれを開くだけ
  existing=$(git -C "$repo_root" worktree list --porcelain \
    | awk -v b="refs/heads/$branch" '
        /^worktree /{p=substr($0,10)}
        /^branch /{if (substr($0,8)==b) {print p; exit}}')
  if [ -n "$existing" ]; then
    if [ "$existing" = "$main_root" ]; then
      die "'$branch' はメインの checkout で使用中です。先に別ブランチへ切り替えてください。"
    fi
    out=$(herdr worktree open --cwd "$main_root" --path "$existing" --focus 2>&1) \
      || die "worktree を開けませんでした:\n$out"
    exit 0
  fi

  local_sha=$(git -C "$repo_root" rev-parse "$branch")
  remote_sha=$(git -C "$repo_root" rev-parse "origin/$branch")
  if [ "$local_sha" != "$remote_sha" ]; then
    if git -C "$repo_root" merge-base --is-ancestor "$branch" "origin/$branch"; then
      # 単に遅れているだけ: fast-forward してから開く
      git -C "$repo_root" fetch origin "$branch:$branch" >/dev/null 2>&1 \
        || die "'$branch' の fast-forward に失敗しました"
    else
      printf '\n\033[33mローカルの %s は origin/%s と分岐しています。\033[0m\n' "$branch" "$branch"
      printf '  [r] review/%s を origin から新規作成（推奨）\n' "$branch"
      printf '  [k] ローカルの %s をそのまま開く\n' "$branch"
      printf '  [q] 中止\n> '
      read -r answer </dev/tty
      case "$answer" in
        r|R|'')
          review="review/$branch"; n=2
          while git -C "$repo_root" show-ref --verify --quiet "refs/heads/$review"; do
            review="review/$branch-$n"; n=$((n + 1))
          done
          create_args=(--branch "$review" --base "origin/$branch")
          ;;
        k|K) : ;;
        *)   exit 0 ;;
      esac
    fi
  fi
fi

out=$(herdr worktree create --cwd "$main_root" "${create_args[@]}" \
  --label "$branch" --focus 2>&1) || die "worktree の作成に失敗しました:\n$out"
