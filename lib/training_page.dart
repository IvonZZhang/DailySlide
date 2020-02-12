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

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final patternLockKey = GlobalKey<PatternLockState>();


  @override
  void initState() {
    super.initState();
    _timerPeriod = new Timer.periodic(new Duration(seconds: 1), (Timer timer) {
      tempPattern.add(widget.patterns[patternNr][7 - nodeLeft--]);
      patternLockKey.currentState.setState(() {
        patternLockKey.currentState.setUsed(tempPattern);
      });

      if(nodeLeft == 0){
        if(patternNr == 2) {
          _timerPeriod.cancel();
          return;
        }

        ++patternNr;
        nodeLeft = 7;
        tempPattern = [];
      }
    });
  }


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
        title: Text("Check Pattern"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Flexible(
            flex: 2,
            child: Text(
              isConfirm ? "Confirm pattern" : "Draw pattern",
              style: TextStyle(fontSize: 26),
            ),
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: FlatButton(
              onPressed: () {
                setState(() {
                  patternLockKey.currentState.setUsed([2]);
                });
              },
              child: Text('Button', style: TextStyle(fontSize: 20),),
            ),
          ),
          Flexible(
            flex: 4,
            child: PatternLock(
              key: patternLockKey,
              selectedColor: Colors.amber,
              pointRadius: 27,
              onInputComplete: (List<int> input) {
                if (input.length < 3) {
                  scaffoldKey.currentState.hideCurrentSnackBar();
                  scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      content: Text(
                        "At least 3 points required",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                  return;
                }
                if (isConfirm) {
                  if (listEquals<int>(input, pattern)) {
                    Navigator.of(context).pop(pattern);
                  } else {
                    scaffoldKey.currentState.hideCurrentSnackBar();
                    scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: Text(
                          "Patterns do not match",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                    setState(() {
                      pattern = null;
                      isConfirm = false;
                    });
                  }
                } else {
                  setState(() {
                    pattern = input;
                    isConfirm = true;
                  });
                }
              },
              fillPoints: true,
            ),
          ),
        ],
      ),
    );
  }
}