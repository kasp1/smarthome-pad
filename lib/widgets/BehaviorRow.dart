import 'package:flutter/material.dart';
import '../utils/BehaviorStep.dart';
import 'BehaviorStepCard.dart';

class BehaviorRow extends StatelessWidget {
  final BehaviorStep item;

  const BehaviorRow({ Key key, this.item }) : super(key: key);
  BehaviorStepCard makeListTile(BehaviorStep item) => BehaviorStepCard(id: item.id, step: item);

  @override
  Widget build(BuildContext context) {
    return makeListTile(item);
  }
}