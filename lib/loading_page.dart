import 'dart:io';
import 'package:after_layout/after_layout.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:daily_slide/training_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class LoadingPage extends StatefulWidget {
  @override
  State createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
  with AfterLayoutMixin<LoadingPage> {

  Future<int> uploadToFirebase() async {

    // Check storage permission
    var permissionStatus = await Permission.storage.status;
    print('Permission is ${permissionStatus.toString()}');
    if (permissionStatus != PermissionStatus.granted) {
      await Permission.storage.request().isGranted;
    }

    Directory appUploadedDocDir = await getExternalStorageDirectory();
    Directory appTempDocDir = Directory("${appUploadedDocDir.path}/temp/");

    if (! await appTempDocDir.exists()) {
      await appTempDocDir.create(recursive: true);
    }

    await for (var f in appTempDocDir.list()) {
      if (f.toString().endsWith('txt\'')) {
        String filename = Path.basename(f.path);
        print('File under process: $filename');
        if(filename == 'null.txt') {
          debugPrint('null found!');
          f.delete();
          continue;
        }

        int patientNr = int.parse(filename.split(' ').first);
        bool isDual = filename.split('_').last.startsWith("dual");
        UploadTask task = FirebaseStorage.instance.ref().child(isDual
              ? '/Dual $patientNr/$filename'
              : '/Single $patientNr/$filename').putFile(f);
        task
          .then((TaskSnapshot snapshot) {
            // Move file in temp directory to external directory and delete it
            File('${appTempDocDir.path}/$filename').copySync('${appUploadedDocDir.path}/$filename');
            f.delete();
            print('Upload successful!');
          })
          .catchError((Object e) {
            print('Error during uploading: ${e.toString()}');
            print('Something went wrong! Data might not fully uploaded...');
          });
      }
    }

    return 0;
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi) {
      await uploadToFirebase();
//      Directory appDocDir = await getApplicationDocumentsDirectory();
//      await for(var f in appDocDir.list()){
//        print(f.toString());
//      }
    } else {
      print('NO WIFI');
    }
    final TrainingPageArguments args = ModalRoute.of(context).settings.arguments;
    Navigator.pushReplacementNamed(context, '/instructions', arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {return false;},
      child: Scaffold(
        appBar: AppBar(
          title: Text(''),
        ),
        backgroundColor: Color(0xFF474747),
        body: Container(
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.all(80.0),
          child:
              Text('Even geduld...', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 50),),
        ),
      ),
    );
  }
}