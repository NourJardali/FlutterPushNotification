import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//this is the name given to the background fetch
const simplePeriodicTask = "simplePeriodicTask";

//flutter local notification setup
void showNotification(v, flp) async {
  var android = AndroidNotificationDetails(
      'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
      priority: Priority.high, importance: Importance.max);
  var iOS = IOSNotificationDetails();
  var platform = NotificationDetails(android: android, iOS: iOS);
  await flp.show(0, 'Virtual Intelligent Solution', '$v', platform,
      payload: 'VIS \n $v');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager.initialize(callbackDispatcher,
      isInDebugMode:
          true); //to true if still in testing lev turn it to false whenever you are launching the app
  await Workmanager.registerPeriodicTask("5", simplePeriodicTask,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      frequency: Duration(minutes: 15), //when should it check the line
      initialDelay:
          Duration(seconds: 5), //duration before showing the notification
      constraints: Constraints(
        networkType: NetworkType.connected,
      ));
  runApp(MyApp());
}

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    FlutterLocalNotificationsPlugin flp = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = IOSInitializationSettings();
    var initSettings = InitializationSettings(android: android, iOS: iOS);
    flp.initialize(initSettings);

    var response =
        await http.post('https://seeviswork.000webhostapp.com/api/testapi.php');
    print("here==============");
    print(response);
    var convert = json.decode(response.body);
    if (convert['status'] == true) {
      showNotification(convert['msg'], flp);
    } else {
      print("no message");
    }
    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Notification',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.teal,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Testing push Notification"),
          centerTitle: true,
        ),
        body: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Text(
                  "Flutter push notification without firebase with background fetch feature"),
            ),
          ),
        ),
      ),
    );
  }
}
