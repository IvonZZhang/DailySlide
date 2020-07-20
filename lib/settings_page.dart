import 'package:flutter/material.dart';

class SettingsPageArguments {
  final int oldPatientNr;

  SettingsPageArguments(this.oldPatientNr);
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final _textEditingController = TextEditingController();
    final SettingsPageArguments args = ModalRoute.of(context).settings.arguments;
    var oldPatientNr = args.oldPatientNr;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      resizeToAvoidBottomPadding: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black54, fontSize: 23, fontWeight: FontWeight.normal, fontStyle: FontStyle.normal),
                  children: <TextSpan>[
                    TextSpan(text: 'This page is only for researchers.\n\n', style: TextStyle(decoration: TextDecoration.underline)),
                    TextSpan(text: 'Please specify the '),
                    TextSpan(text: 'Patient Number', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                    TextSpan(text: ' for this device to identify the source of log file.\nThe '),
                    TextSpan(text: 'Patient Number', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                    TextSpan(text: ' will be used for the name and content of data log generated by trainings on this device.\n\n'),
                    TextSpan(text: 'It is recommended to change the patient number before give this device to a different patient.\n\n'),
                    TextSpan(text: 'Current patient number: '),
                    TextSpan(text: oldPatientNr.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 300,
                    height: 60,
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: _textEditingController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter a patient number here',
                      ),
                    ),
                  ),
                  RaisedButton(
                    child: Text('Enter and go back', style: TextStyle(fontSize: 17),),
                    onPressed: () {
                      if(_textEditingController.text.isEmpty){
                      } else {
                        // Pop here with patient number
                        Navigator.pop(context, int.parse(_textEditingController.text));
                      }
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black54, fontSize: 23, fontWeight: FontWeight.normal, fontStyle: FontStyle.normal),
                  children: <TextSpan>[
                    TextSpan(text: 'The file name is in this format:\n\n', style: TextStyle(decoration: TextDecoration.underline)),
                    TextSpan(text: 'E.g.  ', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                    TextSpan(text: '4 2020-02-01 10:12:43 Day3_dual.txt\n\n'),
                    TextSpan(text: 'which means it stores the data from a Dual task training of Day3 from patient 4 performed on 1st, Feb, 2020. And this file will be located in a folder named \'Dual 4\'\n\n'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
