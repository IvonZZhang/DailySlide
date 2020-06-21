import 'package:flutter/material.dart';

class CountResultPageArguments {
  final bool isCountingGreen;
  final int answer;

  CountResultPageArguments(this.isCountingGreen, this.answer);
}

class CountResultPage extends StatefulWidget {

  @override
  State createState() => _CountResultPage();

}

class _CountResultPage extends State<CountResultPage> {

  static final Color bgColor = Color(0xFF5C5C5C);
  static final Color regularTextColor = Colors.blueGrey[50];
  static final Color feedbackTextColor = Colors.deepOrange;

  // List[1..15], all possible answers
  var answers = new List<int>.generate(16, (i) => i);

  // Indicates which nr user tapped, -1 means not tapped yet
  var answeredNr = -1;

  static final Color correctButtonColor = Colors.green;
  static final Color wrongButtonColor = Colors.red;

  var originalButtonColor = Colors.white70;

  @override
  Widget build(BuildContext context) {
    final CountResultPageArguments args = ModalRoute.of(context).settings.arguments;
    var isCountingGreen = args.isCountingGreen;
    var answer = args.answer;

    return Scaffold(
      appBar: AppBar(
        title: Text('Training'),
      ),
      backgroundColor: bgColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(color: regularTextColor, fontSize: 40, fontWeight: FontWeight.normal, fontStyle: FontStyle.normal),
                  children: <TextSpan>[
                    TextSpan(text: 'How many '),
                    TextSpan(text: isCountingGreen ? 'green' : 'red', style: TextStyle(color: isCountingGreen ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                    TextSpan(text: ' dots did you count? Indicate the correct answer by clicking the number.'),
//                    TextSpan(text:  '\n' + (answeredNr == -1 ? ''
//                          : (answeredNr == answer) ? 'Perfect!' : 'Helaas niet helemaal juist...') ,
//                        style: TextStyle(
//                            fontSize: 30,
//                            fontWeight: FontWeight.bold,
//                            color: feedbackTextColor)
//                    ),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            flex: 4,
            child: Stack(
              children: <Widget>[
                GridView.count(
                  primary: true,
                  physics: new NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 4,
                  childAspectRatio: 2.3,
                  shrinkWrap: true,
                  children:
                    answers.map((item) => new RaisedButton( // TODO: more realistic button
                      key: Key('button$item'),
                      padding: const EdgeInsets.all(8),
                      child: Text(item.toString(), style: TextStyle(color: Colors.black, fontSize: 50, ),),
//                      color: answeredNr == -1? originalButtonColor : // Has user answered?
//                        (item == answer ? correctButtonColor : // Am I the answer?
//                          (answeredNr == item ? wrongButtonColor : originalButtonColor)), // Am I the right answer?
                      onPressed: () {
                        setState(() {
                          print('Pressed $item, should be $answer');
                          answeredNr = item;
                        });
//                        new Timer(Duration(seconds: 2), () {
                        Navigator.pop(context, answeredNr);
//                        });
                      },
                    )).toList(),
                ),
                Visibility(
                  visible: answeredNr != -1,
                  child: Image(
                    image: AssetImage('assets/transparent.png'),
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                  ),
                )
              ]
            ),
          ),
        ],
      ),
    );
  }

}