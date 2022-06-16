/// Reference: https://github.com/dart-lang/linter/blob/master/tool/doc.dart

import 'dart:async';
import 'dart:io';

import 'package:analyzer/src/lint/config.dart';
import 'package:analyzer/src/lint/registry.dart';
import 'package:args/args.dart';
import 'package:code_sharp/src/lint_rule/lint_rule.dart';
import 'package:github/github.dart';
import 'package:http/http.dart' as http;
import 'package:linter/src/analyzer.dart';
import 'package:markdown/markdown.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';
import 'machine.dart';
import 'since.dart';

/// Generates lint rule docs for publishing to https://dart-lang.github.io/
void main(List<String> args) async {
  var parser = ArgParser()
    ..addOption('out', abbr: 'o', help: 'Specifies output directory.')
    ..addOption('token', abbr: 't', help: 'Specifies a github auth token.');

  ArgResults options;
  try {
    options = parser.parse(args);
  } on FormatException catch (err) {
    printUsage(parser, err.message);
    return;
  }

  var outDir = options['out'] as String? ?? path.join(Directory.current.path, 'doc');

  var token = options['token'];
  var auth = token is String ? Authentication.withToken(token) : null;

  await generateDocs(outDir, auth: auth);
}

const homePage = 'https://github.com/Nomeleel/';
const repository = 'https://github.com/Nomeleel/code_sharp/';
const coreLintRules = 'https://github.com/Nomeleel/code_sharp/blob/main/lib/core.yaml';
const recommendedLintRules = 'https://github.com/Nomeleel/code_sharp/blob/main/lib/recommended.yaml';
const flutterLintRules = 'https://github.com/Nomeleel/code_sharp/blob/main/lib/flutter.yaml';

const ruleFootMatter = '''
In addition, rules can be further distinguished by *maturity*.  Unqualified
rules are considered stable, while others may be marked **experimental**
to indicate that they are under review.  Lints that are marked as **deprecated**
should not be used and are subject to removal in future Linter releases.

Rules can be selectively enabled in the analyzer using
[analysis options](https://pub.dev/packages/analyzer)
or through an
[analysis options file](https://dart.dev/guides/language/analysis-options#the-analysis-options-file).

* **An auto-generated list enabling all options is provided [here](options/options.html).**

As some lints may contradict each other, only a subset of these will be
enabled in practice, but this list should provide a convenient jumping-off point.

Many lints are included in various predefined rulesets:

* [core]($coreLintRules) for official "core" Dart team lint rules.
* [recommended]($recommendedLintRules) for additional lint rules "recommended" by the Dart team.
* [flutter]($flutterLintRules) for rules recommended for Flutter projects (`flutter create` enables these by default).

Rules included in these rulesets are badged in the documentation below.

These rules are under active development.  Feedback is
[welcome](https://github.com/Nomeleel/code_sharp/issues)!
''';

const ruleLeadMatter = 'Rules are organized into familiar rule groups.';

final coreRules = <String?>[];
final flutterRules = <String?>[];
final recommendedRules = <String?>[];

late final List<LintRule> rules;

late Map<String, SinceInfo> sinceInfo;

String get enumerateErrorRules =>
    rules.where((r) => r.group == Group.errors).map(toDescription).join('\n\n');

String get enumerateGroups => Group.builtin
    .map((Group g) =>
        '<li><strong>${g.name} -</strong> ${markdownToHtml(g.description)}</li>')
    .join('\n');

String get enumeratePubRules =>
    rules.where((r) => r.group == Group.pub).map(toDescription).join('\n\n');

String get enumerateStyleRules =>
    rules.where((r) => r.group == Group.style).map(toDescription).join('\n\n');

String describeMaturity(LintRule r) =>
    r.maturity == Maturity.stable ? '' : ' (${r.maturity.name})';

Future<void> fetchBadgeInfo() async {
  var core = await getLibConfig('core.yaml');
  if (core != null) {
    for (var ruleConfig in core.ruleConfigs) {
      coreRules.add(ruleConfig.name);
    }
  }

  var recommended = await getLibConfig('recommended.yaml');
  if (recommended != null) {
    recommendedRules.addAll(coreRules);
    for (var ruleConfig in recommended.ruleConfigs) {
      recommendedRules.add(ruleConfig.name);
    }
  }

  var flutter = await getLibConfig('flutter.yaml');
  if (flutter != null) {
    flutterRules.addAll(recommendedRules);
    for (var ruleConfig in flutter.ruleConfigs) {
      flutterRules.add(ruleConfig.name);
    }
  }
}

Future<LintConfig?> fetchConfig(String url) async {
  var client = http.Client();
  print('loading $url...');
  var req = await client.get(Uri.parse(url));
  return processAnalysisOptionsFile(req.body);
}

Future<LintConfig?> getLibConfig(String file) async {
  final content = await File(path.join(Directory.current.path, 'lib', file)).readAsString();
  final yaml = loadYamlNode(content);
  if (yaml is YamlMap) {
    final options = yaml['code_sharp'];
    if (options is YamlMap) {
      return LintConfig.parseMap(options);
    }
  }
  return null;
}

Future<void> fetchSinceInfo(Authentication? auth) async {
  sinceInfo = await getSinceMap(auth);
}

void createDirectorySync(Directory directory) => directory.existsSync() ? null : directory.createSync();

Future<void> generateDocs(String? dir, {Authentication? auth}) async {
  var outDir = dir;
  if (outDir != null) {
    var d = Directory(outDir);
    if (!d.existsSync()) {
      print("Directory '${d.path}' does not exist");
      return;
    }
    if (!File('$outDir/options').existsSync()) {
      var lintsChildDir = Directory('$outDir/lints');
      createDirectorySync(lintsChildDir);
      outDir = lintsChildDir.path;
    }
  }

  registerLintRules();

  /// Sorted list of contributed lint rules.
  rules = List<LintRule>.of(Registry.ruleRegistry, growable: false)..sort();

  // Generate lint count badge.
  await CountBadger(Registry.ruleRegistry).generate(outDir);

  // Fetch info for lint group/style badge generation.
  await fetchBadgeInfo();

  // Fetch since info.
  await fetchSinceInfo(auth);

  // Generate rule files.
  for (var l in rules) {
    RuleHtmlGenerator(l).generate(outDir);
    RuleMarkdownGenerator(l).generate(filePath: outDir);
  }

  // Generate index.
  HtmlIndexer(Registry.ruleRegistry).generate(outDir);
  MarkdownIndexer(Registry.ruleRegistry).generate(filePath: outDir);

  // Generate options samples.
  OptionsSample(rules).generate(outDir);

  // Generate a machine-readable summary of rules.
  MachineSummaryGenerator(Registry.ruleRegistry).generate(outDir);
}

String getBadges(String rule) {
  var sb = StringBuffer();
  if (coreRules.contains(rule)) {
    sb.write(
        '<a class="style-type" href="$coreLintRules">'
        '<!--suppress HtmlUnknownTarget --><img alt="core" src="style-core.svg"></a>');
  }
  if (recommendedRules.contains(rule)) {
    sb.write(
        '<a class="style-type" href="$recommendedLintRules">'
        '<!--suppress HtmlUnknownTarget --><img alt="recommended" src="style-recommended.svg"></a>');
  }
  if (flutterRules.contains(rule)) {
    sb.write(
        '<a class="style-type" href="$flutterLintRules">'
        '<!--suppress HtmlUnknownTarget --><img alt="flutter" src="style-flutter.svg"></a>');
  }
  return sb.toString();
}

void printUsage(ArgParser parser, [String? error]) {
  var message = 'Generates lint docs.';
  if (error != null) {
    message = error;
  }

  stdout.write('''$message
Usage: doc
${parser.usage}
''');
}

String qualify(LintRule r) => r.name + describeMaturity(r);

String toDescription(LintRule r) =>
    '<!--suppress HtmlUnknownTarget --><strong><a href = "${r.name}.html">${qualify(r)}</a></strong><br/> ${getBadges(r.name)} ${markdownToHtml(r.description)}';

class CountBadger {
  Iterable<LintRule> rules;

  CountBadger(this.rules);

  Future<void> generate(String? dirPath) async {
    var lintCount = rules.length;

    var client = http.Client();
    var req = await client.get(
        Uri.parse('https://img.shields.io/badge/lints-$lintCount-blue.svg'));
    var bytes = req.bodyBytes;
    await File('$dirPath/count-badge.svg').writeAsBytes(bytes);
  }
}

class HtmlIndexer {
  final Iterable<LintRule> rules;

  HtmlIndexer(this.rules);

  void generate(String? filePath) {
    var generated = _generate();
    if (filePath != null) {
      var outPath = '$filePath/index.html';
      print('Writing to $outPath');
      File(outPath).writeAsStringSync(generated);
    } else {
      print(generated);
    }
  }

  String _generate() => '''
<!DOCTYPE html>
<html lang="en">
   <head>
      <meta charset="utf-8">
      <link rel="shortcut icon" href="../dart-192.png">
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
      <meta name="mobile-web-app-capable" content="yes">
      <meta name="apple-mobile-web-app-capable" content="yes">
      <link rel="stylesheet" href="../styles.css">
      <title>Linter for Dart</title>
   </head>
   <body>
      <div class="wrapper">
         <header>
            <a href="../index.html">
               <h1>Linter for Dart</h1>
            </a>
            <p>Lint Rules</p>
            <ul>
              <li><a href="https://dart.dev/guides/language/analysis-options#enabling-linter-rules">Using the <strong>Linter</strong></a></li>
            </ul>
            <p><a class="overflow-link" href="https://dart.dev/guides/language/analysis-options#enabling-linter-rules">Using the <strong>Linter</strong></a></p>
         </header>
         <section>

            <h1>Supported Lint Rules</h1>
            <p>
               This list is auto-generated from our sources.
            </p>
            ${markdownToHtml(ruleLeadMatter)}
            <ul>
               $enumerateGroups
            </ul>
            ${markdownToHtml(ruleFootMatter)}

            <h2>Error Rules</h2>

               $enumerateErrorRules

            <h2>Style Rules</h2>

               $enumerateStyleRules

            <h2>Pub Rules</h2>

               $enumeratePubRules

         </section>
      </div>
      <footer>
         <p>Maintained by the <a href="$homePage">Nomeleel</a></p>
         <p>Visit us on <a href="$repository">GitHub</a></p>
      </footer>
   </body>
</html>
''';
}

class MachineSummaryGenerator {
  final Iterable<LintRule> rules;

  MachineSummaryGenerator(this.rules);

  void generate(String? filePath) {
    var generated = getMachineListing(rules);
    if (filePath != null) {
      final machineDir = Directory('$filePath/machine');
      createDirectorySync(machineDir);
      var outPath = '${machineDir.path}/rules.json';
      print('Writing to $outPath');
      File(outPath).writeAsStringSync(generated);
    } else {
      print(generated);
    }
  }
}

class MarkdownIndexer {
  final Iterable<LintRule> rules;

  MarkdownIndexer(this.rules);

  void generate({String? filePath}) {
    var buffer = StringBuffer();

    buffer.writeln('# Linter for Dart');
    buffer.writeln();
    buffer.writeln('## Lint Rules');
    buffer.writeln();
    buffer.writeln(
        '[Using the Linter](https://dart.dev/guides/language/analysis-options#enabling-linter-rules)');
    buffer.writeln();
    buffer.writeln('## Supported Lint Rules');
    buffer.writeln();
    buffer.writeln('This list is auto-generated from our sources.');
    buffer.writeln();
    buffer.writeln(ruleLeadMatter);
    buffer.writeln();

    for (var group in Group.builtin) {
      buffer.writeln('- **${group.name}** - ${group.description}');
      buffer.writeln();
    }

    buffer.writeln(ruleFootMatter);
    buffer.writeln();

    void emit(LintRule rule) {
      buffer
          .writeln('**[${rule.name}](${rule.name}.md)** - ${rule.description}');
      if (coreRules.contains(rule.name)) {
        buffer.writeln('[![core](style-core.svg)]($coreLintRules)');
      }
      if (recommendedRules.contains(rule.name)) {
        buffer.writeln('[![recommended](style-recommended.svg)]($recommendedLintRules)');
      }
      if (flutterRules.contains(rule.name)) {
        buffer.writeln('[![flutter](style-flutter.svg)]($flutterLintRules)');
      }
      buffer.writeln();
    }

    buffer.writeln('## Error Rules');
    buffer.writeln();
    // ignore: prefer_foreach
    for (var rule in rules.where((rule) => rule.group == Group.errors)) {
      emit(rule);
    }

    buffer.writeln('## Style Rules');
    buffer.writeln();
    // ignore: prefer_foreach
    for (var rule in rules.where((rule) => rule.group == Group.style)) {
      emit(rule);
    }

    buffer.writeln('## Pub Rules');
    buffer.writeln();
    // ignore: prefer_foreach
    for (var rule in rules.where((rule) => rule.group == Group.pub)) {
      emit(rule);
    }

    if (filePath == null) {
      print(buffer.toString());
    } else {
      File('$filePath/index.md').writeAsStringSync(buffer.toString());
    }
  }
}

class OptionsSample {
  Iterable<LintRule> rules;

  OptionsSample(this.rules);

  void generate(String? filePath) {
    var generated = _generate();
    if (filePath != null) {
      final optionsDir = Directory('$filePath/options');
      createDirectorySync(optionsDir);
      var outPath = '${optionsDir.path}/options.html';
      print('Writing to $outPath');
      File(outPath).writeAsStringSync(generated);
    } else {
      print(generated);
    }
  }

  String generateOptions() {
    var sb = StringBuffer('''
```
linter:
  rules:
''');

    var sortedRules = rules
        .where((r) => r.maturity != Maturity.deprecated)
        .map((r) => r.name)
        .toList()
      ..sort();
    for (var rule in sortedRules) {
      sb.write('    - $rule\n');
    }
    sb.write('```');

    return sb.toString();
  }

  String _generate() => '''
<!DOCTYPE html>
<html lang="en">
   <head>
      <meta charset="utf-8">
      <link rel="shortcut icon" href="../../dart-192.png">
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
      <meta name="mobile-web-app-capable" content="yes">
      <meta name="apple-mobile-web-app-capable" content="yes">
      <link rel="stylesheet" href="../../styles.css">
      <title>Analysis Options</title>
   </head>
  <body>
      <div class="wrapper">
         <header>
            <a href="../../index.html">
               <h1>Linter for Dart</h1>
            </a>
            <p>Analysis Options</p>
            <ul>
              <li><a href="../index.html">View all <strong>Lint Rules</strong></a></li>
              <li><a href="https://dart.dev/guides/language/analysis-options#enabling-linter-rules">Using the <strong>Linter</strong></a></li>
            </ul>
            <p><a class="overflow-link" href="../index.html">View all <strong>Lint Rules</strong></a></p>
            <p><a class="overflow-link" href="https://dart.dev/guides/language/analysis-options#enabling-linter-rules">Using the <strong>Linter</strong></a></p>
         </header>
         <section>

            <h1 id="analysis-options">Analysis Options</h1>
            <p>
               Auto-generated options enabling all lints.
               Add these to your
               <a href="https://dart.dev/guides/language/analysis-options#the-analysis-options-file">analysis_options.yaml file</a>
               and tailor to fit!
            </p>

            ${markdownToHtml(generateOptions())}

         </section>
      </div>
      <footer>
         <p>Maintained by the <a href="$homePage">Nomeleel</a></p>
         <p>Visit us on <a href="$repository">GitHub</a></p>
      </footer>
   </body>
</html>
''';
}

class RuleHtmlGenerator {
  final LintRule rule;

  RuleHtmlGenerator(this.rule);

  String get details => rule.details;

  String get group => rule.group.name;

  String get humanReadableName => rule.name;

  String get incompatibleRuleDetails {
    var sb = StringBuffer();
    var incompatibleRules = rule.incompatibleRules;
    if (incompatibleRules.isNotEmpty) {
      sb.writeln('<p>');
      sb.write('Incompatible with: ');
      var rule = incompatibleRules.first;
      sb.write(
          '<!--suppress HtmlUnknownTarget --><a href = "$rule.html" >$rule</a>');
      for (var i = 1; i < incompatibleRules.length; ++i) {
        rule = incompatibleRules[i];
        sb.write(', <a href = "$rule.html" >$rule</a>');
      }
      sb.writeln('.');
      sb.writeln('</p>');
    }
    return sb.toString();
  }

  String get maturity => rule.maturity.name;

  String get maturityString {
    switch (rule.maturity) {
      case Maturity.deprecated:
        return '<span style="color:orangered;font-weight:bold;" >$maturity</span>';
      case Maturity.experimental:
        return '<span style="color:hotpink;font-weight:bold;" >$maturity</span>';
      default:
        return maturity;
    }
  }

  String get name => rule.name;

  String get since {
    var info = sinceInfo[name]!;
    // See: https://github.com/dart-lang/linter/issues/2824
    // var version = info.sinceDartSdk != null
    //     ? '>= ${info.sinceDartSdk}'
    //     : '<strong>unreleased</strong>';
    //return 'Dart SDK: $version • <small>(Linter v${info.sinceLinter})</small>';
    return 'Linter v${info.sinceLinter}';
  }

  void generate([String? filePath]) {
    var generated = _generate();
    if (filePath != null) {
      var outPath = '$filePath/$name.html';
      print('Writing to $outPath');
      File(outPath).writeAsStringSync(generated);
    } else {
      print(generated);
    }
  }

  String _generate() => '''
<!DOCTYPE html>
<html lang="en">
   <head>
      <meta charset="utf-8">
      <link rel="shortcut icon" href="../dart-192.png">
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
      <meta name="mobile-web-app-capable" content="yes">
      <meta name="apple-mobile-web-app-capable" content="yes">
      <title>$name</title>
      <link rel="stylesheet" href="../styles.css">
   </head>
   <body>
      <div class="wrapper">
         <header>
            <h1>$humanReadableName</h1>
            <p>Group: $group</p>
            <p>Maturity: $maturityString</p>
            <div class="tooltip">
               <p>$since</p>
               <span class="tooltip-content">Since info is static, may be stale</span>
            </div>
            ${getBadges(name)}
            <ul>
               <li><a href="index.html">View all <strong>Lint Rules</strong></a></li>
               <li><a href="https://dart.dev/guides/language/analysis-options#enabling-linter-rules">Using the <strong>Linter</strong></a></li>
            </ul>
            <p><a class="overflow-link" href="index.html">View all <strong>Lint Rules</strong></a></p>
            <p><a class="overflow-link" href="https://dart.dev/guides/language/analysis-options#enabling-linter-rules">Using the <strong>Linter</strong></a></p>
         </header>
         <section>

            ${markdownToHtml(details)}
            $incompatibleRuleDetails
         </section>
      </div>
      <footer>
         <p>Maintained by the <a href="$homePage">Nomeleel</a></p>
         <p>Visit us on <a href="$repository">GitHub</a></p>
      </footer>
   </body>
</html>
''';
}

class RuleMarkdownGenerator {
  final LintRule rule;

  RuleMarkdownGenerator(this.rule);

  String get details => rule.details;

  String get group => rule.group.name;

  String get maturity => rule.maturity.name;

  String get name => rule.name;

  String get since {
    var info = sinceInfo[name]!;
    // See: https://github.com/dart-lang/linter/issues/2824
    // var version = info.sinceDartSdk != null
    //     ? '>= ${info.sinceDartSdk}'
    //     : '**unreleased**';
    // return 'Dart SDK: $version • (Linter v${info.sinceLinter})';
    return 'Linter v${info.sinceLinter}';
  }

  void generate({String? filePath}) {
    var buffer = StringBuffer();

    buffer.writeln('# Rule $name');
    buffer.writeln();
    buffer.writeln('**Group**: $group\\');
    buffer.writeln('**Maturity**: $maturity\\');
    buffer.writeln('**Since**: $since\\');
    buffer.writeln();

    // badges
    if (coreRules.contains(name)) {
      buffer.writeln('[![core](style-core.svg)]($coreLintRules)');
    }
    if (recommendedRules.contains(name)) {
      buffer.writeln('[![recommended](style-flutter.svg)]($recommendedLintRules)');
    }
    if (flutterRules.contains(name)) {
      buffer.writeln('[![flutter](style-flutter.svg)]($flutterLintRules)');
    }

    buffer.writeln();

    buffer.writeln('## Description');
    buffer.writeln();
    buffer.writeln(details.trim());

    // incompatible rules
    var incompatibleRules = rule.incompatibleRules;
    if (incompatibleRules.isNotEmpty) {
      buffer.writeln('## Incompatible With');
      buffer.writeln();
      for (var rule in incompatibleRules) {
        buffer.writeln('- [$rule]($rule.md)');
      }
      buffer.writeln();
    }

    if (filePath == null) {
      print(buffer.toString());
    } else {
      File('$filePath/$name.md').writeAsStringSync(buffer.toString());
    }
  }
}
