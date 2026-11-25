// @license
// Copyright (c) ggsuite
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:test/test.dart';

/// Node built-ins the scripts call without a namespace prefix.
const _nodeFunctions = {
  'execSync',
  'exec',
  'execFileSync',
  'spawn',
  'spawnSync',
  'readFileSync',
  'writeFileSync',
  'existsSync',
  'mkdirSync',
  'readdirSync',
  'statSync',
  'copyFileSync',
  'rmSync',
  'unlinkSync',
  'join',
  'resolve',
  'dirname',
  'basename',
  'relative',
  'tmpdir',
  'promisify',
  'fileURLToPath',
};

final _scriptsDir = Directory('dna/scripts');

List<File> _scripts() =>
    _scriptsDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.js'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

/// The names exported by the shared modules in `dna/scripts/functions`.
Set<String> _sharedExports() {
  final export = RegExp(
    r'^export\s+(?:async\s+)?(?:const|let|function)\s+([A-Za-z_$][\w$]*)',
    multiLine: true,
  );
  return {
    for (final file in _scripts().where(
      (f) => f.uri.pathSegments.contains('functions'),
    ))
      for (final m in export.allMatches(file.readAsStringSync())) m.group(1)!,
  };
}

/// The names a module binds itself: imports and top-level declarations.
Set<String> _boundNames(String source) {
  final names = <String>{};

  final named = RegExp(r'import\s*\{([^}]*)\}\s*from', multiLine: true);
  for (final m in named.allMatches(source)) {
    for (final part in m.group(1)!.split(',')) {
      final words = part.trim().split(RegExp(r'\s+'));
      if (words.first.isNotEmpty) names.add(words.last);
    }
  }

  final single = RegExp(
    r'import\s+(?:\*\s+as\s+)?([A-Za-z_$][\w$]*)\s*(?:,|from)',
  );
  names.addAll(single.allMatches(source).map((m) => m.group(1)!));

  final declared = RegExp(
    r'(?:function\s+|(?:const|let|var)\s+)([A-Za-z_$][\w$]*)',
  );
  names.addAll(declared.allMatches(source).map((m) => m.group(1)!));

  return names;
}

void main() {
  group('dna/scripts', () {
    test('every script exists', () {
      expect(_scripts(), isNotEmpty);
    });

    test('imports every function it calls', () {
      final callable = {..._nodeFunctions, ..._sharedExports()};
      final missing = <String>[];

      for (final file in _scripts()) {
        final source = file.readAsStringSync();
        final bound = _boundNames(source);
        for (final name in callable) {
          final call = RegExp('(?<![.\\w\$])${RegExp.escape(name)}\\s*\\(');
          if (call.hasMatch(source) && !bound.contains(name)) {
            missing.add('${file.path}: $name');
          }
        }
      }

      expect(missing, isEmpty, reason: 'called without an import');
    });

    test('parses with node --check', () {
      for (final file in _scripts()) {
        final result = Process.runSync('node', ['--check', file.path]);
        expect(result.exitCode, 0, reason: '${file.path}: ${result.stderr}');
      }
    });
  });
}
