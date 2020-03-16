import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LoadingPage extends StatefulWidget {


  @override
  State createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {

//  Future<int> uploadToFirebase(int patientNr, int day) async {
//    var date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
//    String path = '/$patientNr/$patientNr $date Day$day.txt';
//
//    final StorageReference ref = FirebaseStorage().ref().child(path);
//    var uploadTask = ref.putFile(await widget._logger.getLogFile());
//    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
//
//    return taskSnapshot.error == null ? 0 : -1;
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      backgroundColor: Color(0xFF474747),
      body: Container(
        alignment: Alignment.bottomRight,
        padding: const EdgeInsets.all(40.0),
        child: Text('Please wait...', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 50),),
      ),
    );
  }
}