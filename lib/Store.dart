import 'dart:convert';
import 'dart:collection';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:websocket/websocket.dart';
import 'utils/BehaviorStep.dart';
import 'utils/enums.dart';


class S with ChangeNotifier {

  BuildContext context;

  //
  //  Behavior
  //

  Map<String, dynamic> sharedFlow;
  Map<String, dynamic> modules;

  // List<String> localEvents;
  // List<String> localGroups; // Decided groups will be only global / shared (and local flow will be able to call global groups)
  Map<String, dynamic> localFlow = {};

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
    this.notifyListeners();
  }

  void turnHeadlessOn(bool onOff) {
    this.headlessMode = onOff;
    this.setPers('headless-mode', this.headlessMode.toString());
    this.notifyListeners();
  }

  void triggerLocalEvent(String id) {
    this.localFlow.forEach((String event, steps) {
      if (event == id) {
        if (steps != null) {
          steps.forEach((String actionOrGroup, params) {
            this.send('doStep', data: {
              'step': actionOrGroup,
              'params': params
            });
          });
        } else {
          print('Local event ' + id + " triggered, but there's nothing to do.");
        }
      }
    });
  }

  void loadLocalFlow() {
    if (S().getPers('local-flow') != false) {
      this.localFlow = jsonDecode(S().getPers('local-flow'));
      this.notifyListeners();
    } else {
      // no local behavior has been defined on this device yet
      this.send('loadDefaultLocalFlow');
    }
  }

  void addLocalEvent(String title) {
    this.localFlow[title] = null;
    this.saveLocalFlow();
    this.notifyListeners();
  }

  void addSharedEvent(String id) {
    this.sharedFlow = this.sharedFlow ?? {};

    this.sharedFlow[id] = null;
    this.notifyListeners();
  }

  void removeLocalEvent(String title) {
    this.localFlow.remove(title);
    this.saveLocalFlow();
    this.notifyListeners();
  }

  void saveLocalFlow() {
    this.setPers('local-flow', jsonEncode(this.localFlow));
  }

  void saveDefaultLocalFlow() {
    this.send('updateDefaultLocalFlow', data: this.localFlow);
  }

  void loadDefaultLocalFlow() {
    this.send('loadDefaultLocalFlow');
  }

  void addSharedFlowStep(String eventOrGroup, String actionOrGroupId, { Map<String, String> paramValues }) {
    //print(eventOrGroup);
    //print(actionId);
    //print(paramValues);

    if (this.sharedFlow[eventOrGroup] == null) {
      this.sharedFlow[eventOrGroup] = <String, dynamic>{};
    }

    // in case of a group, null value is expected
    this.sharedFlow[eventOrGroup][actionOrGroupId] = paramValues;

    this.notifyListeners();
  }

  void addLocalFlowStep(String eventOrGroup, String actionOrGroupId, { Map<String, String> paramValues }) {
    if (this.localFlow[eventOrGroup] == null) {
      this.localFlow[eventOrGroup] = <String, dynamic>{};
    }

    // in case of a group, null value is expected
    this.localFlow[eventOrGroup][actionOrGroupId] = paramValues;

    this.saveLocalFlow();

    this.notifyListeners();
  }

  void addGroup(String id) {
    this.sharedFlow = this.sharedFlow ?? {};

    this.sharedFlow[id] = null;
    this.notifyListeners();
  }

  void applySharedFlow(LinkedHashMap<String, List<BehaviorStep>> board) {
    this.send('flowUpdate', data: this.sharedFlow);
  }

  void removeSharedEventOrGroupDefinition(String id) {
    print('Removing a shared event or group definiton: ' + id);
    this.sharedFlow.remove(id);

    print(this.sharedFlow);

    this.notifyListeners();
  }

  void removeSharedActionOrGroupCall(String eventOrGroup, String id) {
    print('Removing a shared action or group call: ' + id + ' from ' + eventOrGroup);

    this.sharedFlow[eventOrGroup].remove(id);

    this.notifyListeners();
  }

  void removeLocalActionOrGroupCall(String event, String id) {
    print('Removing a local action or group call: ' + id + ' from ' + event);

    this.localFlow[event].remove(id);

    this.notifyListeners();
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

  void send(String command, { dynamic data }) {
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
    if (this.isCodedData(evt, 10)) this.defaultLocalFlowLoaded(evt);
  }

  void connectionAccepted(evt) {
    this.connected = true;
    // initial route after establishing a connection
    this.go2('/controls');

    this.send('flowLoad');
    this.send('modulesLoad');
    this.loadLocalFlow();
  }

  void connectionRejected(evt) {
    this.alert(this.context, 'The server has rejected connection because another connection to the server is currently active.');
  }

  void flowLoaded(evt) {
    this.sharedFlow = evt['data']['data'];
  }

  void defaultLocalFlowLoaded(evt) {
    this.localFlow = evt['data']['data'];
    this.notifyListeners();
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