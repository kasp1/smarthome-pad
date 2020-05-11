import 'package:flutter/material.dart';

import '../Store.dart';

import '../widgets/Menu.dart';

class ConnectScreen extends StatefulWidget {
  ConnectScreen({Key key}) : super(key: key);

  @override
  _ConnectScreenState createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final addressController = TextEditingController();
  bool autoReconnectChecked = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    this.addressController.dispose();
    super.dispose();
  }

  @override 
  void initState() {
    if (S().getPers('auto-reconnect') == 'true') {
      autoReconnectChecked = true;
    } else {
      autoReconnectChecked = false;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    this.addressController.text = 'ws://localhost:80';
    S().context = context;

    return Scaffold(
      drawer: Menu(),
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/brewster-mcleod-architects-1486154143.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Opacity(
            opacity: .95,
            child: Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.blueGrey,
            ),
          ),
          Center(
            child: Container(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('⌂',
                    style: TextStyle(
                      fontSize: 100,
                      color: Colors.white
                    )
                  ),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      hintText: 'Smart Home Address',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      child: Text('Connect'),
                      onPressed: () {
                        S().setPers('server-address', this.addressController.text);
                        S().websocketConnect(this.addressController.text);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Switch(
                          value: this.autoReconnectChecked,
                          activeColor: Colors.white,
                          inactiveThumbColor: Colors.grey[800],
                          onChanged: (value) {
                            this.setState(() {
                              this.autoReconnectChecked = value;
                            });

                            S().setPers('auto-reconnect', value.toString());
                          },
                        ),
                        Text('Auto-reconnect on restart',
                          style: TextStyle(color: Colors.grey[800])
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ]
      ),
    );
  }
}
