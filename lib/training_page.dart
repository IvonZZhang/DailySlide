import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'pattern_lock.dart';
import 'dart:async';

class TrainingPage extends StatefulWidget {
//  final List<int> pattern_1 = [7, 6, 3, 0, 4, 1, 5];
//  final List<int> pattern_2 = [7, 4, 8, 5, 2, 1, 3];
//  final List<int> pattern_3 = [7, 3, 4, 0, 1, 2, 5];
  final List<List<int>> patterns = [[7, 6, 3, 0, 4, 1, 5], [7, 4, 8, 5, 2, 1, 3], [7, 3, 4, 0, 1, 2, 5]];

  @override
  _TrainingPageState createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  bool showing = true;
  bool isConfirm = false;
  List<int> pattern;

  List<int> tempPattern = [];
  Timer _timerPeriod;
  int patternNr = 0;
  int nodeLeft = 7;
  bool isTraining = false;
  bool secondTrial = false;

  Text feedbackText = Text('');

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final patternLockKey = GlobalKey<PatternLockState>();


  @override
  void initState() {
    super.initState();
    showPatternExample();
  }

  void showPatternExample() => _timerPeriod = new Timer.periodic(new Duration(milliseconds: 300), (Timer timer) {
    if(nodeLeft == 0){
      _timerPeriod.cancel();
      pattern = widget.patterns[patternNr];
      nodeLeft = 7;
      tempPattern = [];

      patternLockKey.currentState.setState( () => patternLockKey.currentState.setUsed([]) );
      setState(() => isTraining = true);
      return;
    }

    tempPattern.add(widget.patterns[patternNr][7 - nodeLeft--]);
    patternLockKey.currentState.setState(() => patternLockKey.currentState.setUsed(tempPattern));

  });


  @override
  void dispose() {
    super.dispose();
    _timerPeriod.cancel();
  }

  @override
  Widget build(BuildContext context) {
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
            child: Text(
              isTraining ? "Please redo the pattern" : "Please look at the pattern",
              style: TextStyle(fontSize: 46),
            ),
          ),
          Flexible(
            flex: 1,
            child: feedbackText,
          ),
          Flexible(
            flex: 4,
            child: PatternLock(
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
                      feedbackText = Text('');
                    });
                    showPatternExample();
                  });
                } else {
                  secondTrial = true;
                }


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
              },
              fillPoints: true,
            ),
          ),
        ],
      ),
    );
  }
}