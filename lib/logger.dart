import 'dart:io';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class Logger {
  String _filename;

  set filename(String filename) {
    _filename = filename;
  }

  Future<String> get _localPath async {
//    final directory = await getExternalStorageDirectory();
    /*
    * ExternalStorageDirectory: /storage/emulated/0/Android/data/com.ivonzhang.daily_slide/files
    * ExternalStorageDirectories: /storage/emulated/0/Android/data/com.ivonzhang.daily_slide/files
    *                             /storage/18FC-0419/Android/data/com.ivonzhang.daily_slide/files
    * ApplicationSupportDirectory: /data/user/0/com.ivonzhang.daily_slide/files
    * ApplicationDocumentsDirectory: /data/user/0/com.ivonzhang.daily_slide/app_flutter
    * TemporaryDirectory: /data/user/0/com.ivonzhang.daily_slide/cache
    * DownloadsDirectory: Unsupported operation: Functionality not available on Android
    *
    */
    // Check storage permission
    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
    print('Permission is ${permission.value}');
    if(permission.value != PermissionStatus.granted.value) {
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    }

    Directory directory = Directory('/storage/emulated/0/PDlab/temp/');

    if(! await directory.exists()) {
      await directory.create(recursive: true);
    }



    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
//    /data/user/0/com.ivonzhang.daily_slide/app_flutter
    return File('$path/$_filename.txt');
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<File> getLogFile() async {
    return this._localFile;
  }

  Future<String> readLog() async {
    try {
      final file = await _localFile;
      return file.readAsString();
    } catch (e) {
      return e.toString();
    }
  }

  Future<int> writeFileHeader(int patientNr, int dayNr) async {
    final file = await _localFile;
    var sink = file.openWrite(mode: FileMode.write);

    // Write the file
    sink.write('Patient No.$patientNr\n');
    sink.write(DateFormat('yyyy-MM-dd HH:mm:ss\n').format(DateTime.now()));
    sink.write('Training data of Day $dayNr:\n');

    sink.close();
    return 0;
  }

  Future<int> writePatternNr(int patternNr) async {
    final file = await _localFile;
    var sink = file.openWrite(mode: FileMode.append);

    sink.write('\nPattern $patternNr\n');

    sink.close();
    return 0;
  }

  Future<int> writeTrainingResult(int nrOfTrying, bool isSuccess, int duration) async {
    final file = await _localFile;
    var sink = file.openWrite(mode: FileMode.append);

    sink.write('Trying$nrOfTrying ${isSuccess ? 1 : 0} $duration\n');

    sink.close();
    return 0;
  }

  Future<int> writeFileFooter() async {
    final file = await _localFile;
    var sink = file.openWrite(mode: FileMode.append);

    sink.write('\n******End of training******\n');

    sink.close();
    return 0;
  }

  Future<int> writeLine(String str) async {
    final file = await _localFile;
    var sink = file.openWrite(mode: FileMode.append);

    sink.write(str + '\n');

    sink.close();
    return 0;
  }

}
