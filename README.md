# dna_scripts

English | [Deutsch](README.de.md)

Gives a repo the node scripts that automate its git and GitHub workflow, and
the functions they share.

## Motivation

Repos automate the same steps of their workflow with small node scripts:
checking that `main` is clean, waiting for a pull request, setting up a new
GitHub repo, renaming a class. Copied from repo to repo — the rljson repos
took theirs from `template-project` — every copy repeats the same `git`, `gh`
and file system calls. This layer ships the scripts as one set that every repo
gets the same way, with those calls in shared functions that no script
repeats.

## Usage

Declare it as a dev-dependency and initialize once:

```bash
pnpm add -D @ggdna/dna-scripts   # TypeScript projects
dart pub add dev:dna_scripts     # Dart projects
helix init
```

`helix init` places a test that instantiates and verifies the DNA on every
test run. It copies the scripts to `scripts/`, the shared functions to
`scripts/functions/`, the guide to `doc/guides/` and the skill to
`.claude/skills/scripts/`.

The scripts need Node.js 22 or newer, in Dart repos as well. The ones that
talk to GitHub need the [GitHub CLI](https://cli.github.com), logged in with
`gh auth login`. Run them from the repo root:

```bash
node scripts/setup-github-repo.js                # prints the settings, changes nothing
node scripts/setup-github-repo.js --apply        # applies them to this repo
node scripts/wait-for-pr.js                      # waits until the pull request is merged or closed
node scripts/delete-feature-branch.js            # deletes the merged feature branch locally
node scripts/rename-class.js OldName NewName     # renames a class across the repo
```

Type `/scripts` in Claude Code to check that the scripts still work.

## Guides

- `dna/doc/guides/scripts-guide.md` — use a shared function instead of
  repeating a `git`, `gh` or file system call, and where a new script and its
  shared parts go

## Skills

- `/scripts` — runs `node --check` on every script, checks that every import
  from `./functions/` resolves to an exported symbol, reports `git`, `fs` or
  `child_process` calls copied across scripts, then writes the fixes; follows
  the scripts guide

## Scripts

The scripts guide calls none of them; run them by hand from the repo root,
as shown in the usage.

- `dna/scripts/setup-github-repo.js` — sets up a GitHub repo via `gh api`:
  squash merges only, auto merge, branches deleted after merge, and a ruleset
  `Default` on the default branch that blocks deletion and force pushes and
  requires a linear history, a pull request and the status check
  `dnaGitQuickCheckPipelineName`. Without `--apply` it only prints the
  settings; `--require-review` adds one required approval; an `org/repo`
  argument targets another repo
- `dna/scripts/wait-for-pr.js` — prints the URL of the current branch's pull
  request and polls via `gh` until it is merged or closed. It stops early when
  the latest workflow run failed — but it reads that run from the hardcoded
  repo `rljson/template-project`, not from the current one
- `dna/scripts/delete-feature-branch.js` — checks that the feature branch has
  no uncommitted or unpushed work, pulls `main`, test-merges the branch and
  deletes it locally if it is fully merged; it does not touch the remote
  branch
- `dna/scripts/rename-class.js` — renames a class in every text file of the
  repo, in UpperCamelCase, lowerCamelCase, kebab case and snake case, and
  renames the files whose names contain it; skips hidden folders,
  `node_modules` and binary files
- `dna/scripts/functions/` — the shared functions the scripts import:
  - `colors.js` — ANSI colors for console output
  - `run-command.js` — runs a shell command, logs it and returns its output
  - `current-branch.js` — the current git branch
  - `is-clean-repo.js` — whether `main` is checked out, clean and in sync
    with `origin/main`
  - `is-main-up-to-date.js` — whether local `main` matches `origin/main`
  - `directories.js` — the repo root and its `dist`, `src`, `test`,
    `scripts`, `test/goldens` and `node_modules` folders, derived from the
    location of the script
  - `get-version.js` — the version from `package.json`
  - `sync-folders.js` — copies one folder into another, recursively
  - `get-repo-urls.js` — the repository URLs of a GitHub organization or
    user, via `gh repo list`
  - `pull-request-url.js` — the URL of the current branch's pull request,
    via `gh pr view`

## Scope

The layer only ships the scripts and the rules for writing them. It leaves the
workflow they belong to — when a script runs and which guide calls it — to the
repo and to other layers, and it installs neither Node.js nor the GitHub CLI;
dna_install has the guides for both.

## Layers

The layer is orthogonal: `dna/_dna.json` lists no parent layers. It carries
only its own topic and is combined with other layers by the consuming repo.

## Variables

`mustOverride` in `dna/_dna.json` forces every repo or layer that lists this
layer to set both variables in its own `dna/_vars.json`, because they name the
organization and have no sensible default. An umbrella such as dna_ggdna sets
them once for its organization.

- `dnaCopyrightHolder` — the holder named in the copyright header of every
  placed file
- `dnaGitQuickCheckPipelineName` — the name of the quick check that
  `setup-github-repo.js` makes a required status check; the layer has no
  default value for it in `dna/_vars.json`

## Development

The `dna/` folder is hand-authored source and is never generated. The repo
instantiates its own DNA — run `dart test` after changes; commit first, a file
the DNA would overwrite must not carry uncommitted work.

Edit the files below `dna/`, never their copies in `scripts/`, `doc/` and
`.claude/`: the test overwrites them.

## License

MIT — see [LICENSE](LICENSE).
