import 'dart:convert';

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

  final Logger _logger = Logger('log_cache');

  @override
  _TrainingPageState createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage>
    with AfterLayoutMixin<TrainingPage> {
  // Nr of node left during showing
  int nodeLeft = 7;

  // Temp pattern in showing
  List<int> tempPattern = [];

  // Seconds left during resting
  int restSec = 14;

  Timer _timerPeriod;
  Timer _restTimerPeriod;

  // The index of pattern in a series/sequence
  int patternNr = 0;

  // The index of day/sequence
  int day = -1;

  // The nr of trying (max 12)
  int trying = 1;

  // Text on the top for general notifications
  Text notificationText = Text('Please look at the pattern on the left',style: TextStyle(fontSize: 46));

  // Text in the middle for feedback of a training
  Text feedbackText = Text(' ', style: TextStyle(fontSize: 30));

  // Is training pattern touchable or not
  bool isTraining = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final trainingPatternKey = GlobalKey<PatternLockState>();
  final showingPatternKey = GlobalKey<PatternLockState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final TrainingPageArguments args = ModalRoute.of(context).settings.arguments;
    widget._logger.writeFileHeader(args.patientNr, day); // DoneTODO: patient nr
    showPatternExample();
  }

  void showPatternExample() => _timerPeriod =
          new Timer.periodic(new Duration(milliseconds: 80), (Timer timer) {
        if (nodeLeft == 0) {
          _timerPeriod.cancel();
          nodeLeft = 7;
          widget._logger.writePatternNr(patternNr + 1);

          setState(() => notificationText = Text(
              'Please redo the pattern on the right',
              style: TextStyle(fontSize: 46)));
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
            'Take a rest: $restSec',
            style: TextStyle(fontSize: 46),
          );
        });

        if (restSec == 0) {
          _restTimerPeriod.cancel();
          restSec = 14;
          tempPattern = [];
          setState(() {
            ++patternNr;
            notificationText = Text('Please look at the pattern',
                style: TextStyle(fontSize: 46));
            feedbackText = Text(' ');
            showingPatternKey.currentState
                .setState(() => showingPatternKey.currentState.setUsed([]));
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
//    widget._logger.writeFileFooter();
//    uploadToDbx(666);
//    widget._logger.readLog().then((value) => print(value));
  }

  Future<int> uploadToDbx(int patientNr) async {
    var date = DateFormat('yyyy-MM-dd HH:mm:ss\n').format(DateTime.now());
    // Get upload link
    var urlGetLink =
        'https://api.dropboxapi.com/2/files/get_temporary_upload_link';
    var headersGetLink = {
      'Authorization':
          'Bearer wHGP8A-xg1AAAAAAAAAAGLDSRW1zS5ghHK-W57eqNMy06ekPl8bXCzG5JyVL5_A5',
      'Content-Type': 'application/json'
    };
    var dataGetLink = {
      'commit_info': {
        'path': '/$patientNr/$patientNr $date Day$day.txt',
        'mode': 'add',
        'autorename': true,
        'mute': false,
        'strict_conflict': false
      },
      'duration': 3600
    };

    var responseLink = await http.post(urlGetLink,
        headers: headersGetLink, body: jsonEncode(dataGetLink));

    // Upload the log file
    var urlUpload = jsonDecode(responseLink.body)['link'];
    print(urlUpload);
    String dataUpload = await widget._logger.readLog();

    final request = await HttpClient().postUrl(Uri.parse(urlUpload));
    request.headers
        .set(HttpHeaders.contentTypeHeader, "application/octet-stream");
    request.write(dataUpload);
    final response = await request.close();

    return response.statusCode;
  }

  @override
  Widget build(BuildContext context) {
    final TrainingPageArguments args = ModalRoute.of(context).settings.arguments;
    day = args.dayNr;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Training"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Flexible(
            flex: 2,
            child: notificationText,
          ),
          Flexible(
            flex: 1,
            child: feedbackText,
          ),
          Flexible(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Center(
                      child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      PatternLock(
                        key: showingPatternKey,
                        selectedColor: Colors.amber,
                        pointRadius: 27,
                        fillPoints: true,
                        onInputComplete: (List<int> input, int duration) {},
                      ),
                      Image(
                        image: AssetImage('assets/transparent.png')
                      ),
                      Positioned(
                        bottom: 40,
                        right: 200,
                        child: Text(
                          'Example',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.black54),
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
                        selectedColor: Colors.amber,
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
                                        color: Colors.deepOrange,
                                        fontWeight: FontWeight.bold),
                                  )
                                : Text(
                                    'Mistaken...',
                                    style: TextStyle(
                                        fontSize: 30,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  );
                            notificationText = trying % 2 == 0
                                ? Text(
                                    'Please redo the pattern. Remaining: ' +
                                        (12 - trying).toString(),
                                    style: TextStyle(fontSize: 46))
                                : Text(
                                    'Please do it again.           Remaining: ' +
                                        (12 - trying).toString(),
                                    style: TextStyle(fontSize: 46),
                                  );
                          });

                          widget._logger.writeTrainingResult(trying,
                              listEquals(input, tempPattern), duration);

                          if (trying == 12) {
                            isTraining = false;
                            if (patternNr == 8) {
                              widget._logger.writeFileFooter();
                              new Timer(
                                  Duration(seconds: 1),
                                  () => setState(() => feedbackText = Text(
                                        'Training finished! Exit after syncing data...',
                                        style: TextStyle(
                                            fontSize: 30,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      )));
                              String syncInfo = await uploadToDbx(args.patientNr) == 200 // DoneTODO: patientNr
                                  ? 'Data sync successfully!'
                                  : 'Data sync failed.';
                              scaffoldKey.currentState.hideCurrentSnackBar();
                              scaffoldKey.currentState.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    syncInfo,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              );
                              new Timer(Duration(seconds: 2),
                                  () => Navigator.pop(context));
                              return;
                            }
                            setState(() {
                              notificationText = Text(
                                'Take a rest: 14',
                                style: TextStyle(fontSize: 46),
                              );
                              feedbackText = Text(
                                ' ',
                                style: TextStyle(fontSize: 30),
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
    );
  }
}
