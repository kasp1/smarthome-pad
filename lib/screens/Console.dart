import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Store.dart';

class ConsoleScreen extends StatefulWidget {
  ConsoleScreen({Key key}) : super(key: key);

  @override
  _ConsoleScreenState createState() => _ConsoleScreenState();
}

class _ConsoleScreenState extends State<ConsoleScreen> {
  @override
  Widget build(BuildContext context) {
    S provider = Provider.of<S>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Console'),
      ),
      backgroundColor: Colors.blueGrey,
      body: Column(
        children: <Widget>[
          if (S().messages.length > 0) Expanded(
            child:
            ListView.builder(
              itemCount: S().messages.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  margin: EdgeInsets.all(6),
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {
                      print('Card tapped.');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(6),
                      child: Text(S().messages[index],
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                    ),
                  ),
                );
              }
            )
          ),
          if (S().messages.length <= 0) Expanded(
            child: Center(
              child: Text('Incoming messages will display here when connected.')
            )
          ),
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white
            ),
            child: Text('Input'),
          )
        ]
      ),
    );
  }
}
