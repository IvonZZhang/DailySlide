import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'training_page.dart';

class InstructionSinglePage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Training Instructies'),
      ),
      resizeToAvoidBottomPadding: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black87, height: 1.6, fontSize: 20, fontWeight: FontWeight.normal, fontStyle: FontStyle.normal),
                  children: <TextSpan>[
                    TextSpan(text: 'Instructies:\n', style: TextStyle(decoration: TextDecoration.underline)),
                    TextSpan(text: 'Onderaan ziet u een voorbeeld van wat u te zien zal krijgen tijdens de training.'),
                    TextSpan(text: '\n ◦ Linksonder op het scherm zal een patroon getoond worden aan het begin van elke reeks.'),
                    TextSpan(text: '\n ◦ Van zodra het voorbeeldpatroon werd gevormd linksonder, zal een leeg veld met 9 lichtblauwe bolletjes \n      verschijnen rechts onderaan.'),
                    TextSpan(text: '\n ◦ Probeer het voorbeeldpatroon na te maken rechts onderaan het scherm door met uw rechterwijsvinger te \n      swipen over het scherm. Doe dit '),
                    TextSpan(text: 'zo snel en accuraat mogelijk', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ', zonder uw vinger van het scherm te halen.'),
                    TextSpan(text: '\n ◦ Gedurende de uitvoering zal het patroon zichtbaar blijven links onderaan op het scherm.'),
                  ],
                ),
              ),
            ),
            Image(image: AssetImage('assets/Instructie_single.png'), height: 190,),
            Container(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 28.0),
                child: OutlineButton(
                  borderSide: BorderSide(style: BorderStyle.solid, width: 2.0),
                  child: Text('Klik hier om de training te starten'),
                  onPressed: () {
                    final TrainingPageArguments args = ModalRoute.of(context).settings.arguments;
                    Navigator.pushReplacementNamed(context, '/training', arguments: args);
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