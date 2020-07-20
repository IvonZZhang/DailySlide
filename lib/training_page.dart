import 'dart:math';

import 'package:daily_slide/count_result_page.dart';
import 'package:daily_slide/painters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'pattern_lock.dart';
import 'dart:async';
import 'logger.dart';
import 'package:after_layout/after_layout.dart';
import 'package:intl/intl.dart';

class TrainingPageArguments {
  final int patientNr;

  TrainingPageArguments(this.patientNr);
}

class TrainingPage extends StatefulWidget {

  final List<List<int>> patterns = [
    [7, 4, 6, 3, 0, 1, 5],
    [7, 8, 5, 2, 4, 1, 3],
    [7, 6, 4, 0, 1, 2, 5],
    [7, 6, 3, 0, 4, 2, 5],
    [7, 5, 4, 2, 1, 0, 3],
    [7, 8, 4, 2, 1, 0, 3]
  ];

  // Pattern number sequence for Day1~Day5
  final List<List<int>> sequence = [
    [1, 2, 3],
    [],
    [4, 5, 6]
  ];

  final Logger _logger = Logger();

  @override
  _TrainingPageState createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage>
  with AfterLayoutMixin<TrainingPage> {

  // Constants
  static final int exampleTimeMs = 80; // 800
  static final int waitingTimeMs = 4; // 14
  static final int totalLights = 30;
  static final int lightsCycleTimeInSec = 3; // 3
  static final int lightsOnTimeInMillisec = 500; // 500
  static final int delayBetweenExampleAndFirstLightInSec = 2; // 2
  static final int lastFeedbackTimeInSec = 2;
  static final int pureCountingTaskTimeInSec = 10; // 30
  static final double notificationTextSize = 30.0;
  static final double remainingNrTextSize = 23.0;
//  static final double feedbackTextSize = 33.0;

  static final Color bgColor = Color(0xFF5C5C5C);
  static final Color regularTextColor = Colors.blueGrey[50];
  static final Color selectedCircleColor = Color(0xFF092E6B);
  static final Color notSelectedCircleColor = Color(0xFFA0B8DC);
//  static final Color feedbackTextColor = Colors.deepOrange;
  static final Color exampleTextColor = Color(0xCF092E6B);

//  static final Color snackBarTextColor = Colors.white;

  // Nr of node left during showing
  int nodeLeft = 7;

  // Temp pattern in showing
  List<int> tempPattern = [];

  // Seconds left during resting
  int restSec = waitingTimeMs;

  Timer _timerPeriod;
  Timer _restTimerPeriod;
  Timer _lightsTimerPeriod;
  int lightsCounter = 0;

  // The index of pattern in a series/sequence
  int patternNr = 0;

  // Phase 1: Pattern tracing only.
  // Phase 2: Lights counting only.
  // Phase 3： Dual task
  int phase = 1;

  // The nr of trying (max 12)
  int trying = 1;

  // The nr of correctly redrawn trials in a set
  int nrOfCorrectTrial = 0;

  // Text on the top for general notifications
  Text notificationText = Text(
    'Probeer dit patroon zo snel en accuraat mogelijk na\n te maken aan de rechterkant van het scherm.',
    style: TextStyle(fontSize: notificationTextSize, color: regularTextColor),
    textAlign: TextAlign.center,);

  // Text in the middle for feedback of a training
  Text feedbackText = Text(' ', style: TextStyle(fontSize: 30));

  // Text indicating how many trials left
  Text remainingNrText = Text('');

  // Text showing which color should be counted
  List<TextSpan> countColorText;

  // Is training pattern touchable or not
  bool isTraining = false;

  // Is example pattern is visible or not
  bool isResting = false;

  int answer = 0; // correct answer for counting task

  // The last answered number for counting task, 0 means no task has been performed
  int answeredNr = 0;

  bool greenLightsOn = false;
  bool redLightsOn = false;

  // Are lights visible or not
  bool isCounting = false;

  // Current target light being counted is green (true) or red (false)
  bool isCountingGreen = true;

  List<int> lightSequence = [];
  
  // Difference can be: Text saying red/green, Circles, Feedback text on counting, Log, Result page
  bool doCounting = false;
  bool doPattern = true;

  // Location offset for two lights
  static final double topOffsetLights = 330.0; //330
  static final double leftOffsetLights = 510.0; //510
  static final double offsetBetweenLights = 80.0; //80

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final trainingPatternKey = GlobalKey<PatternLockState>();
  final showingPatternKey = GlobalKey<PatternLockState>();

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> generateLightsSequence() async {
    List<int> greenIndices = [];
    for (int i = 0; i < totalLights / 2 - 1; ++i) {
      var index;
      while (true) {
        index = Random().nextInt(totalLights - 1);
        if (!greenIndices.contains(index)) {
          break;
        }
      }
      greenIndices.add(index);
    }
    greenIndices.add(totalLights - 1);

    lightSequence.clear();
    for (int i = 0; i < totalLights; ++i) {
      lightSequence.add(greenIndices.contains(i) ? 1 : 0);
    }

    print('lightSequence is $lightSequence');
    print('Its length is ${lightSequence.length}');

    return;
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    final TrainingPageArguments args = ModalRoute.of(context).settings.arguments;
    var date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    var patientNr = args.patientNr;
    widget._logger.filename = '$patientNr $date Test';
    await widget._logger.writeFileHeader(args.patientNr);

//    await generateLightsSequence();
//    if(doPattern) {
//      startPatternExample();
//    } else {
//      startCountingLights();
//    }
    startPatternExample();
  }

  void startCountingLights() {
    setState(() {
      // Decide which color to count
      isCountingGreen = Random().nextBool();
      if (isCountingGreen == false) { // Make sure the last one is the one to be count
        for (int i = 0; i < lightSequence.length; ++i) {
          lightSequence[i] ^= 1; // reverse every bit
        }
      }
      answer = 0;
      lightsCounter = 0;
    });

    if(phase == 2) {
      new Timer(Duration(seconds: pureCountingTaskTimeInSec), () async {
        this._lightsTimerPeriod.cancel();
        await _navigateToResultPage(context, CountResultPageArguments(isCountingGreen, answer));
        updateRestingText();
        takeARest();
      });
    }

    new Timer(Duration(seconds: delayBetweenExampleAndFirstLightInSec), () {
      setState(() {
        // Lit up the correct light
        greenLightsOn = (lightSequence[lightsCounter] == 1);
        redLightsOn = (lightSequence[lightsCounter] == 0);
        feedbackText = Text('   ');
        print('Counter $lightsCounter: green is $greenLightsOn, red is $redLightsOn.');
      });

      new Timer(Duration(milliseconds: lightsOnTimeInMillisec), () {
        setState(() {
          greenLightsOn = redLightsOn = false;
          feedbackText = Text('  ');
        });
      });

      // count appeared
      if ((isCountingGreen && lightSequence[lightsCounter] == 1) ||
        (!isCountingGreen && lightSequence[lightsCounter] == 0)) {
        answer++;
      }

      setState(() {
        lightsCounter++;
      });

      print('Counter $lightsCounter: answer is $answer.');

      this._lightsTimerPeriod = new Timer.periodic(
                        Duration(seconds: lightsCycleTimeInSec), (Timer timer) {
        setState(() {
          // Lit up the correct light
          greenLightsOn = (lightSequence[lightsCounter] == 1);
          redLightsOn = (lightSequence[lightsCounter] == 0);
          feedbackText = Text('   ');
        });
        print('Green lights on: $greenLightsOn, red lights on: $redLightsOn. With lightSequence == ${lightSequence[lightsCounter]}');

        new Timer(Duration(milliseconds: lightsOnTimeInMillisec), () {
          setState(() {
            greenLightsOn = redLightsOn = false;
            feedbackText = Text('  ');
          });
        });

        // count appeared
        if ((isCountingGreen && lightSequence[lightsCounter] == 1) ||
          (!isCountingGreen && lightSequence[lightsCounter] == 0)) {
          answer++;
        }

        setState(() {
          lightsCounter++;
        });

        print('Counter $lightsCounter: answer is $answer.');

        if (lightsCounter == totalLights) {
          print('In "if", reached max lights nr.');
          _lightsTimerPeriod.cancel();
          if (answer != totalLights / 2) {
            print("ERROR: lights stopped but answer is not 15.");
          }
        }
      });
    });
  }

  void startPatternExample() {
    if(doPattern) {
      _timerPeriod = new Timer.periodic(Duration(milliseconds: exampleTimeMs), (Timer timer) {
        if (nodeLeft == 0) {// Example pattern finished
          _timerPeriod.cancel();
          nodeLeft = 7;
          widget._logger.writePatternNr(patternNr + 1);

          setState(() {
            // This setState() must be here to refresh and let show right pattern.
            remainingNrText = Text('\nPatroon: 12/12', style: TextStyle(
              color: regularTextColor, fontSize: remainingNrTextSize,
            ),);
          });

          isTraining = true;
          if(doCounting) {
            startCountingLights();
          }
          return;
        }

        tempPattern.add(widget.patterns[widget.sequence[phase - 1][patternNr] - 1][7 - nodeLeft--]);
        showingPatternKey.currentState.setState(
            () => showingPatternKey.currentState.setUsed(tempPattern));
      });
    }
  }

  void takeARest() {
//    isResting = true;
    isTraining = false;
    isCounting = false;

    _restTimerPeriod = new Timer.periodic(new Duration(seconds: 1), (Timer timer) {
      --restSec;
//      if(doPattern) {
        setState(() {
          notificationText = Text(
            'Even rust: $restSec',
            style: TextStyle(fontSize: 46, color: regularTextColor),
            textAlign: TextAlign.center,
          );
        });
//      }

      if (restSec == 0) {
        _restTimerPeriod.cancel();
        restSec = waitingTimeMs;
        tempPattern = [];
        setState(() {
          ++patternNr;
          print('PatternNr is $patternNr');

          if(patternNr == 3) {
            patternNr = 0;
            if(phase == 1) {
              doCounting = true;
              doPattern = false;
              phase = 2;
              this.widget._logger.writeLine('');
            } else if(phase == 2) {
              doPattern = true;
              doCounting = true;
              phase = 3;
            }
          }

          isResting = false;
          if(doPattern) {
            notificationText = Text('Probeer dit patroon zo snel en accuraat mogelijk na\n te maken aan de rechterkant van het scherm.',
              style: TextStyle(
                fontSize: notificationTextSize, color: regularTextColor),
              textAlign: TextAlign.center,);
          } else {
            notificationText = Text('');
          }

          feedbackText = Text(' ');
          nrOfCorrectTrial = 0;
        });
        
        new Timer(new Duration(microseconds: 1), () async {
          await generateLightsSequence();
          if(doPattern) {
            startPatternExample();
          } else {
            startCountingLights();
          }
        });
        if(phase != 1) {
          isCounting = true;
        }
      }
    });
  }

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
                Text('De onvoltooide testen zal niet worden geregistreerd.'),
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
                await widget._logger.writeLine('Testen stopped by emergency button.');
                await widget._logger.writeFileFooter();
                Navigator.of(context).popUntil(ModalRoute.withName('/'));
              },
            )
          ],
        );
      }
    );
  }

//  List<TextSpan> updateCountColorText(show) {
//    return show ? [
//      TextSpan(text: 'Tel gelijktijdig de '),
//      TextSpan(text: isCountingGreen ? 'groene' : 'rode', style: TextStyle(fontSize: 46, color: isCountingGreen ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
//      TextSpan(text: ' bolletjes.'),
//    ] : [];
//  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: showExitDialog,
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text("Testen"),
        ),
        backgroundColor: bgColor,
        body: Stack(
          children: [
            Positioned(
              top: topOffsetLights,
              left: leftOffsetLights,
              child: CustomPaint(
                painter: DrawCircle(isCounting, greenLightsOn, Colors.green, 10.0, PaintingStyle.fill),
              )
            ),
            Positioned(
              top: topOffsetLights,
              left: leftOffsetLights,
              child: CustomPaint(
                painter: DrawCircle(isCounting, true, Colors.black, 3.0, PaintingStyle.stroke, 32.0),
              ),
            ),
            Positioned(
              top: topOffsetLights + offsetBetweenLights,
              left: leftOffsetLights,
              child: CustomPaint(
                painter: DrawCircle(isCounting, redLightsOn, Colors.red, 10.0, PaintingStyle.fill),
              )
            ),
            Positioned(
              top: topOffsetLights + offsetBetweenLights,
              left: leftOffsetLights,
              child: CustomPaint(
                painter: DrawCircle(isCounting, true, Colors.black, 3.0, PaintingStyle.stroke, 32.0),
              ),
            ),
            Positioned(
              top: 170,
              left: 140,
              child: feedbackText
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Flexible(
                  flex: 7,
                  child:
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: notificationText,
                      ),
                      Visibility(
                        visible: doCounting,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(color: regularTextColor, fontSize: notificationTextSize, fontWeight: FontWeight.normal, fontStyle: FontStyle.normal),
                            children: isResting ? <TextSpan>[] : <TextSpan>[
                              TextSpan(text: (phase == 3) ? 'Tel gelijktijdig de ' : 'Tel de '),
                              TextSpan(text: isCountingGreen ? 'groene' : 'rode', style: TextStyle(fontSize: 46, color: isCountingGreen ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                              TextSpan(text: ' bolletjes.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        child: Center(
                          child: Visibility(
                            visible: doPattern && !isResting,
                            child: Stack(
                              fit: StackFit.expand,
                              children: <Widget>[
                                Center(
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
                                  child: Text(
                                    'Voorbeeld',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: exampleTextColor),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Center(
                          child: Visibility(
                            visible: doPattern && isTraining,
                            child: PatternLock(
                              key: trainingPatternKey,
                              selectedColor: selectedCircleColor,
                              notSelectedColor: notSelectedCircleColor,
                              pointRadius: 27,
                              fillPoints: true,
                              onInputComplete:
                                (List<int> input, int duration) async {
                                setState(() {
                                  remainingNrText = Text('\nPatroon: ' + (12-trying).toString() + '/12', style: TextStyle(
                                    color: regularTextColor, fontSize: remainingNrTextSize,
                                  ),);

                                  if (trying == 12) {
                                    if(doCounting) {
                                      _lightsTimerPeriod.cancel();
                                      print('light timer canceled on 12th finish.');
                                    }
                                    isTraining = false;
                                    isCounting = false;
                                  }
                                });

                                await widget._logger.writeTrainingResult(trying,
                                  listEquals(input, tempPattern), duration);

                                nrOfCorrectTrial += listEquals(input, tempPattern) ? 1 : 0;

                                if (trying == 12) {
                                  if(doCounting) {
                                    await _navigateToResultPage(context, CountResultPageArguments(isCountingGreen, answer));
                                  }

                                  updateRestingText();

                                  if (patternNr == 2 && phase == 3) {// Nr of pattern - 1
                                    setState(() {
                                      notificationText = Text(' ');
                                    });
                                    await widget._logger.writeFileFooter();
                                    new Timer(
                                      Duration(seconds: lastFeedbackTimeInSec),
                                        () => setState(() => feedbackText = Text(
                                        'Testen voltooid! Exiting...',
                                        style: TextStyle(
                                          fontSize: 30,
                                          color: regularTextColor,
                                          fontWeight: FontWeight.bold),
                                      )));
                                    new Timer(Duration(seconds: lastFeedbackTimeInSec + 2),
                                        () => Navigator.pop(context));
                                    return;
                                  }
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
            Positioned(
              top: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    RaisedButton(
                      child: Text('Exit testen', style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.bold),),
                      color: Colors.red,
                      onPressed: () {
                        showExitDialog();
                      },),
                    Visibility(
                      visible: doPattern && !isResting,
                      child: remainingNrText
                    ),
                  ],
                ),
              )
            ),
          ],
        ),
      ),
    );
  }

  void updateRestingText() {
    this.setState(() {
      notificationText = Text(
        'Even rust: $waitingTimeMs',
        style: TextStyle(fontSize: 46, color: regularTextColor),
        textAlign: TextAlign.center,
      );
//      if(doPattern) {
        remainingNrText = Text(' ');
//      }
      if(doPattern) {
        showingPatternKey.currentState.setUsed([]);
      }
      isResting = true;
//      print('doCounting: $doCounting, doPattern: $doPattern');
//      if(doCounting) {
//        if (doPattern) {
//          feedbackText = Text.rich(
//            TextSpan(
//              style: TextStyle(fontSize: feedbackTextSize, color: regularTextColor),
//              children: <TextSpan>[
//                TextSpan(text: '\nFeedback\n\n\n\n', style: TextStyle(fontWeight: FontWeight.bold)),
//                TextSpan(text: 'Het correct antwoord: $answer bolletjes\n'),
//                TextSpan(text: 'Uw antwoord: $answeredNr bolletjes\n\n'),
//                TextSpan(text: '$nrOfCorrectTrial van de 12 patronen werden perfect gevormd\n'),
//                TextSpan(text: (12-nrOfCorrectTrial).toString() + ' van de 12 patronen waren helaas niet helemaal juist.'),
//              ],
//            ),
//          );
//        } else {
//          feedbackText = Text.rich(
//            TextSpan(
//              style: TextStyle(fontSize: feedbackTextSize, color: regularTextColor),
//              children: <TextSpan>[
//                TextSpan(text: '\nFeedback\n\n\n\n', style: TextStyle(fontWeight: FontWeight.bold)),
//                TextSpan(text: 'Het correct antwoord: $answer bolletjes\n'),
//                TextSpan(text: 'Uw antwoord: $answeredNr bolletjes\n\n'),
//              ]
//            )
//          );
//        }
//      } else {
//        feedbackText = Text.rich(
//          TextSpan(
//            style: TextStyle(fontSize: feedbackTextSize, color: regularTextColor),
//            children: <TextSpan>[
//              TextSpan(text: '\nFeedback\n\n\n\n', style: TextStyle(fontWeight: FontWeight.bold)),
//              TextSpan(text: '$nrOfCorrectTrial van de 12 patronen werden perfect gevormd\n'),
//              TextSpan(text: (12-nrOfCorrectTrial).toString() + ' van de 12 patronen waren helaas niet helemaal juist.'),
//            ],
//          ),
//        );
//      }
    });
  }

  _navigateToResultPage(BuildContext context, CountResultPageArguments args) async {
    final result = await Navigator.pushNamed(context, '/countResult', arguments: args);
    if(result != null) {
      answeredNr = result;
      print('Answer from CountResultPage: $answeredNr.');
      await this.widget._logger.writeLine('Counting task: counting ' + (isCountingGreen ? 'GREEN' : 'RED') + '.');
      await this.widget._logger.writeLine('Should answer $answer, patient answered $answeredNr.');
    } else {
      print('ERROR: No result returned from CountResultPage!');
      await this.widget._logger.writeLine('Encountered an error. Please contact the developer.');
    }
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