import 'package:flutter/material.dart';

class DisplayedQuestion extends StatelessWidget {
  //ANCHOR Public Variables
  final Widget child;

  //ANCHOR Constructor
  DisplayedQuestion({this.child});

  @override
  //ANCHOR Builder
  Widget build(BuildContext context) {
    //ANCHOR Displayed Question
    return Expanded(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            child,
          ],
        ),
      ),
    );
  }
}
