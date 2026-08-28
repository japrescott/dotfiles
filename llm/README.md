# LLM Runtime Config

This tree is the versioned source of truth for personal AI tooling config that
is symlinked into runtime-owned paths under the home directory.

## Install

Run the dedicated installer phase from the repo root:

```sh
./install.sh skills
./install.sh llm-import
./install.sh llm
```

Use `llm-import` to pull existing local runtime files into the repo-owned paths
before you symlink them. The import step backs up the current repo-side source
path with a `.pre-import.<timestamp>` suffix before replacing it with the local
runtime contents.

The installer links repo-owned files into live runtime locations so edits made
through paths like `~/.claude/CLAUDE.md` or `~/.config/opencode/opencode.json`
write back into this repo.

If a managed runtime path already exists, the installer warns and skips it by
default. This prevents local config from being silently replaced. After you
import the existing file into the repo-owned runtime path, rerun the installer.
Only use `DOTFILES_OVERWRITE=1 ./install.sh llm` when you explicitly want the
installer to back up and replace an existing path.

Run `./install.sh skills` before `llm` to install the SHA-pinned skill packages
declared in `manifests/skills.lock`. Use `./install.sh skills-update` to review
available upstream pins, then set `SKILLS_UPDATE_WRITE=1` to apply approved pin
updates. Project-specific installs are private by default and belong in
`manifests/skills-projects.lock`; each entry includes its local project path and
causes skills.sh to write that project's native `skills-lock.json`. Shared
authored skills are instead editable working trees under `~/Programming/skills`
and `~/Programming/skills-private`, linked through `~/.agents/skills` into
Claude. The LLM linker never replaces a runtime skills directory.

## Layout

- `catalog/` contains machine-readable metadata about managed runtimes.
- `runtimes/` mirrors the user-authored surfaces that are safe to version.
- `manifests/skills.lock` declares pinned shared skills.sh packages.
- `manifests/skills-projects.lock` declares private project-specific packages.

## Managed vs Local

Only stable, user-authored config belongs here.

Examples of managed surfaces:

- Claude instructions, rules, agents, and settings.
- OpenCode config plus authored instructions, agents, and commands.
- Conductor user-only settings.
- User-level Copilot instruction files.

Examples of local-only surfaces that should stay outside this repo:

- Auth tokens and secrets.
- Runtime caches, indexes, and session state.
- Machine-local approvals or trust records.
