import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:daily_slide/count_result_page.dart';
import 'package:daily_slide/loading_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'instruction_page.dart';
import 'training_page.dart';
import 'package:flutter/services.dart';
import 'settings_page.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as Path;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    return MaterialApp(
      title: 'Daily Slide Test',
      theme: ThemeData(
//        primarySwatch: Colors.blueAccent[300],
        primaryColor: Colors.blue[200]
      ),
      home: MyHomePage(title: 'Daily Slide'),
      routes: {
        '/training': (context) => TrainingPage(),
        '/settings': (context) => SettingsPage(),
        '/loading' : (context) => LoadingPage(),
        '/countResult': (context) => CountResultPage(),
        '/instructions': (context) => InstructionPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  static final Color buttonColor = Colors.grey;
//  static final Color textColor = Colors.white;

  int patientNr;

  @override
  void initState() {
    super.initState();
      () async {
      await Future.delayed(Duration.zero);
      final prefs = await SharedPreferences.getInstance();
      patientNr = prefs.getInt('patientNr') ?? -2;
    }();

    print('Got patient Nr in initState() is $patientNr\n');
    // TODO patientNr is null here somehow but it's correct in the beginning of Build()
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Color(0xFF5C5C5C),
      resizeToAvoidBottomPadding: false,
      drawer: Drawer(
        child: Container(
          decoration: new BoxDecoration(color: Color(0xFF474747)),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
//                color: Colors.blue,
                  image: DecorationImage(
                    image: AssetImage('assets/KU_Leuven.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Text(
                  'Researcher page',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontStyle: FontStyle.italic,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.settings, color: Colors.white70,),
                title: Text('Settings', style: TextStyle(color: Colors.white),),
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Please enter password:'),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: TextFormField(
                                  obscureText: true,
                                  validator: (value) {
                                    if(value.isEmpty) {
                                      return 'Please enter the password';
                                    } else if (sha256.convert(utf8.encode(value)).toString() == '22eeb1a9473d7a35564b883ee49aaf21d3709642d5ade76b663b897cfeda924b') {
                                      return null;
                                    }
                                    return 'Incorrect password';
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: FlatButton(
                                      child: Text("CANCEL", style: TextStyle(color: Colors.red),),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: FlatButton(
                                      child: Text("ENTER", style: TextStyle(color: Colors.red),),
                                      onPressed: () {
                                        if (_formKey.currentState.validate()) {
                                          _navigateToSettingsPage(context);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                },
              ),
              ListTile(
                title: Text('Sync Data', style: TextStyle(color: Colors.white),),
                leading: Icon(Icons.sync, color: Colors.white70,),
                onTap: () async {
                  Navigator.pop(context);
                  String syncInfo = 'Data sync successfully!';
                  var connectivityResult = await (Connectivity().checkConnectivity());
                  if(connectivityResult == ConnectivityResult.wifi) {
                    // Check storage permission
                    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
//                    print('Permission is ${permission.value}');
                    if(permission.value != PermissionStatus.granted.value) {
                      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
                    }

                    final dirUploaded = '/storage/emulated/0/PDlabTest/';
                    if(! await Directory(dirUploaded).exists()) {
                      await Directory(dirUploaded).create(recursive: true);
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
                  } else {
                    syncInfo = 'No internet!';
                  }

                  _scaffoldKey.currentState.hideCurrentSnackBar();
                  _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        syncInfo,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.arrow_back, color: Colors.white70,),
                title: Text('Close', style: TextStyle(color: Colors.white),),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child:
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ButtonTheme(
              height: 80,
              minWidth: 200,
              child: RaisedButton(
                child: Text(
                  'Start Test',
                  style: const TextStyle(fontSize: 46, color: Colors.white),
                ),
                padding: EdgeInsets.all(26.0),
                color: buttonColor,
                onPressed: () {
                  Navigator.pushNamed(context, '/loading', arguments: TrainingPageArguments(patientNr));
                },
              ),
            ),
          ),
      ),
    );
  }

  _navigateToSettingsPage(BuildContext context) async {
    final result = await Navigator.pushNamed(context, '/settings', arguments: SettingsPageArguments(patientNr));
    if(result != null) {
      patientNr = result;
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('patientNr', patientNr);
    }
    Navigator.pop(context);
  }
}

// DoneTODO: change the font, color...
// DoneTODO: Show feedback at the end of training.
// DoneTODO: block the training every 12 hours
// DoneTODO: tip, other help info...
// DoneTODO: preference of dropbox account name?
// DoneTODO: speed of showing the pattern?
// DoneTODO: block back and menu during training

/*
* Donetodo 1. Show the pattern always on the side.
* Donetodo 2. Timing in ms for each trying
* Donetodo p, Good/wrong, date, .
* Donetodo 3. Daily different training.
* Donetodo 4. Show how many times remaining.
* Donetodo 5. Indicate patient on file name.
* 6.
* */

/*
* bg color:
* disable back button during traininng
* show the first circle
* */