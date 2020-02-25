import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'training_page.dart';
import 'package:flutter/services.dart';
//import 'logger.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    return MaterialApp(
      title: 'Daily Slide',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Daily Slide'),
      routes: {
        '/training': (context) => TrainingPage(),
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
//  int _counter = 0;
//
//  void _incrementCounter() {
//    setState(() {
//      _counter++;
//    });
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ButtonTheme(
                height: 80,
                minWidth: 200,
                child: RaisedButton(
                  child: Text(
                    'Day 1',
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                  padding: EdgeInsets.all(16.0),
                  color: Colors.red,
                  onPressed: () {
                    Navigator.pushNamed(context, '/training', arguments: 1);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ButtonTheme(
                height: 80,
                minWidth: 200,
                child: RaisedButton(
                  child: Text(
                    'Day 2',
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                  padding: EdgeInsets.all(16.0),
                  color: Colors.red,
                  onPressed: () {
                    Navigator.pushNamed(context, '/training', arguments: 2);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ButtonTheme(
                height: 80,
                minWidth: 200,
                child: RaisedButton(
                  child: Text(
                    'Day 3',
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                  padding: EdgeInsets.all(16.0),
                  color: Colors.red,
                  onPressed: () {
                    Navigator.pushNamed(context, '/training', arguments: 3);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ButtonTheme(
                height: 80,
                minWidth: 200,
                child: RaisedButton(
                  child: Text(
                    'Day 4',
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                  padding: EdgeInsets.all(16.0),
                  color: Colors.red,
                  onPressed: () {
                    Navigator.pushNamed(context, '/training', arguments: 4);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TODO: change the font, color...
// TODO: Show feedback at the end of training.
// DoneTODO: block the training every 12 hours
// DoneTODO: tip, other help info...
// DoneTODO: preference of dropbox account name?
// DoneTODO: speed of showing the pattern?

/*
* Donetodo 1. Show the pattern always on the side.
* Donetodo 2. Timing in ms for each trying
* Donetodo p, Good/wrong, date, .
* Donetodo 3. Daily different training.
* Donetodo 4. Show how many times remaining.
* todo 5. Indicate patient on file name.
* 6.
* */