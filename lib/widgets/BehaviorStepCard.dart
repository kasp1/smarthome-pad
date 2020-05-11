import 'package:flutter/material.dart';
import '../utils/BehaviorStepPainter.dart';
import 'package:recase/recase.dart';

import '../Store.dart';
import '../utils/BehaviorStep.dart';

// The list header (static)
class BehaviorStepCard extends StatelessWidget {
  String id;
  BehaviorStepType type;
  BehaviorStep step;

  BehaviorStepCard({Key key, this.id, this.step}) : super(key: key) {
    if (this.step == null) {
      this.type = S().determineStepType(this.id);
    } else {
      this.type = this.step.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color titleColor;

    switch (this.type) {
      case BehaviorStepType.action:
        bgColor = Colors.white;
        titleColor = Colors.grey[800];
        break;
      case BehaviorStepType.group:
        bgColor = Colors.blue[200];
        titleColor = Colors.white;
        break;
      case BehaviorStepType.event:
        bgColor = Colors.red[200];
        titleColor = Colors.white;
        break;
      case BehaviorStepType.add:
        bgColor = Colors.blueGrey[200];
        titleColor = Colors.white;
        break;
    }

    String title = this.id;

    if (title.contains('_')) {
      title = title.split('_')[1];
    }

    title = title.titleCase;

    return CustomPaint(
      painter: BehaviorStepPainter(bgColor),
      child: Container(
        width: 200,
        height: 80,
        padding: EdgeInsets.only(left: 5, top: 5, right: 25, bottom: 5),
        child: Text(title, style: TextStyle(color: titleColor)),
        /*decoration: BoxDecoration(
          color: Colors.white,
        ),*/
      ),
    );
  }
}