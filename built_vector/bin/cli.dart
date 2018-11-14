import 'dart:io';
import 'package:args/args.dart';
import 'package:built_vector/generator.dart';
import 'package:built_vector/parser.dart';

void main(List<String> args) async {

  final parser = ArgParser();
  parser.addOption('input', abbr: 'i');
  parser.addOption('output', abbr: 'o');
  final results = parser.parse(args);

  if(results["input"] == null) return print("an input file path must be provided");
  if(results["output"] == null) return print("an ouput file path must be provided");

  // Parsing
  final input = File(results["input"]);
  final content = await input.readAsString();
  final assetsParser = AssetsParser();
  final assets = assetsParser.parse(content);

  // Generating
  final output = File(results["output"]);
  final generator = FlutterGenerator();
  final outputContent = generator.generate(assets);
  await output.writeAsString(outputContent);
}