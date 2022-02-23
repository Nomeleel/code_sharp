
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/utilities/fixes/fix_contributor_mixin.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

class DartFixContributor extends FixContributor with FixContributorMixin{
  
  @override
  Future<void> computeFixesForError(AnalysisError error) async {
    // TODO(Nomeleel): imp
    if (error.errorCode.name == '') {

    }
  }

}