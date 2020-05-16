import 'package:flutter/material.dart';
import '../utils/BehaviorStepPainter.dart';
import 'package:recase/recase.dart';

import '../Store.dart';
import '../utils/BehaviorStep.dart';
import '../utils/enums.dart';

// The list header (static)
class BehaviorStepCard extends StatelessWidget {
  String id;
  BehaviorStepType type;
  BehaviorStep step;
  bool isLocalEvent;

  BehaviorStepCard({Key key, this.id, this.step, this.isLocalEvent}) : super(key: key) {
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
    String typeCaption;

    switch (this.type) {
      case BehaviorStepType.action:
        bgColor = Colors.white;
        titleColor = Colors.grey[800];
        typeCaption = 'Action';
        break;
      case BehaviorStepType.group:
        bgColor = Colors.blue[200];
        titleColor = Colors.white;
        typeCaption = 'Group';
        break;
      case BehaviorStepType.event:
        bgColor = Colors.red[200];
        titleColor = Colors.white;
        typeCaption = 'Event';
        break;
    }

    // override group decision on local events
    if (this.isLocalEvent == true) {
      bgColor = Colors.red[200];
      titleColor = Colors.white;
      this.type = BehaviorStepType.event;
    }

    String title = this.id;

    if (title.contains('_')) {
      title = title.split('_')[1];
    }

    title = title.titleCase;

    List<Widget> params = [];

    if (this.type == BehaviorStepType.action) {
      if (this.step.params != null) {
        if (this.step.params.isNotEmpty) {
          this.step.params.forEach((String param, value) {
            params.add(Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(3)),
                color: Colors.blueGrey[100],
              ),
              child: Text(param.titleCase + ': ' + value.toString().titleCase,
                style: TextStyle(color: Colors.grey[800], fontSize: 11),
              ),
            ));
          });
        }
      }
    }

    return CustomPaint(
      painter: BehaviorStepPainter(bgColor),
      child: Container(
        width: 200,
        height: 80,
        padding: EdgeInsets.only(left: 10, top: 5, right: 30, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text(title,
                style: TextStyle(color: titleColor, fontSize: 16)
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: params
                ),
              )
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(typeCaption,
                style: TextStyle(fontWeight: FontWeight.bold, color: titleColor)
              ),
            ),
          ],
        ),
      ),
    );
  }
}