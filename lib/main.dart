import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Store.dart';

import 'screens/Console.dart';
import 'screens/Connect.dart';
import 'screens/Behavior.dart';
import 'screens/Controls.dart';

Future main() async {
  await S().bootstrap();

  runApp(App());
}

class App extends StatefulWidget {
  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    S().navigatorKey = new GlobalKey<NavigatorState>();

    S().checkAutoReconnect();

    return ChangeNotifierProvider<S>.value(
      value: S(),
        child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Home',
        theme: ThemeData(
          primaryColor: Colors.white,
          accentColor: Colors.blueGrey,
          backgroundColor: Colors.blueGrey,
          textTheme: TextTheme(
            bodyText2: TextStyle(color: Colors.white),
            headline1: TextStyle(fontSize: 20.0, color: Colors.white),
          ),
          buttonTheme: ButtonThemeData(
             buttonColor: Colors.white,
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.all(Radius.circular(3))
             ),
             textTheme: ButtonTextTheme.primary
          ),
           cursorColor: Colors.white,
        ),
        navigatorKey: S().navigatorKey,
        initialRoute: '/',
        routes: {
          '/': (context) => ConnectScreen(),
          '/behavior': (context) => BehaviorScreen(),
          '/console': (context) => ConsoleScreen(),
          '/controls': (context) => ControlsScreen(),
        }
      ),
    );
  }
}

