dotfiles
========

Install
-------

```sh
git clone https://github.com/japrescott/dotfiles ~/dotfiles
cd ~/dotfiles && ./install.sh
```

The installer is split into explicit phases, so you can rerun one slice without
touching the rest of the machine:

```sh
./install.sh packages
./install.sh submodules
./install.sh links
./install.sh skills
./install.sh skills-update
./install.sh skills-projects
./install.sh llm-import
./install.sh llm
./install.sh node
./install.sh python
```

Add this to `~/.bashrc` or `~/.zshrc`:

```sh
source ~/dotfiles/import
```

`import` resolves the repo from its own location, so sourcing works from any
current working directory.

LLM setup
---------

LLM runtime config lives under `llm/` and is managed separately from the rest of
the shell dotfiles.

```sh
./install.sh submodules
./install.sh skills
./install.sh llm-import
./install.sh llm
```

- Run `skills` to install the SHA-pinned skill packages in `manifests/skills.lock`.
- Run `skills-update` to view newer upstream commits. Review the reported
  revisions, then rerun it with `SKILLS_UPDATE_WRITE=1` to update the lockfile.
- Run `skills-projects` only for private, project-specific packages declared in
  `manifests/skills-projects.lock`. Each entry names its local project path and
  writes that project's native `skills-lock.json`.
- Run `llm-import` before `llm` when local Claude, OpenCode, Copilot, or
  Conductor config should become the repo-owned source of truth.
- The installer never overwrites existing runtime paths by default. It warns and
  leaves them in place until you reconcile or import them.
- Use `DOTFILES_OVERWRITE=1 ./install.sh llm` only when you intentionally want
  to back up and replace an existing file or directory.

Skills declared in `manifests/skills.lock` are cloned as editable working trees
under `~/Programming/skills` and `~/Programming/skills-private`. The installer
verifies each pinned commit and links every authored skill into
`~/.agents/skills`; existing Claude skill links resolve through that directory.
Editing or creating a skill through `~/.claude/skills` therefore changes the
appropriate Git working tree directly. Normal installation is additive: it adds
missing authored-skill links but leaves any existing nonmatching local skill
directory untouched for manual reconciliation.

Authored skill workflow
-----------------------

Existing authored skills follow this link chain:

```text
~/.claude/skills/<skill>
  -> ~/.agents/skills/<skill>
  -> ~/Programming/skills/<skill>          # public
  -> ~/Programming/skills-private/<skill>  # private
```

Editing an existing linked skill through `~/.claude/skills/<skill>` immediately
changes its public or private Git working tree. Commit and push from that source
repository to publish the change.

A new skill cannot be automatically classified as public or private. Create it
in the intended source repository, then refresh the links:

```sh
mkdir ~/Programming/skills/my-public-skill
# or: mkdir ~/Programming/skills-private/my-private-skill
./install.sh skills
```

Project-specific packages are private by default and belong in
`manifests/skills-projects.lock`, sourced from `skills-private`. This installer
does not replace either `~/.claude/skills` or `~/.config/opencode/skills`.

Getting started
---------------

What the shell wires in by default.

Terminal
--------

- Theme: Duckbones via `.config/ghostty/config`.
- Multiplexing: cmux locally, tmux for detachable SSH sessions.

Prompt
------

- Starship powers the prompt and Claude Code statusline.
- The old promptline is still preserved in `prompt_nostalgia.sh`.

Navigation and preview
----------------------

- `z` via zoxide for directory jumping.
- `y` via yazi for a terminal file manager with previews.
- `l`, `ll`, `la`, `tree`, `bat`, `viu`, and `lsix` for richer shell browsing.

Finding things
--------------

- `Ctrl-R` for fuzzy shell history.
- `Ctrl-T` for fuzzy file picking with previews.
- `Alt-C` for fuzzy directory jumping.
- `fd` and `rg` as the underlying file and content search tools.

Typing less
-----------

- `zsh-abbr` for expanding short commands to their real form.
- `zsh-autosuggestions` for ghost-text history suggestions.
- `zsh-syntax-highlighting` for inline command validation.

Remembering commands
--------------------

- `Ctrl-G` opens navi snippets.
- `tldr <cmd>` shows short usage examples.
- `fuck` proposes a correction for failed commands via pay-respects.

Runtimes and git
----------------

- `mise` manages node and python versions.
- `delta` renders git diffs, logs, and blame with syntax highlighting.
- `source/*` is auto-sourced by `import`, so helpers like `claudeyolo` from
  `source/claude` are available in every shell.

Startup model
-------------

- `import` is orchestration only; topic-specific shell code lives in `source/*`.
- Tool init scripts are cached under `~/.cache/zsh-init-cache/` for fast shells.
- Completions are audited once per day and reused otherwise.
