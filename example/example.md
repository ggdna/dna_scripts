# Example

`dna_scripts` is a DNA layer: it ships deterministic node scripts, their
shared functions, the scripts guide and the `/scripts` skill, no library
code. Declare it as a dev dependency and instantiate it once:

```bash
dart pub add dev:dna_scripts    # Dart projects
pnpm add -D @ggdna/dna-scripts  # TypeScript projects
gg dna init
gg dna build
```

Then run a script from the project root, e.g.:

```bash
node scripts/wait-for-pr.js
```
