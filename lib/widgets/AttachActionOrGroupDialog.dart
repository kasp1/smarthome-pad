import 'package:flutter/material.dart';
import 'package:recase/recase.dart';
import '../utils/enums.dart';
import '../Store.dart';
import '../utils/DropDownFieldWrapper.dart';

class AttachActionOrGroupDialog extends StatefulWidget {
  AttachActionOrGroupDialog({ Key key, this.eventOrGroup }) : super(key: key);
  String eventOrGroup;

  @override
  _AttachActionOrGroupDialogState createState() => _AttachActionOrGroupDialogState();
}

class _AttachActionOrGroupDialogState extends State<AttachActionOrGroupDialog> {
  Map<String, String> options = {};
  String selectedActionOrGroup;
  Map <String, String> paramValues = {};

  // ! only usable if S().determineStepType(this.selectedActionOrGroup) == BehaviorStepType.action
  Map <String, dynamic> getActionParams() {
    if (S().determineStepType(this.selectedActionOrGroup) == BehaviorStepType.action) {
      String moduleId = this.selectedActionOrGroup.split('_')[0];
      String action = this.selectedActionOrGroup.split('_')[1];
      return S().modules[moduleId]['actions'][action]['params'];
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    S().modules.forEach((String id, module) {
      if (module is Map) {
        if (module['actions'] != null) {
          module['actions'].forEach((String action, params) {
            this.options[id + '_' + action] = action.toString().titleCase;
          });
        }
      }
    });

    S().sharedFlow.forEach((String actionOrGroup, step) {
      if (S().determineStepType(actionOrGroup) == BehaviorStepType.group) {
        this.options[actionOrGroup] = actionOrGroup.titleCase;
      }
    });

    Widget actionParametersEditor() {
      Map <String, dynamic> params = this.getActionParams();

      if (params != null) {
        List<Widget> p = [];

        params.forEach((String param, options) {
          if (options is List) {
            // the param is list of string options
            List<String> par = List.castFrom<dynamic, String>(options);

            if (this.paramValues[param] == null) {
              this.paramValues[param] = par[0];
            }

            p.add(Container(
              child: 
                Container(
                  color: Colors.blueGrey,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  child: DropdownButton<String>(
                    value: this.paramValues[param],
                    icon: Icon(Icons.arrow_downward, color: Colors.white),
                    iconSize: 16,
                    elevation: 16,
                    style: TextStyle(color: Colors.white),
                    underline: Container(
                      height: 0,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        this.paramValues[param] = newValue;
                      });
                    },
                    items: par.map<DropdownMenuItem<String>>((String val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(param.titleCase + ': ' + val)
                      );
                    }).toList(),
                  ),
                )
            ));
          } else {
            // the param is not a list of options, therefore simple string can be input
            p.add(Container(
              child: Row(
                children: [
                  Text(param),
                  Text('is an input')
                ]
              )
            ));
          }
        });

        return Container(
          margin: EdgeInsets.only(top: 20),
          child: Wrap(
            runSpacing: 10,
            spacing: 10,
            children: p
          )
        );
      } else {
        return Container(
          margin: EdgeInsets.all(30),
          child: Text('There are on editable parameters on this action.',
            style: TextStyle(fontSize: 12),
          )
        );
      }
    }

    return AlertDialog(
      title: Text('Attach an Action or Group'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropDownFieldWrapper(
            value: '',
            //icon: Icon(Icons.event),
            required: true,
            hintText: 'Type to choose an action or group',
            options: this.options,
            strict: false,
            onValueChanged: (String id, String value) {
              this.setState(() {
                this.selectedActionOrGroup = id;
              });
            }
          ),
          if (this.selectedActionOrGroup != null)
            if (S().determineStepType(this.selectedActionOrGroup) == BehaviorStepType.action)
              actionParametersEditor()
        ],
      ),
      actions: [
        FlatButton(
          child: Text('Cancel'),
          onPressed:  () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('Add'),
          onPressed: () {
            if (this.selectedActionOrGroup != null) {
              Map <String, dynamic> params = this.getActionParams();

              if (S().localFlow.containsKey(this.widget.eventOrGroup)) {
                // this action is to be attached to a local event
                if (params != null) {
                  S().addLocalFlowStep(this.widget.eventOrGroup, this.selectedActionOrGroup, paramValues: this.paramValues);
                } else {
                  S().addLocalFlowStep(this.widget.eventOrGroup, this.selectedActionOrGroup);
                }
              } else {
                // this action is to be attached to a shared event or group
                if (params != null) {
                  S().addSharedFlowStep(this.widget.eventOrGroup, this.selectedActionOrGroup, paramValues: this.paramValues);
                } else {
                  S().addSharedFlowStep(this.widget.eventOrGroup, this.selectedActionOrGroup);
                }
              }

              Navigator.of(context).pop();
            }
          }
        )
      ],
    );
  }
}