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
configs into place, and installs runtimes. Node.js and uv come from
[mise](https://mise.jdx.dev/) at the versions in `.config/mise/config.toml`.
Ubuntu has no mise package, so
[install mise from its signed apt repository](https://mise.jdx.dev/installing-mise.html#apt)
before running `./install.sh` there.

## Managed LLM setup

LLM configuration is managed separately from the shell files:

```sh
./install.sh skills
./install.sh llm-import
./install.sh llm
```

- `skills` links the SHA-pinned public and private authored skill repositories.
  Normal installation is additive: it adds missing links and leaves conflicting
  local skill directories untouched.
- `llm-import` imports existing Claude, OpenCode, Copilot, or Conductor config
  into this repo before linking it. Existing runtime paths are never replaced
  unless `DOTFILES_OVERWRITE=1` is explicitly set.
- `llm` links the managed runtime configuration into the appropriate user paths.

Authored skills live in editable Git working trees under `~/Programming/skills`
and `~/Programming/skills-private`. Existing skill links follow:

```text
~/.claude/skills/<skill>
  -> ~/.agents/skills/<skill>
  -> ~/Programming/skills/<skill>          # public
  -> ~/Programming/skills-private/<skill>  # private
```

Edits through an existing Claude skill link modify its source repository
directly. Create new skills in the intended public or private source repository,
then run `./install.sh skills` to add their links.

Use `dotfiles-sync` (or `./install.sh sync`) to check dotfiles and authored
skill repositories for updates. `dotfiles-sync pull` fast-forwards clean
repositories, refreshes the shared skill pins, and adds missing links. When the
pins change it leaves `manifests/skills.lock` modified and prints the command to
commit it; that uncommitted pin change does not block later checks or pulls.
`dotfiles-sync reinject` only restores missing authored-skill links. Interactive
shells check in the background at most every six hours and print this command
when action is needed; they never pull automatically or change dirty trees.

Review available upstream skill pins with `./install.sh skills-update`. After
reviewing the revisions, set `SKILLS_UPDATE_WRITE=1` to update the lockfile.
Write mode also fast-forwards the authored checkouts in `~/Programming` to the
new pins. It checks every checkout first and changes nothing if any of them has
local changes or has diverged. A checkout with unpushed commits ahead of its pin
only produces a warning, during both `skills-update` and `./install.sh skills`.

## Getting started — the 2026 toolchain

A tour of what's wired in and the keystrokes that matter.

### Terminal

- **Theme**: [Duckbones](#tool-directory)
  via `.config/ghostty/config`, which both standalone Ghostty and
  [cmux](#tool-directory) read (it's first in cmux's config search order).
  Edit, then reload with **⌘⇧,** — applies instantly.
- **Multiplexing**: cmux is the window manager locally; tmux (`.tmux.conf`)
  remains for detachable sessions over SSH.

### Prompt (starship)

Green Tokyo Night-style pills —
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

- **[zoxide](#tool-directory)** — smarter `cd`.
  `z zipper` jumps to the directory you visit most that matches "zipper";
  `zi` for an interactive picker. It learns as you cd around.
- **[yazi](#tool-directory)** — type `y`: a terminal file
  manager with live previews — images render as real pixels (kitty graphics
  protocol), plus PDFs, video thumbnails, syntax-highlighted code, archives,
  JSON. Quitting cd's your shell to wherever you navigated, so it doubles as
  visual `cd`.
- **[eza](#tool-directory)** — `ls` and friends (`l`,
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
  with a preview pane: [bat](#tool-directory)-highlighted file
  contents, eza tree for directories (configured in `source/fzf`).
- **Alt-C** — fuzzy-cd into any subdirectory, previewing its tree.
- **Tab** — completion goes through [fzf-tab](#tool-directory):
  type `git checkout <Tab>` and fuzzy-search the branches.
- **fd / rg** (ripgrep) — find files by name / by contents; also the engines
  behind the pickers.

### Typing less

- **[zsh-abbr](#tool-directory)** — fish-style abbreviations. Type
  `gs` + space and watch it expand to `git status` before your eyes. Unlike
  aliases you always see the real command. Add your own with
  `abbr add "x"="long command"` (persisted in `.config/zsh-abbr/user-abbreviations`).
- **zsh-autosuggestions** — ghost-text suggestion from history as you type;
  accept with →.
- **zsh-syntax-highlighting** — valid commands render green, typos red, as you type.

### Remembering commands

- **[navi](#tool-directory)** — **Ctrl-G** opens a fuzzy
  cheatsheet of your own snippets, with fill-in placeholders. Snippets live in
  `cheats/*.cheat` in this repo — add the one-liners you keep re-googling.
- **[tealdeer](#tool-directory)** — `tldr <cmd>` shows
  community usage examples instead of a 40-page man page.
- **[pay-respects](#tool-directory)** — typo'd or failed a
  command? Type `fuck` and it proposes the fix.

### Runtimes & git

- **[mise](#tool-directory)** — node + python versions, pinned in
  `.config/mise/config.toml`. Reads `.nvmrc` in projects. `mise use node@24`
  to switch. uv stays in charge of python venvs and tools.
- **[delta](#tool-directory)** — git diffs/log/blame with
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

## Tool Directory

Every managed tool is listed here with its primary documentation. The package
manifests remain the source of truth for what `./install.sh packages`, `node`,
and `python` install.

### Foundation

| Tool | Purpose |
| --- | --- |
| [Homebrew](https://docs.brew.sh/) | macOS package manager |
| [APT](https://documentation.ubuntu.com/server/how-to/software/package-management/) | Ubuntu package manager |
| [Git](https://git-scm.com/doc) | version control |
| [Gitk](https://git-scm.com/docs/gitk) | graphical Git history viewer |
| [tmux](https://github.com/tmux/tmux/wiki) | terminal multiplexer |
| [Starship](https://starship.rs/config/) | shell prompt |
| [mise](https://mise.jdx.dev/) | runtime version manager |
| [Node.js](https://nodejs.org/docs/latest/api/) | JavaScript runtime |
| [npm](https://docs.npmjs.com/) | JavaScript package manager |
| [uv](https://docs.astral.sh/uv/) | Python version, environment, and tool manager |
| [Python](https://docs.python.org/3/) | Python runtime |
| [Zsh](https://zsh.sourceforge.io/Doc/) | interactive shell |

### Terminal Workflow

| Tool | Purpose |
| --- | --- |
| [Yazi](https://yazi-rs.github.io/docs/) | terminal file manager and previewer |
| [Helix](https://docs.helix-editor.com/) | syntax-aware terminal editor (`hx`) |
| [Vim](https://vimhelp.org/) | fallback terminal editor |
| [bat](https://github.com/sharkdp/bat#readme) | syntax-highlighted file viewer |
| [eza](https://eza.rocks/) | modern `ls` replacement |
| [fzf](https://junegunn.github.io/fzf/) | fuzzy finder |
| [fzf-tab](https://github.com/Aloxaf/fzf-tab#readme) | fzf-powered Zsh completion menu |
| [zoxide](https://github.com/ajeetdsouza/zoxide#readme) | smart directory navigation |
| [zsh-abbr](https://zsh-abbr.olets.dev/) | fish-style Zsh abbreviations |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions#readme) | command suggestions from history |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting#readme) | interactive command highlighting |
| [Navi](https://github.com/denisidoro/navi#readme) | searchable command cheatsheets |
| [Pay Respects](https://github.com/iffse/pay-respects#readme) | corrected command suggestions |
| [tealdeer](https://github.com/tealdeer-rs/tealdeer#readme) | fast `tldr` client |
| [ripgrep](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md) | fast text search (`rg`) |
| [fd](https://github.com/sharkdp/fd#readme) | friendly `find` replacement |
| [jq](https://jqlang.org/manual/) | JSON processor |
| [diff-so-fancy](https://github.com/so-fancy/diff-so-fancy#readme) | readable Git diffs |
| [Mole](https://github.com/tw93/Mole) | command-line search tool |
| [aria2](https://aria2.github.io/) | resumable, segmented downloader |
| [Docker](https://docs.docker.com/) | container runtime and contexts |
| [Google Cloud CLI](https://cloud.google.com/sdk/docs) | Google Cloud project and service CLI |

### Optional Utilities

| Tool | Purpose |
| --- | --- |
| [Ghostty](https://ghostty.org/docs) | terminal emulator |
| [cmux](https://cmux.com/docs) | local terminal workspace manager |
| [Duckbones](https://terminalcolors.com/themes/zenbones/duckbones/) | terminal color theme |
| [dust](https://github.com/bootandy/dust#readme) | disk-usage viewer |
| [duf](https://github.com/muesli/duf#readme) | disk-space viewer |
| [sd](https://github.com/chmln/sd#readme) | find-and-replace CLI |
| [procs](https://github.com/dalance/procs#readme) | process viewer |
| [hyperfine](https://github.com/sharkdp/hyperfine#readme) | command-line benchmarker |

### Media And File Previews

| Tool | Purpose |
| --- | --- |
| [ffmpeg](https://ffmpeg.org/documentation.html) | audio and video processing |
| [Poppler](https://poppler.freedesktop.org/) | PDF rendering utilities |
| [7-Zip](https://www.7-zip.org/) | archive extraction (`7zz`) |
| [ImageMagick](https://imagemagick.org/script/command-line-tools.php) | image conversion and manipulation |
| [resvg](https://docs.rs/resvg/latest/resvg/) | SVG rendering |
| [Chafa](https://hpjansson.org/chafa/) | terminal image rendering |
| [viu](https://github.com/atanunq/viu#readme) | terminal image viewer |
| [lsix](https://github.com/hackerb9/lsix#readme) | terminal image thumbnail sheet |
| [yt-dlp](https://github.com/yt-dlp/yt-dlp#readme) | media downloader |
| [Symbols Nerd Font](https://www.nerdfonts.com/) | terminal icon glyphs |

### Development Tools

| Tool | Purpose |
| --- | --- |
| [TypeScript](https://www.typescriptlang.org/docs/) | typed JavaScript language |
| [ts-node](https://typestrong.org/ts-node/docs/) | TypeScript execution for Node.js |
| [tsx](https://tsx.is/) | fast TypeScript execution |
| [json-log-viewer](https://github.com/mbbill/json-log-viewer#readme) | JSON log viewer |
| [Black](https://black.readthedocs.io/) | Python formatter |
| [Ruff](https://docs.astral.sh/ruff/) | Python linter and formatter |
| [Jupyter](https://docs.jupyter.org/) | interactive Python notebooks |

### LLM Runtimes

| Tool | Purpose |
| --- | --- |
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | Anthropic coding agent runtime |
| [GitHub Copilot](https://code.visualstudio.com/docs/copilot/overview) | GitHub coding assistant runtime |
| [OpenCode](https://opencode.ai/docs/) | open-source coding agent runtime |
| [Conductor](https://conductor.build/docs) | agent orchestration runtime |
| [Agent Skills](https://agentskills.io/) | portable agent-skill format |
