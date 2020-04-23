import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'pattern_lock.dart';
import 'dart:async';
import 'logger.dart';
import 'package:after_layout/after_layout.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:intl/intl.dart';

class TrainingPageArguments {
  final int dayNr;
  final int patientNr;

  TrainingPageArguments(this.dayNr, this.patientNr);
}

class TrainingPage extends StatefulWidget {

  final List<List<int>> patterns = [
    [7, 6, 3, 0, 4, 1, 5],
    [7, 4, 8, 5, 2, 1, 3],
    [7, 3, 4, 0, 1, 2, 5]
  ];
  final List<List<int>> sequence = [
    [1, 2, 3, 2, 2, 1, 3, 1, 3],
    [1, 3, 3, 1, 2, 2, 1, 2, 3],
    [1, 1, 2, 3, 1, 3, 2, 3, 2],
    [1, 3, 1, 2, 3, 3, 2, 2, 1]
  ];

  final Logger _logger = Logger();

  @override
  _TrainingPageState createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage>
    with AfterLayoutMixin<TrainingPage> {

  // Constants
  static final int exampleTimeMs = 800;
  static final int waitingTimeMs = 14;

  static final Color bgColor = Color(0xFF5C5C5C);
  static final Color regularTextColor = Colors.blueGrey[50];
  static final Color selectedCircleColor = Color(0xFF092E6B);
  static final Color notSelectedCircleColor = Color(0xFFA0B8DC);
  static final Color feedbackTextColor = Colors.deepOrange;
  static final Color exampleTextColor = Color(0xCF092E6B);
  static final Color snackBarTextColor = Colors.white;

  // Nr of node left during showing
  int nodeLeft = 7;

  // Temp pattern in showing
  List<int> tempPattern = [];

  // Seconds left during resting
  int restSec = waitingTimeMs;

  Timer _timerPeriod;
  Timer _restTimerPeriod;

  // The index of pattern in a series/sequence
  int patternNr = 0;

  // The index of day/sequence
  int day = -1;

  // The nr of trying (max 12)
  int trying = 1;

  // Text on the top for general notifications
  Text notificationText = Text('Kijk naar het voorbeeldpatroon aan de linkerkant van het scherm.',
                                style: TextStyle(fontSize: 46, color: regularTextColor),
                                textAlign: TextAlign.center,);

  // Text in the middle for feedback of a training
  Text feedbackText = Text(' ', style: TextStyle(fontSize: 30));

  // Is training pattern touchable or not
  bool isTraining = false;

  // Is example pattern is visible or not
  bool isResting = false;

  DateTime currentBackPressTime;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final trainingPatternKey = GlobalKey<PatternLockState>();
  final showingPatternKey = GlobalKey<PatternLockState>();

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    final TrainingPageArguments args = ModalRoute.of(context).settings.arguments;
    var date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    var patientNr = args.patientNr;
    widget._logger.filename = '$patientNr $date Day$day';
    await widget._logger.writeFileHeader(args.patientNr, day); // DoneTODO: patient nr
    showPatternExample();
  }

  void showPatternExample() => _timerPeriod =
          new Timer.periodic(new Duration(milliseconds: exampleTimeMs), (Timer timer) {
        if (nodeLeft == 0) {
          _timerPeriod.cancel();
          nodeLeft = 7;
          widget._logger.writePatternNr(patternNr + 1);

          setState(() => notificationText = Text(
              'Probeer dit patroon na te maken aan de rechterkant van het scherm.',
              style: TextStyle(fontSize: 46, color: regularTextColor),
              textAlign: TextAlign.center,));
          isTraining = true;
          return;
        }

        tempPattern.add(widget.patterns[widget.sequence[day - 1][patternNr] - 1]
            [7 - nodeLeft--]);
        showingPatternKey.currentState.setState(
            () => showingPatternKey.currentState.setUsed(tempPattern));
      });

  void takeARest() => _restTimerPeriod =
          new Timer.periodic(new Duration(seconds: 1), (Timer timer) {
        --restSec;
        setState(() {
          notificationText = Text(
            'Even rust: $restSec',
            style: TextStyle(fontSize: 46, color: regularTextColor),
            textAlign: TextAlign.center,
          );
        });

        if (restSec == (waitingTimeMs - 1)) {
          setState(() {
            feedbackText = Text(
              ' ',
              style: TextStyle(fontSize: 30, color: regularTextColor),
            );
            isResting = true;
            showingPatternKey.currentState
              .setState(() => showingPatternKey.currentState.setUsed([]));
          });
        }

        if (restSec == 0) {
          _restTimerPeriod.cancel();
          restSec = waitingTimeMs;
          tempPattern = [];
          setState(() {
            ++patternNr;
            isResting = false;
            notificationText = Text('Kijk naar het patroon.',
                style: TextStyle(fontSize: 46, color: regularTextColor),
                textAlign: TextAlign.center,);
            feedbackText = Text(' ');

          });
          new Timer(new Duration(seconds: 1), () {
            showPatternExample();
          });
        }
      });

  @override
  void dispose() {
    super.dispose();
    if (_timerPeriod != null) {
      _timerPeriod.cancel();
    }
    if (_restTimerPeriod != null) {
      _restTimerPeriod.cancel();
    }
  }

//  Future<int> upload(int patientNr) async {
////    return uploadToDbx(patientNr);
//    return uploadToFirebase(patientNr);
//  }
//
//  Future<int> uploadToFirebase(int patientNr) async {
//    var date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
//    String path = '/$patientNr/$patientNr $date Day$day.txt';
//
//    final StorageReference ref = FirebaseStorage().ref().child(path);
//    var uploadTask = ref.putFile(await widget._logger.getLogFile());
//    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
//
//    return taskSnapshot.error == null ? 0 : -1;
//  }

//  Future<int> uploadToDbx(int patientNr) async {
//    var date = DateFormat('yyyy-MM-dd HH:mm:ss\n').format(DateTime.now());
//    // Get upload link
//    var urlGetLink =
//        'https://api.dropboxapi.com/2/files/get_temporary_upload_link';
//    var headersGetLink = {
//      'Authorization':
//          'Bearer wHGP8A-xg1AAAAAAAAAAGZXdv9qzFMWsVgmM7KwWxoZ617nh6ykiRbsHRllB21Pa',
//      'Content-Type': 'application/json'
//    };
//    var dataGetLink = {
//      'commit_info': {
//        'path': '/$patientNr/$patientNr $date Day$day.txt',
//        'mode': 'add',
//        'autorename': true,
//        'mute': false,
//        'strict_conflict': false
//      },
//      'duration': 3600
//    };
//
//    var responseLink = await http.post(urlGetLink,
//        headers: headersGetLink, body: jsonEncode(dataGetLink));
//
//    // Upload the log file
//    var urlUpload = jsonDecode(responseLink.body)['link'];
//    print(urlUpload);
//    String dataUpload = await widget._logger.readLog();
//
//    final request = await HttpClient().postUrl(Uri.parse(urlUpload));
//    request.headers
//        .set(HttpHeaders.contentTypeHeader, "application/octet-stream");
//    request.write(dataUpload);
//    final response = await request.close();
//
//    return response.statusCode;
//  }

  Future<bool> showExitDialog() async {
    return await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        widget._logger.writeLine('Emergency button pushed.');
        return AlertDialog(
          title: Text('Bent u zeker dat u het programma wil afsluiten?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('De onvoltooide training zal niet worden geregistreerd.'),
//                            Text('You\’re like me. I’m never satisfied.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('NEE'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('JA'),
              onPressed: () async {
                await widget._logger.writeLine('Training stopped by emergency button.');
                await widget._logger.writeFileFooter();
                Navigator.of(context).popUntil(ModalRoute.withName('/'));
//                            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final TrainingPageArguments args = ModalRoute.of(context).settings.arguments;
    day = args.dayNr;

    return WillPopScope(
      onWillPop: showExitDialog,
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text("Training"),
        ),
        backgroundColor: bgColor,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: RaisedButton(
                  child: Text('Exit training', style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.bold),),
                  color: Colors.red,
                  onPressed: () {
                    showExitDialog();
                  },),
              )
            ),
            Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Spacer(
                flex: 1,
              ),
              Flexible(
                flex: 4,
                child:
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: notificationText,
                      ),
                      Text(isTraining?'Doe dit zo snel en accuraat als mogelijk.':'', style: TextStyle(fontSize: 30, color: Colors.white54),),
                    ],
                  ),
              ),
              Flexible(
                flex: 2,
                child: feedbackText,
              ),
              Flexible(
                flex: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Center(
                        child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Visibility(
                            visible: !isResting,
                            child: PatternLock(
                              key: showingPatternKey,
                              selectedColor: selectedCircleColor,
                              notSelectedColor: notSelectedCircleColor,
                              pointRadius: 27,
                              fillPoints: true,
                              onInputComplete: (List<int> input, int duration) {},
                            ),
                          ),
                          Image(
                            image: AssetImage('assets/transparent.png')
                          ),
                          Positioned(
                            bottom: 40,
                            right: 200,
                            child: Visibility(
                              visible: !isResting,
                              child: Text(
                                'Voorbeeld',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                    color: exampleTextColor),
                              ),
                            ),
                          ),
                        ],
                      )),
                    ),
                    Flexible(
                      flex: 1,
                      child: Center(
                        child: Visibility(
                          visible: isTraining,
                          child: PatternLock(
                            key: trainingPatternKey,
                            selectedColor: selectedCircleColor,
                            notSelectedColor: notSelectedCircleColor,
                            pointRadius: 27,
                            fillPoints: true,
                            onInputComplete:
                                (List<int> input, int duration) async {
                              setState(() {
                                feedbackText = listEquals(input, tempPattern)
                                    ? Text(
                                        'Perfect!',
                                        style: TextStyle(
                                            fontSize: 30,
                                            color: feedbackTextColor,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : Text(
                                        'Helaas niet helemaal juist...',
                                        style: TextStyle(
                                            fontSize: 30,
                                            color: feedbackTextColor,
                                            fontWeight: FontWeight.bold),
                                      );
                                notificationText = trying % 2 == 0
                                    ? Text(
                                        'Probeer dit patroon na te maken.          Resterende herhalingen: ' +
                                            (12 - trying).toString(),
                                        style: TextStyle(fontSize: 46, color: regularTextColor),
                                        textAlign: TextAlign.center,)
                                    : Text(
                                        'Probeer dit patroon nogmaals na te maken. Resterende herhalingen: ' +
                                            (12 - trying).toString(),
                                        style: TextStyle(fontSize: 46, color: regularTextColor),
                                        textAlign: TextAlign.center,
                                      );
                              });

                              await widget._logger.writeTrainingResult(trying,
                                  listEquals(input, tempPattern), duration);

                              if (trying == 12) {
                                isTraining = false;
                                if (patternNr == 8) {
                                  await widget._logger.writeFileFooter();
                                  new Timer(
                                      Duration(seconds: 1),
                                      () => setState(() => feedbackText = Text(
                                            'Training voltooid! Exiting...',
                                            style: TextStyle(
                                                fontSize: 30,
                                                color: regularTextColor,
                                                fontWeight: FontWeight.bold),
                                          )));
//                                  String syncInfo = await upload(args.patientNr) == 0 // DoneTODO: patientNr
//                                      ? 'Data sync successfully!'
//                                      : 'Data sync failed.';
//                                  scaffoldKey.currentState.hideCurrentSnackBar();
//                                  scaffoldKey.currentState.showSnackBar(
//                                    SnackBar(
//                                      content: Text(
//                                        syncInfo,
//                                        style: TextStyle(color: snackBarTextColor),
//                                      ),
//                                    ),
//                                  );
                                  new Timer(Duration(seconds: 2),
                                      () => Navigator.pop(context));
                                  return;
                                }

                                setState(() {
                                  notificationText = Text(
                                    'Even rust: $waitingTimeMs',
                                    style: TextStyle(fontSize: 46, color: regularTextColor),
                                    textAlign: TextAlign.center,
                                  );
                                });
                                takeARest();
                                trying = 1;
                              } else {
                                ++trying;
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
