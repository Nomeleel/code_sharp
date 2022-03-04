import 'package:analyzer_plugin/plugin/plugin.dart';

mixin SeasonableAnalysisMixin on ServerPlugin {
  @override
  void contentChanged(String path) {
    driverForPath(path)?.addFile(path);
  }
}
