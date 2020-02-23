import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'pattern_lock.dart';
import 'dart:async';

class TrainingPage extends StatefulWidget {
//  final List<int> pattern_1 = [7, 6, 3, 0, 4, 1, 5];
//  final List<int> pattern_2 = [7, 4, 8, 5, 2, 1, 3];
//  final List<int> pattern_3 = [7, 3, 4, 0, 1, 2, 5];
  final List<List<int>> patterns = [[7, 6, 3, 0, 4, 1, 5], [7, 4, 8, 5, 2, 1, 3], [7, 3, 4, 0, 1, 2, 5]];
  final List<List<int>> sequence = [[1, 2, 3, 2, 2, 1, 3, 1, 3], [1, 3, 3, 1, 2, 2, 1, 2, 3],
                                    [1, 1, 2, 3, 1, 3, 2, 3, 2], [1, 3, 1, 2, 3, 3, 2, 2, 1]];

  @override
  _TrainingPageState createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {

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
  Text notificationText = Text('Please look at the pattern on the left', style: TextStyle(fontSize: 46),);
  // Text in the middle for feedback of a training
  Text feedbackText = Text(' ', style: TextStyle(fontSize: 30),);

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final trainingPatternKey = GlobalKey<PatternLockState>();
  final showingPatternKey = GlobalKey<PatternLockState>();

  @override
  void initState() {
    super.initState();
    showPatternExample();
  }

  void showPatternExample() => _timerPeriod = new Timer.periodic(new Duration(milliseconds: 80), (Timer timer) {
    if(nodeLeft == 0){
      _timerPeriod.cancel();
//      pattern = widget.patterns[widget.sequence[day - 1][patternNr] - 1];
      nodeLeft = 7;

      setState(() => notificationText = Text('Please redo the pattern on the right', style: TextStyle(fontSize: 46)));
      return;
    }

    tempPattern.add(widget.patterns[widget.sequence[day - 1][patternNr] - 1][7 - nodeLeft--]);
    print(day - 1);
    showingPatternKey.currentState.setState(() => showingPatternKey.currentState.setUsed(tempPattern));

  });

  void takeARest() => _restTimerPeriod = new Timer.periodic(new Duration(seconds: 1), (Timer timer) {
    --restSec;
    setState(() {
      notificationText = Text(
        'Take a rest: ' + restSec.toString(), style: TextStyle(fontSize: 46),
      );
    });

    if(restSec == 0){
      _restTimerPeriod.cancel();
      restSec = 14;
      tempPattern = [];
      setState(() {
        ++patternNr;
        notificationText = Text('Please look at the pattern', style: TextStyle(fontSize: 46));
        feedbackText = Text(' ');
        showingPatternKey.currentState.setState( () => showingPatternKey.currentState.setUsed([]) );
      });
      new Timer(new Duration(seconds: 1), () {
        showPatternExample();
      });
    }
  });


  @override
  void dispose() {
    super.dispose();
    _timerPeriod.cancel();
  }

  @override
  Widget build(BuildContext context) {
    day = ModalRoute.of(context).settings.arguments;
//    --day;

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
            child:
            Row(
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
                          onInputComplete: (List<int> input) {},
                        ),
                        Image(
                          image: NetworkImage('https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fupload.wikimedia.org%2Fwikipedia%2Fcommons%2Fthumb%2F0%2F02%2FTransparent_square.svg%2F768px-Transparent_square.svg.png&f=1&nofb=1'),
                        ),
                        Positioned(
                          bottom: 40,
                          right: 200,
                          child: Text(
                            'Example',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black54),
                          ),
                        ),
                      ],
                    )

                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Center(
                    child:PatternLock(
                      key: trainingPatternKey,
                      selectedColor: Colors.amber,
                      pointRadius: 27,
                      fillPoints: true,
                      onInputComplete: (List<int> input) {
                        setState(() {
                          feedbackText = listEquals(input, tempPattern)?
                              Text('Perfect!', style: TextStyle(fontSize: 30, color: Colors.deepOrange, fontWeight: FontWeight.bold),)
                              : Text('Mistaken...', style: TextStyle(fontSize: 30, color: Colors.red, fontWeight: FontWeight.bold),);
                          notificationText = trying % 2 == 0 ?
                              Text('Please redo the pattern. Remaining: ' + (12 - trying).toString(), style: TextStyle(fontSize: 46))
                              : Text('Please do it again.           Remaining: ' + (12 - trying).toString(), style: TextStyle(fontSize: 46),);
                        });

                        if(trying == 12){
                          if(patternNr == 8) {
                            // TODO: data logging
                            new Timer(Duration(seconds: 1), () => setState(() => feedbackText = Text(
                              'Training finished! About to exit...',
                              style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
                            )
                            )
                            );
                            new Timer(Duration(seconds: 5), () => Navigator.pop(context));
                            return;
                          }
                          setState(() {
                            notificationText = Text('Take a rest: 14', style: TextStyle(fontSize: 46),);
                            feedbackText = Text(' ', style: TextStyle(fontSize: 30),);
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
              ],
            )

          ),
        ],
      ),
    );
  }
}

/*
* PatternLock(
                  key: patternLockKey,
                  selectedColor: Colors.amber,
                  pointRadius: 27,
                  onInputComplete: (List<int> input) {
                    setState(() {
                      feedbackText = listEquals(input, pattern)?
                      Text(
                        'Perfect!',
                        style: TextStyle(fontSize: 30, color: Colors.deepOrange, fontWeight: FontWeight.bold),
                      )
                          : Text(
                        'Mistaken...',
                        style: TextStyle(fontSize: 30, color: Colors.red, fontWeight: FontWeight.bold),
                      );
                    });

                    if(secondTrial) {
                      if(patternNr == 2) {
                        // TODO: data logging
                        new Timer(Duration(seconds: 1), () => setState(() => feedbackText = Text(
                          'Training finished! About to exit...',
                          style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
                        )
                        )
                        );
                        new Timer(Duration(seconds: 5), () => Navigator.pop(context));
                        return;
                      }

                      new Timer(Duration(seconds: 1), () {
                        setState(() {
                          ++patternNr;
                          isTraining = false;
                          secondTrial = false;
                          feedbackText = Text(' ');
                        });
                        showPatternExample();
                      });
                    } else {
                      secondTrial = true;
                    }
                  },
                  fillPoints: true,
                ),
* */





//                if (input.length < 3) {
//                  scaffoldKey.currentState.hideCurrentSnackBar();
//                  scaffoldKey.currentState.showSnackBar(
//                    SnackBar(
//                      content: Text(
//                        "At least 3 points required",
//                        style: TextStyle(color: Colors.red),
//                      ),
//                    ),
//                  );
//                  return;
//                }
//                if (isConfirm) {
//                  if (listEquals<int>(input, pattern)) {
//                    Navigator.of(context).pop(pattern);
//                  } else {
//                    scaffoldKey.currentState.hideCurrentSnackBar();
//                    scaffoldKey.currentState.showSnackBar(
//                      SnackBar(
//                        content: Text(
//                          "Patterns do not match",
//                          style: TextStyle(color: Colors.red),
//                        ),
//                      ),
//                    );
//                    setState(() {
//                      pattern = null;
//                      isConfirm = false;
//                    });
//                  }
//                } else {
//                  setState(() {
//                    pattern = input;
//                    isConfirm = true;
//                  });
//                }