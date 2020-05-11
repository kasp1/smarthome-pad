import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Store.dart';

class Menu extends StatefulWidget {
  Menu({Key key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool headlessMode = false;

  @override 
  void initState() {
    if (S().getPers('headless-mode') == 'true') {
      headlessMode = true;
    } else {
      headlessMode = false;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    S provider = Provider.of<S>(context);

    return FractionallySizedBox(
      widthFactor: 0.8,
      child: Container(
        alignment: Alignment.centerRight,
        color: Colors.white,
        child: Column(
          children: <Widget>[
            if (provider.connected) ListTile(
              leading: Icon(Icons.arrow_forward_ios),
              title: Text('Behavior'),
              onTap: () {
                S().go2('/behavior', pop: true, reset: true);
              },
            ),
            if (provider.connected) ListTile(
              leading: Icon(Icons.radio_button_checked),
              title: Text('Controls'),
              onTap: () {
                S().go2('/controls', pop: true, reset: true);
              },
            ),
            ListTile(
              leading: Icon(Icons.code),
              title: Text('Console'),
              onTap: () {
                S().go2('/console', pop: true);
              },
            ),
            if (provider.connected) ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Disconnect'),
              onTap: () {
                S().setPers('auto-reconnect', 'false');
                S().go2('/', pop: false, reset: true);
              },
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.centerRight,
              child: Row(
                children: [
                  Switch(
                    value: this.headlessMode,
                    activeColor: Colors.blueGrey,
                    inactiveThumbColor: Colors.grey[800],
                    activeTrackColor: Colors.grey[800],
                    onChanged: (value) {
                      this.setState(() {
                        this.headlessMode = value;
                      });

                      S().setPers('headless-mode', value.toString());
                    },
                  ),
                  Text('Clean Mode',
                    style: TextStyle(color: Colors.grey[800])
                  )
                ],
              ),
            )
          ],
        )
      )
    );
  }
}