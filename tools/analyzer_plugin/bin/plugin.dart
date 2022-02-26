import 'dart:isolate';

import 'package:code_sharp/code_sharp.dart';

void main(List<String> args, SendPort sendPort) => start(args, sendPort);