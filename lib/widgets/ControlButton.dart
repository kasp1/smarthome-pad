import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Store.dart';
import '../screens/Controls.dart';

class ControlButton extends StatefulWidget {
  String title;
  String id;
  ControlsScreenState screenState;


  ControlButton({Key key, this.title, this.id, this.screenState }) : super(key: key);

  @override
  _ControlButtonState createState() => _ControlButtonState();
}

class _ControlButtonState extends State<ControlButton> {
  double width;

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    S provider = Provider.of<S>(context);
    double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth <= 400) {
      this.width = screenWidth - 40;
    }

    if (screenWidth > 400) {
      this.width = (screenWidth / 2) - 40;
    }

    if (screenWidth > 800) {
      this.width = (screenWidth / 3) - 40;
    }

    if (screenWidth > 1200) {
      this.width = (screenWidth / 4) - 40;
    }
    
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            SizedBox(
              width: this.width,
              height: MediaQuery.of(context).size.height / 4,
              child: RaisedButton(
                child: Text(this.widget.title,
                  style: TextStyle(
                    fontSize: 30
                  ),
                ),
                onPressed: () {
                  S().triggerLocalEvent(this.widget.id);
                }
              )
            ),
            if (!provider.headlessMode) IconButton(
              alignment: Alignment.centerRight,
              icon: Icon(Icons.clear, size: 40),
              onPressed: () {
                S().confirm(context, 'Do you wish to remove this button?', () {
                  this.widget.screenState.setState(() {
                    this.widget.screenState.tiles.remove(this.widget);
                  });

                  this.widget.screenState.updateButtonList();

                  S().syncLocalEvents();
                });
              },
            ),
          ] 
        ),
      );
  }
}