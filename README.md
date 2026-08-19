# dna_scripts

The DNA layer for the node scripts a repo automates its workflow with —
deterministic given local git and file system state, no GitHub API calls.

## Guides

- `dna/doc/guides/scripts-guide.md` — what belongs here, what does not,
  and how to add a script

## Skills

- `/scripts` — checks every script parses, every import resolves, and
  reports duplicated logic that should be a shared function

## Scripts

- `dna/scripts/functions/colors.js` — ANSI colors for console output
- `dna/scripts/functions/current-branch.js` — the current git branch
- `dna/scripts/functions/directories.js` — the script's own directory
- `dna/scripts/functions/get-version.js` — the version from `package.json`
- `dna/scripts/functions/is-clean-repo.js` — whether `main` is checked
  out, clean and in sync with `origin/main`
- `dna/scripts/functions/is-main-up-to-date.js` — whether local `main`
  matches `origin/main`
- `dna/scripts/functions/run-command.js` — runs a shell command, logs
  and returns its output
- `dna/scripts/functions/sync-folders.js` — recursively copies one
  folder into another
- `dna/scripts/functions/get-repo-urls.js` — lists a GitHub
  organization's repository URLs via `gh`
- `dna/scripts/functions/pull-request-url.js` — the URL of the current
  branch's pull request via `gh`
- `dna/scripts/delete-feature-branch.js` — deletes the current feature
  branch locally and on the remote once it is merged
- `dna/scripts/rename-class.js` — renames every occurrence of a class
  and file name across the repo
- `dna/scripts/setup-github-repo.js` — applies the branch protection
  rules a new repo needs
- `dna/scripts/wait-for-pr.js` — waits for the current pull request to
  merge

## Layers

Orthogonal: this layer carries only its own topic and is combined with
other layers by the consuming repo.

## Variables

- `dnaCopyrightHolder` — the name in the license header of every file

## Usage

Declare it as a dev-dependency and initialize once:

```bash
pnpm add -D @ggdna/dna-scripts   # TypeScript projects
dart pub add dev:dna_scripts     # Dart projects
helix init
```

The placed test instantiates and verifies the DNA on every test run.

## Development

The `dna/` folder is hand-authored source and is never generated. The repo
instantiates its own DNA — run `dart test` after changes; commit first, a
file the DNA would overwrite must not carry uncommitted work.
