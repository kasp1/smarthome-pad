import 'package:flutter/material.dart';
import 'package:recase/recase.dart';
import '../utils/enums.dart';
import '../Store.dart';
import '../utils/DropDownFieldWrapper.dart';

class AddEventDialog extends StatefulWidget {
  AddEventDialog({ Key key }) : super(key: key);
  FlowType flowType;

  @override
  _AddEventDialogState createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  Map<String, String> options = {};
  dynamic selectedEvent;

  @override
  Widget build(BuildContext context) {
    S().modules.forEach((String id, module) {
      if (module is Map) {
        if (module['events'] != null) {
          for(int i = 0; i < module['events'].length; i++){
            this.options[id + '_' + module['events'][i]] = (module['events'][i]).toString().titleCase;
          }
        }
      }
    });

    return AlertDialog(
      title: Text('Add an Event'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropDownFieldWrapper(
            value: '',
            //icon: Icon(Icons.event),
            required: true,
            hintText: 'Type to choose an event',
            options: this.options,
            strict: false,
            onValueChanged: (String id, String value) {
              this.setState(() {
                this.selectedEvent = id;
              });
            }
          ),
          if (S().sharedFlow != null)
          if (S().sharedFlow.containsKey(this.selectedEvent))
          Container(
            margin: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.red[200]
            ),
            padding: EdgeInsets.all(20),
            child: Text("This event is already present the in the behavior chart. If there is already too many actions present this event's timeline, please consider grouping actions.",
              style: TextStyle(color: Colors.white),
            )
          )
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
            if (this.selectedEvent != null) {
              Navigator.of(context).pop();

              if (S().sharedFlow != null) {
                if (!S().sharedFlow.containsKey(this.selectedEvent)) {
                  S().addSharedEvent(this.selectedEvent);
                }
              } else {
                S().addSharedEvent(this.selectedEvent);
              }
            }
          }
        )
      ],
    );
  }
}