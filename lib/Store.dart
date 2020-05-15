import 'dart:convert';
import 'dart:collection';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:websocket/websocket.dart';
import 'utils/BehaviorStep.dart';
import 'utils/enums.dart';


class S with ChangeNotifier {

  BuildContext context;

  Map<String, dynamic> sharedFlow;
  Map<String, dynamic> modules;

  List<String> localEvents;
  // List<String> localGroups; // Decided groups will be only global / shared (and local flow will be able to call global groups)
  Map<String, String> localFlow;

  bool headlessMode = false;

  void bootstrap() async {
    this.persistent = await SharedPreferences.getInstance();

    if (this.getPers('headless-mode') == 'true') {
      this.headlessMode = true;
    }
  }

  void toggleHeadless() {
    this.headlessMode = !this.headlessMode;
    this.setPers('headless-mode', this.headlessMode.toString());
  }

  void triggerLocalEvent(String id) {

  }

  void loadEvents() {
    if (S().getPers('local-events') != false) {
      this.localEvents = jsonDecode(S().getPers('local-events'));
    }
  }

  void addLocalEvent(String title) {
    this.localEvents.add(title);
    this.saveLocalEvents();
  }

  void removeLocalEvent(String title) {
    this.localEvents.remove(title);
    this.saveLocalEvents();
  }

  void saveLocalEvents() {
    this.setPers('local-events', jsonEncode(this.localEvents));
  }

  void addFlowStep(String eventOrGroup, String actionId, { Map<String, String> paramValues }) {
    //print(eventOrGroup);
    //print(actionId);
    //print(paramValues);

    // now we have to iterate over both shared and local flows and add the action where eventOrGroup matches the id
  }

  //
  // Flow
  //

  void applySharedFlow(LinkedHashMap<String, List<BehaviorStep>> board) {
    Map<String, dynamic> newFlow = Map();

    board.forEach((eventOrGroup, steps) {
      newFlow[eventOrGroup] = Map();

      steps.forEach((step) {
        switch(step.type) {
          case BehaviorStepType.action:
            newFlow[eventOrGroup][step.id] = Map();

            if (step.params != null) {
              step.params.forEach((param, value) {
                newFlow[eventOrGroup][step.id][param] = value;
              });
            } else {
              newFlow[eventOrGroup][step.id] = null;
            }

            break;
          case BehaviorStepType.group:
            newFlow[eventOrGroup][step.id] = null;
            break;
          default:
            break;
        }
      });
    });

    this.send('flowUpdate', data: newFlow);
  }

  BehaviorStepType determineStepType(String id) {
    // if there is an underscore in the ID, it is an action or event
    if (id.contains('_')) {
      String module = id.split('_')[0];
      id = id.split('_')[1];

      // check if this is an action
      if (this.modules[module]['actions'] is Map) {
        Map actions = this.modules[module]['actions'];
        if (actions.containsKey(id)) {
          return BehaviorStepType.action;
        } else {
          return BehaviorStepType.event;
        }
      // if there are no actions, it's got to be an event
      } else {
        return BehaviorStepType.event;
      }
    // otherwise it's an action group
    } else {
      return BehaviorStepType.group;
    }
  }

  //
  // Server connection
  //

  WebSocket channel;
  bool connected = false;

  List<String> messages = [];

  Future websocketConnect(String address) async {
    this.channel = await WebSocket.connect(address);

    this.channel.stream.listen((event) {
      print(event);
      this.messages.add(event);
      this.processIncomingEvent(event);
    });
  }

  void send(String command, { Map<String, dynamic> data }) {
    Map<String, dynamic> request = {
      'command': command
    };

    if (data != null) request['data'] = data; 

    this.channel.add(jsonEncode(request));
  }

  void checkAutoReconnect() {
    print(this.getPers('auto-reconnect'));

    if (this.getPers('auto-reconnect') != false) {
      if (this.getPers('server-address') != false) {
        this.websocketConnect(this.getPers('server-address'));
      }
    }
  }

  void processIncomingEvent(event) {
    Map<String, dynamic> evt = jsonDecode(event);

    if (this.isCodedData(evt, 1)) this.connectionAccepted(evt);
    if (this.isCodedData(evt, 2)) this.connectionRejected(evt);
    if (this.isCodedData(evt, 3)) this.flowLoaded(evt);
    if (this.isCodedData(evt, 6)) this.modulesLoaded(evt);
  }

  void connectionAccepted(evt) {
    this.connected = true;
    // initial route after establishing a connection
    this.go2('/controls');

    this.send('flowLoad');
    this.send('modulesLoad');
  }

  void connectionRejected(evt) {
    this.alert(this.context, 'The server has rejected connection because another connection to the server is currently active.');
  }

  void flowLoaded(evt) {
    this.sharedFlow = evt['data']['data'];
  }

  void modulesLoaded(evt) {
    this.modules = evt['data']['data'];
  }

  bool isCodedData(evt, code) {
    if (evt['data'] is Map) {
      if (evt['data'].containsKey('code')) {
        if (evt['data']['code'] == code) {
          return true;
        }
      }
    }

    return false;
  }

  //
  // Navigation
  //

  GlobalKey<NavigatorState> navigatorKey;

  Future go2(path, { Map args = const {}, reset: false, pop: false }) {
    if (reset) {
      return this.navigatorKey.currentState.pushNamedAndRemoveUntil(path, (_) => false);
    }

    if (pop) {
      this.navigatorKey.currentState.pop();
    }
    
    return this.navigatorKey.currentState.pushNamed(path, arguments: args);
  }

  void goBack() {
    return this.navigatorKey.currentState.pop();
  }

  //
  // Local data
  //
  
  SharedPreferences persistent;
  String persistentPrefix = 'sh.';

  dynamic getPers(String key) {
    print('Getting ' + key);
    if (this.persistent != null) {
      try {
        String value = this.persistent.getString(this.persistentPrefix + key);
        print('(' + value + ')');
        return value;
      } catch (e) {
        print('(not set)');
        return false;
      }
    } else {
        print('(Persistent storage is null, perhaps not available in the env)');
    }
  }

  void setPers(String key, String val) {
    if (this.persistent != null) {
      this.persistent.setString(this.persistentPrefix + key, val);
      print('Setting ' + key + ' to ' + val);
    }
  }

  //
  // Dialogs
  //

  void confirm(BuildContext context, String question, Function onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text("Notice"),
          content: Text(question),
          actions: [
            FlatButton(
              child: Text('Cancel'),
              onPressed:  () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Proceed'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  void alert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  //
  // Singleton
  //

  static final S _singleton = S._internal();

  factory S() => _singleton;

  S._internal();
}