import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class Logger {
  String _filename;

  Logger(this._filename);

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
//    /data/user/0/com.ivonzhang.daily_slide/app_flutter
    return File('$path/$_filename.txt'); // TODO: change file name
  }

//  Future<int> readCounter() async {
//    try {
//      final file = await _localFile;
//
//      // Read the file
//      String contents = await file.readAsString();
//
//      return int.parse(contents);
//    } catch (e) {
//      // If encountering an error, return 0
//      return 0;
//    }
//  }

  void writeFileHeader(int patientNr, int dayNr) async {
    final file = await _localFile;
    var sink = file.openWrite(mode: FileMode.write);

    // Write the file
    sink.write('Patient No.$patientNr\n');
    sink.write(DateFormat('yyyy-MM-dd HH:mm:ss\n').format(DateTime.now()));
    sink.write('Training data of Day $dayNr:\n');

    sink.close();
  }

  void writePatternNr(int patternNr) async {
    final file = await _localFile;
    var sink = file.openWrite(mode: FileMode.append);

    sink.write('\nPattern $patternNr\n');

    sink.close();
  }

  void writeTrainingResult(int nrOfTrying, bool isSuccess, int duration) async {
    final file = await _localFile;
    var sink = file.openWrite(mode: FileMode.append);

    sink.write('Trying$nrOfTrying ${isSuccess ? 1 : 0} $duration\n');

    sink.close();
  }

  void writeFileFooter() async {
    final file = await _localFile;
    var sink = file.openWrite(mode: FileMode.append);

    sink.write('\n******End of training******\n');

    sink.close();
  }
}
