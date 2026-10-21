# dotfiles

mise bootstrap で管理する macOS の dotfiles。

## セットアップ

```sh
# Homebrew と mise
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install mise

mise bootstrap --from <このリポジトリの URL>

exec zsh -l
```

`mise bootstrap` は次の順に進む。どれも何度実行してもよい。

1. `[bootstrap.packages]` の brew formula / cask を入れる
2. `[dotfiles]` のファイルをホームにリンクする
3. `pre-tools` フックで Claude Code を入れる
4. `~/.config/mise/config.toml` のツール（Node.js、pnpm、Python、Rust、npm パッケージ、miel）を入れる
5. `bootstrap` タスクで helix のビルド、helix プラグイン、VS Code 拡張機能を入れる

ツールの置き場所は次のように分ける。

- 言語ランタイム、npm / cargo のツール: `mise-global/config.toml`（`~/.config/mise/config.toml` にリンクする）
- 一般の CLI、GUI アプリ、フォント、zsh プラグイン: `mise.toml` の `[bootstrap.packages]`（Homebrew）
- 独自のビルド手順が要るもの（helix）: `mise-tasks/`

一部だけ流すときは `--only` を使う。

```sh
mise bootstrap --only packages
mise bootstrap --only dotfiles
mise bootstrap dotfiles status   # リンクの状態を見る
```

## git

汎用設定は `~/.config/git/config` として管理する。user など環境ごとの設定は管理せず `~/.gitconfig` に書く。

```sh
git config --file ~/.gitconfig user.name "<name>"
git config --file ~/.gitconfig user.email "<email>"
```

`~/.gitconfig` がないと `git config --global` は `~/.config/git/config` に書き込むので、先に作っておく。

## helix

steel 対応フォーク（mattwparas/helix の `steel-event-system`）をビルドする。ソースは `~/.cache/helix-steel` に clone する。

```sh
mise run helix:build            # 未インストールか、clone の HEAD がインストール済みと違うときだけビルドする
mise run helix:build --update   # ソースを最新にしてからビルドする
mise run helix:build --force    # 常にビルドする
```

`mise bootstrap` からは `--update` なしで呼ぶので、ソースが勝手に進むことはない。

プラグイン（steel cog）は `helix/cog.scm` の `dependencies` に列挙している。

```sh
mise run helix:plugins          # すべてインストール・最新に更新（forge build）
mise run helix:plugins forest   # forest だけ更新（forge pkg install --git --force）
```

forge は `git pull` の失敗を無視するので、どちらも最後に各プラグインのコミットを表示する。helix の再起動で反映される。

`forge build --dry-run` は使わない。既存の `~/.local/share/steel/cogs/<name>` を削除したうえでコピーを省くため、プラグインが消える。
