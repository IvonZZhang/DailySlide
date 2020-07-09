import 'dart:io';
import 'package:after_layout/after_layout.dart';
import 'package:connectivity/connectivity.dart';
import 'package:daily_slide/training_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;
import 'package:permission_handler/permission_handler.dart';

class LoadingPage extends StatefulWidget {
  @override
  State createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
  with AfterLayoutMixin<LoadingPage> {

  Future<int> uploadToFirebase() async {

    // Check storage permission
    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
//    print('Permission is ${permission.value}');
    if(permission.value != PermissionStatus.granted.value) {
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    }

    if(! await Directory('/storage/emulated/0/PDlabTest/').exists()) {
      await Directory('/storage/emulated/0/PDlabTest/').create(recursive: true);
    }

    if(! await Directory('/storage/emulated/0/PDlabTest/temp/').exists()) {
      await Directory('/storage/emulated/0/PDlabTest/temp/').create(recursive: true);
    }

    Directory appDocDir = Directory('/storage/emulated/0/PDlabTest/temp/');
    await for (var f in appDocDir.list()) {
      if (f.toString().endsWith('txt\'')) {
        String filename = Path.basename(f.path);
        print('File under process: $filename');
        if(filename == 'null.txt') {
          debugPrint('null found!');
          f.delete();
          continue;
        }
        try {
          int patientNr = int.parse(filename.split(' ').first);
          final StorageReference ref = FirebaseStorage().ref().child('/Test $patientNr/$filename');
          var uploadTask = ref.putFile(f);
          StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

          if(taskSnapshot.error == null) {
            // Move file in temp directory to external directory and delete it
            File('/storage/emulated/0/PDlabTest/temp/$filename').copySync('/storage/emulated/0/PDlabTest/$filename');
            await f.delete();
            print('Upload successful!');
          } else {
            print('Error during uploading!');
          }
        } catch (Exception) {
          print(Exception.toString());
          print('Something went wrong! Data might not fully uploaded...');
//                          syncInfo = 'Something went wrong! Data might not fully uploaded...';
          continue;
        }
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