# dna_scripts

[English](README.md) | Deutsch

Gibt einem Repo die Node-Skripte, die seinen Git- und GitHub-Ablauf
automatisieren, und die Funktionen, die sie gemeinsam nutzen.

## Motivation

Repos automatisieren dieselben Schritte ihres Ablaufs mit kleinen
Node-Skripten: prüfen, ob `main` sauber ist, auf einen Pull Request warten, ein
neues GitHub-Repo einrichten, eine Klasse umbenennen. Von Repo zu Repo kopiert
— die rljson-Repos haben ihre aus `template-project` übernommen —, wiederholt
jede Kopie dieselben `git`-, `gh`- und Dateisystem-Aufrufe. Diese Schicht
liefert die Skripte als einen Satz, den jedes Repo auf dieselbe Weise bekommt,
mit diesen Aufrufen in gemeinsamen Funktionen, die kein Skript wiederholt.

## Verwendung

Als Dev-Dependency eintragen und einmal initialisieren:

```bash
pnpm add -D @ggdna/dna-scripts   # TypeScript projects
dart pub add dev:dna_scripts     # Dart projects
helix init
```

`helix init` legt einen Test ab, der die DNA bei jedem Testlauf instanziiert
und prüft. Er kopiert die Skripte nach `scripts/`, die gemeinsamen Funktionen
nach `scripts/functions/`, den Guide nach `doc/guides/` und den Skill nach
`.claude/skills/scripts/`.

Die Skripte brauchen Node.js 22 oder neuer, auch in Dart-Repos. Die Skripte,
die mit GitHub sprechen, brauchen die [GitHub CLI](https://cli.github.com),
angemeldet mit `gh auth login`. Starte sie aus dem Wurzelverzeichnis des Repos:

```bash
node scripts/setup-github-repo.js                # prints the settings, changes nothing
node scripts/setup-github-repo.js --apply        # applies them to this repo
node scripts/wait-for-pr.js                      # waits until the pull request is merged or closed
node scripts/delete-feature-branch.js            # deletes the merged feature branch locally
node scripts/rename-class.js OldName NewName     # renames a class across the repo
```

Tippe `/scripts` in Claude Code, um zu prüfen, ob die Skripte noch
funktionieren.

## Guides

- `dna/doc/guides/scripts-guide.md` — eine gemeinsame Funktion nutzen, statt
  einen `git`-, `gh`- oder Dateisystem-Aufruf zu wiederholen, und wohin ein
  neues Skript und seine gemeinsamen Teile gehören

## Skills

- `/scripts` — führt `node --check` für jedes Skript aus, prüft, ob jeder
  Import aus `./functions/` auf ein exportiertes Symbol zeigt, meldet `git`-,
  `fs`- oder `child_process`-Aufrufe, die zwischen Skripten kopiert sind, und
  schreibt dann die Korrekturen; folgt dem Skript-Guide

## Skripte

Der Skript-Guide ruft keines davon auf; starte sie von Hand aus dem
Wurzelverzeichnis des Repos, wie in der Verwendung gezeigt.

- `dna/scripts/setup-github-repo.js` — richtet ein GitHub-Repo über `gh api`
  ein: nur Squash-Merges, Auto-Merge, Branches nach dem Merge löschen und ein
  Ruleset `Default` auf dem Default-Branch, das Löschen und Force-Pushes
  verbietet und eine lineare Historie, einen Pull Request und den Status-Check
  `dnaGitQuickCheckPipelineName` verlangt. Ohne `--apply` gibt es die
  Einstellungen nur aus; `--require-review` verlangt zusätzlich eine
  Freigabe; ein Argument `org/repo` richtet ein anderes Repo ein
- `dna/scripts/wait-for-pr.js` — gibt die URL des Pull Requests des aktuellen
  Branches aus und fragt über `gh` ab, bis er gemergt oder geschlossen ist. Es
  bricht früher ab, wenn der letzte Workflow-Lauf fehlgeschlagen ist — liest
  diesen Lauf aber aus dem fest eingetragenen Repo `rljson/template-project`,
  nicht aus dem aktuellen
- `dna/scripts/delete-feature-branch.js` — prüft, dass der Feature-Branch keine
  uncommittete oder ungepushte Arbeit hat, holt `main`, probiert den Merge des
  Branches und löscht ihn lokal, wenn er vollständig gemergt ist; den
  Remote-Branch fasst es nicht an
- `dna/scripts/rename-class.js` — benennt eine Klasse in jeder Textdatei des
  Repos um, in UpperCamelCase, lowerCamelCase, Kebab-Case und Snake-Case, und
  benennt die Dateien um, deren Name sie enthält; überspringt versteckte
  Ordner, `node_modules` und Binärdateien
- `dna/scripts/functions/` — die gemeinsamen Funktionen, die die Skripte
  importieren:
  - `colors.js` — ANSI-Farben für die Konsolenausgabe
  - `run-command.js` — führt einen Shell-Befehl aus, protokolliert ihn und gibt
    seine Ausgabe zurück
  - `current-branch.js` — der aktuelle Git-Branch
  - `is-clean-repo.js` — ob `main` ausgecheckt, sauber und auf dem Stand von
    `origin/main` ist
  - `is-main-up-to-date.js` — ob das lokale `main` mit `origin/main`
    übereinstimmt
  - `directories.js` — das Wurzelverzeichnis des Repos und seine Ordner
    `dist`, `src`, `test`, `scripts`, `test/goldens` und `node_modules`,
    abgeleitet aus dem Ort des Skripts
  - `get-version.js` — die Version aus `package.json`
  - `sync-folders.js` — kopiert einen Ordner rekursiv in einen anderen
  - `get-repo-urls.js` — die Repository-URLs einer GitHub-Organisation oder
    eines Nutzers, über `gh repo list`
  - `pull-request-url.js` — die URL des Pull Requests des aktuellen Branches,
    über `gh pr view`

## Umfang

Die Schicht liefert nur die Skripte und die Regeln, nach denen sie geschrieben
werden. Den Ablauf, zu dem sie gehören — wann ein Skript läuft und welcher
Guide es aufruft —, überlässt sie dem Repo und anderen Schichten, und sie
installiert weder Node.js noch die GitHub CLI; die Guides für beides hat
dna_install.

## Schichten

Die Schicht ist orthogonal: `dna/_dna.json` nennt keine Eltern-Schichten. Sie
trägt nur ihr eigenes Thema und wird vom nutzenden Repo mit anderen Schichten
kombiniert.

## Variablen

`mustOverride` in `dna/_dna.json` zwingt jedes Repo und jede Schicht, die diese
Schicht einbindet, beide Variablen in der eigenen `dna/_vars.json` zu setzen,
weil sie die Organisation nennen und keinen sinnvollen Standardwert haben. Ein
Umbrella wie dna_ggdna setzt sie einmal für seine Organisation.

- `dnaCopyrightHolder` — der Rechteinhaber im Copyright-Kopf jeder abgelegten
  Datei
- `dnaGitQuickCheckPipelineName` — der Name des Quick Checks, den
  `setup-github-repo.js` zum Pflicht-Status-Check macht; die Schicht hat dafür
  keinen Standardwert in `dna/_vars.json`

## Entwicklung

Der Ordner `dna/` ist handgeschriebene Quelle und wird nie generiert. Das Repo
instanziiert seine eigene DNA — nach Änderungen `dart test` laufen lassen;
vorher committen, denn eine Datei, die die DNA überschreiben würde, darf keine
uncommittete Arbeit enthalten.

Bearbeite die Dateien unter `dna/`, nie ihre Kopien in `scripts/`, `doc/` und
`.claude/`: Der Test überschreibt sie.

## Lizenz

MIT — siehe [LICENSE](LICENSE).
