import 'package:flutter/material.dart';
import '../utils/BehaviorStep.dart';
import 'BehaviorStepCard.dart';

class BehaviorRow extends StatelessWidget {
  final BehaviorStep item;

  const BehaviorRow({ Key key, this.item }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BehaviorStepCard(id: this.item.id, step: this.item);
  }
}