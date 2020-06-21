
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InstructionPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Training Instructies'),
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
                  style: TextStyle(color: Colors.black87, height: 1.4, fontSize: 20, fontWeight: FontWeight.normal, fontStyle: FontStyle.normal),
                  children: <TextSpan>[
                    TextSpan(text: 'Instructies:\n', style: TextStyle(decoration: TextDecoration.underline)),
                    TextSpan(text: 'Onderaan ziet u een voorbeeld van wat u te zien zal krijgen tijdens de training.'),
                    TextSpan(text: '\n ◦ Linksonder op het scherm zal een patroon getoond worden aan het begin van elke reeks. '),
                    TextSpan(text: '\n ◦ Van zodra het voorbeeldpatroon werd gevormd linksonder, zal een leeg veld met 9 lichtblauwe bolletjes verschijnen rechts onderaan.'),
                    TextSpan(text: '\n ◦ Probeer het voorbeeldpatroon na te maken rechts onderaan het scherm door met uw rechterwijsvinger te swipen over het scherm. Doe dit '),
                    TextSpan(text: 'zo snel en accuraat mogelijk', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ', zonder uw vinger van het scherm te halen.'),
                    TextSpan(text: '\n ◦ Gedurende de uitvoering zal het patroon zichtbaar blijven links onderaan op het scherm.'),
                    TextSpan(text: '\n ◦ Vergeet niet om gelijktijdig de groene of de rode bolletjes te tellen. Deze zullen in een willekeurige volgorde verschijnen in het midden van het scherm. Voor elke reeks zal aangegeven worden welke kleur geteld moet worden.'),
                    TextSpan(text: '\n ◦ Nadien zal u gevraagd worden om aan te duiden hoeveel rode of groene bolletjes u heeft geteld, zoals op het voorbeeld rechtsonder. '),
                  ],
                ),
              ),
            ),
            Image(image: AssetImage('assets/Instructie_dual.png'), height: 190,),
            Container(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 28.0),
                child: OutlineButton(
                  borderSide: BorderSide(style: BorderStyle.solid, width: 2.0),
                  child: Text('Klik hier om de training te starten'),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}