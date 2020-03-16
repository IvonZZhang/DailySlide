import 'dart:io';
import 'package:after_layout/after_layout.dart';
import 'package:connectivity/connectivity.dart';
import 'package:daily_slide/training_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as Path;

class LoadingPage extends StatefulWidget {


  @override
  State createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
  with AfterLayoutMixin<LoadingPage> {

  Future<int> uploadToFirebase() async {

    Directory appDocDir = await getApplicationDocumentsDirectory();
    await for (var f in appDocDir.list()) {
      if (f.toString().endsWith('txt\'')) {
        String filename = Path.basename(f.path);
        try {
          int patientNr = int.parse(filename.split(' ').first);
          final StorageReference ref = FirebaseStorage().ref().child('/$patientNr/$filename');
          var uploadTask = ref.putFile(f);
          StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

          if(taskSnapshot.error == null) {
            // Delete file
            await f.delete();
          } else {
            print('Error during uploading!');
          }
        } catch (Exception) {
          print(Exception.toString());
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
    Navigator.pushReplacementNamed(context, '/training', arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      backgroundColor: Color(0xFF474747),
      body: Container(
        alignment: Alignment.bottomRight,
        padding: const EdgeInsets.all(80.0),
        child:
            Text('Please wait...', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 50),),
      ),
    );
  }
}