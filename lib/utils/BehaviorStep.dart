import '../Store.dart';
import '../utils/enums.dart';

class BehaviorStep {
  final String id;
  String listId;
  BehaviorStepType type;
  Map<String, dynamic> params = Map();

  BehaviorStep({this.id, this.listId, this.params}) {
    this.type = S().determineStepType(this.id);
  }
}