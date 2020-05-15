import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:recase/recase.dart';

import '../widgets/ControlButton.dart';
import '../widgets/Menu.dart';
import '../Store.dart';

class ControlsScreen extends StatefulWidget {
  ControlsScreen({Key key}) : super(key: key);

  @override
  ControlsScreenState createState() => ControlsScreenState();
}

class ControlsScreenState extends State<ControlsScreen> {
  double iconSize;
  List<ControlButton> tiles = [];
  final buttonTitleController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    this.buttonTitleController.dispose();
    super.dispose();
  }

  /*@override
  void initState() {
    super.initState();

    if (S().getPers('local-events') != false) {
      Map<String, dynamic> localEvents = jsonDecode(S().getPers('local-events'));

      localEvents.forEach((key, value) {
        this.tiles.add(ControlButton(title: value, id: key, screenState: this));
      });
    }

    // test
    /*tiles = [
      ControlButton(title: 'Světla Kuchyň', id: 'LocalSvetlaKuchyn', screenState: this),
      ControlButton(title: 'Rolety Kuchyň', id: 'LocalRoletyKuchyn', screenState: this),
      ControlButton(title: 'Světla Garáž', id: 'LocalSvetlaGaraz', screenState: this),
      ControlButton(title: 'Garáž Vrata', id: 'LocalGarazVrata', screenState: this),
      ControlButton(title: 'Světla Veranda', id: 'LocalSvetlaVeranda', screenState: this),
    ];*/
  }*/

  @override
  Widget build(BuildContext context) {
    S provider = Provider.of<S>(context);

    if (provider.localEvents != null) {
      provider.localEvents.forEach((eventId) {
        this.tiles.add(ControlButton(title: eventId.titleCase, id: eventId, screenState: this));
      });
    }

    var wrap = ReorderableWrap(
      spacing: 8.0,
      runSpacing: 4.0,
      padding: const EdgeInsets.all(8),
      children: tiles,
      onReorder: (int oldIndex, int newIndex) {
        ControlButton tile = tiles[oldIndex];

        S().localEvents.removeAt(oldIndex);
        S().localEvents.insert(newIndex, tile.id);

        /*setState(() {
          Widget row = tiles.removeAt(oldIndex);
          tiles.insert(newIndex, row);
        });*/
      },
      onNoReorder: (int index) {
        //this callback is optional
        debugPrint('${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
      },
      onReorderStarted: (int index) {
        //this callback is optional
        debugPrint('${DateTime.now().toString().substring(5, 22)} reorder started: index:$index');
      }
    );

    return Scaffold(
      drawer: Menu(),
      backgroundColor: Colors.blueGrey,
      appBar: (!provider.headlessMode) ? AppBar(
        title: Text('Controls'),
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.remove_red_eye),
            onPressed: () {
              S().toggleHeadless();
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Add Button'),
                    content: TextField(
                      controller: buttonTitleController,
                      decoration: const InputDecoration(
                        hintText: 'Button Title',
                      ),
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
                          if (buttonTitleController.text.isNotEmpty) {
                            Navigator.of(context).pop();
                            S().addLocalEvent(buttonTitleController.text.pascalCase);
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ) : null,
      body: Center(
        child: SingleChildScrollView(
          child: wrap,
        ),
      ),
    );
  }
}

