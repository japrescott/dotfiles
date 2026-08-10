dotfiles
========

## Install

```sh
git clone https://github.com/japrescott/dotfiles ~/dotfiles
cd ~/dotfiles && ./install.sh
```

then add to `~/.zshrc`:

```sh
source ~/dotfiles/import
```

`install.sh` installs everything via Homebrew (or apt on Ubuntu), symlinks the
configs into place, and installs runtimes. Terminal colors come from the Ghostty
config (`.config/ghostty/config`), which cmux also reads.

## Getting started — the 2026 toolchain

A tour of what's wired in and the keystrokes that matter.

### Prompt & navigation

- **[starship](https://starship.rs)** — the prompt. Shows cwd, git branch/status,
  and language versions when relevant. Colors follow the terminal theme;
  configured in `.config/starship.toml`.
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** — smarter `cd`. `z zipper`
  jumps to the directory you visit most that matches "zipper". `zi` for an
  interactive picker. It learns as you cd around.
- **[eza](https://github.com/eza-community/eza)** — `ls` and friends (`l`, `ll`,
  `la`, `tree`) now show git status and icons.

### Finding things (fzf everywhere)

- **Ctrl-R** — fuzzy-search shell history (100k entries kept, shared across panes).
- **Ctrl-T** — fuzzy-pick files/dirs under the cwd, inserted at the cursor.
- **Alt-C** — fuzzy-cd into any subdirectory.
- **Tab** — completion goes through [fzf-tab](https://github.com/Aloxaf/fzf-tab):
  type `git checkout <Tab>` and fuzzy-search the branches.

### Typing less

- **[zsh-abbr](https://zsh-abbr.olets.dev)** — fish-style abbreviations. Type
  `gs` + space and watch it expand to `git status` before your eyes. Unlike
  aliases you always see the real command. Add your own with
  `abbr add "x"="long command"` (persisted in `.config/zsh-abbr/user-abbreviations`).
- **zsh-autosuggestions** — ghost-text suggestion from history as you type;
  accept with →.
- **zsh-syntax-highlighting** — valid commands render green, typos red, as you type.

### Remembering commands

- **[navi](https://github.com/denisidoro/navi)** — **Ctrl-G** opens a fuzzy
  cheatsheet of your own snippets, with fill-in placeholders. Snippets live in
  `cheats/*.cheat` in this repo — add the one-liners you keep re-googling.
- **[tealdeer](https://github.com/tealdeer-rs/tealdeer)** — `tldr <cmd>` shows
  community usage examples instead of a 40-page man page.
- **[pay-respects](https://github.com/iffse/pay-respects)** — typo'd or failed a
  command? Type `fuck` and it proposes the fix.

### Runtimes & git

- **[mise](https://mise.jdx.dev)** — node + python versions, pinned in
  `.config/mise/config.toml`. Reads `.nvmrc` in projects. `mise use node@24`
  to switch. uv stays in charge of python venvs and tools.
- **[delta](https://github.com/dandavison/delta)** — git diffs/log/blame with
  syntax highlighting and line numbers. `git add -p` is highlighted too.

### Modern coreutils

| instead of | try | for |
|---|---|---|
| `du -sh *` | `dust` | disk usage as a readable tree |
| `df -h` | `duf` | mounted volumes, readable |
| `sed -i` | `sd 'find' 'replace'` | sane find & replace |
| `ps aux \| grep` | `procs <name>` | readable process list |
| `time` loops | `hyperfine 'cmd'` | proper benchmarking with stats |

Old habits still work — these are additions, not replacements.
