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
configs into place, and installs runtimes.

## Getting started — the 2026 toolchain

A tour of what's wired in and the keystrokes that matter.

### Terminal

- **Theme**: [Duckbones](https://terminalcolors.com/themes/zenbones/duckbones/)
  via `.config/ghostty/config`, which both standalone Ghostty and
  [cmux](https://cmux.com) read (it's first in cmux's config search order).
  Edit, then reload with **⌘⇧,** — applies instantly.
- **Multiplexing**: cmux is the window manager locally; tmux (`.tmux.conf`)
  remains for detachable sessions over SSH.

### Prompt (starship)

Green [Tokyo Night](https://starship.rs/presets/tokyo-night)-style pills —
recolored to the `#87af5f` green of the 2015 promptline this repo ran for a
decade. Configured in `.config/starship.toml`; support code that starship
can't do itself lives in `source/prompt`.

- **Machine badge** (first pill): `󰋜 󰇵` on the private laptop, `󰋜 󰕈` on
  minix, ` 󰚩` anywhere else (corporate). Hostname-based, in `source/prompt`.
- **Directory**: last two folders in full, 3-char fish-style crumbs above
  (`~/Pro/zip/scripts/ingest`).
- **Git**: branch plus change counts — `+1!3?2⇡1` is staged/modified/
  untracked/ahead.
- **Contextual pills**: node/python versions, docker context, active gcloud
  project — each only when relevant.
- **Right margin**: previous command's duration (zero-padded, `1s034ms`,
  hidden under 100ms) and the clock — the gap between two clocks is the wall
  time between commands.
- **Claude Code**: the same starship renders Claude Code's statusline
  (model, context gauge, session cost) via the `claude-code` profile.
- **Nostalgia**: the 2015 promptline is preserved in `prompt_nostalgia.sh` —
  `zsh -f` then `source ~/dotfiles/prompt_nostalgia.sh` to visit.

### Navigation & preview

- **[zoxide](https://github.com/ajeetdsouza/zoxide)** — smarter `cd`.
  `z zipper` jumps to the directory you visit most that matches "zipper";
  `zi` for an interactive picker. It learns as you cd around.
- **[yazi](https://github.com/sxyazi/yazi)** — type `y`: a terminal file
  manager with live previews — images render as real pixels (kitty graphics
  protocol), plus PDFs, video thumbnails, syntax-highlighted code, archives,
  JSON. Quitting cd's your shell to wherever you navigated, so it doubles as
  visual `cd`.
- **[eza](https://github.com/eza-community/eza)** — `ls` and friends (`l`,
  `ll`, `la`) with git status and icons. `tree` draws the directory tree:
  `tree -L 2` limits depth, `-a` includes dotfiles, `--git-ignore` skips
  node_modules and friends — `tree -L 3 --git-ignore` is the code-repo
  incantation.
- **`viu img.png`** shows an image in the terminal; **`lsix`** shows a
  thumbnail sheet of a directory's images; **`bat file`** is `cat` with
  syntax highlighting and git gutters.

### Finding things (fzf everywhere)

- **Ctrl-R** — fuzzy-search shell history (100k entries kept, shared across panes).
- **Ctrl-T** — fuzzy-pick files/dirs under the cwd, inserted at the cursor,
  with a preview pane: [bat](https://github.com/sharkdp/bat)-highlighted file
  contents, eza tree for directories (configured in `source/fzf`).
- **Alt-C** — fuzzy-cd into any subdirectory, previewing its tree.
- **Tab** — completion goes through [fzf-tab](https://github.com/Aloxaf/fzf-tab):
  type `git checkout <Tab>` and fuzzy-search the branches.
- **fd / rg** (ripgrep) — find files by name / by contents; also the engines
  behind the pickers.

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

### Under the hood (startup speed)

Startup is ~0.4s, profiled with zprof + hyperfine. How it stays that way:

- `import` caches every tool's `init zsh` output in `~/.cache/zsh-init-cache/`
  (`_initcache`), re-generating only when the tool's binary is newer — a
  `source` costs ~1ms where a spawn costs 30–90ms.
- compinit runs its full audit at most once a day, `-C` otherwise.
- gcloud's completion (~250ms) loads after the first prompt, not before it.
- The remaining cost is mise's activation hook (~140ms) and zsh-abbr (~120ms)
  — the price of per-directory runtimes and abbreviations.

Layout: `import` is orchestration only; per-topic shell code lives in
`source/*` (auto-sourced); tool configs live in `.config/*` (symlinked by
`install.sh`).
