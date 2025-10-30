import 'package:expense_manager_app/Screen/errorStartup.dart';
import 'package:expense_manager_app/Screen/homeScreen.dart';
import 'package:expense_manager_app/Screen/startUpScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((value) async {
    await Supabase.initialize(
      url: "https://hbofkqwchejhepriaorx.supabase.co",
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhib2ZrcXdjaGVqaGVwcmlhb3J4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5NTk1NDAsImV4cCI6MjA2OTUzNTU0MH0.9zfICt1sOMu9CRkbmn0v6JmtDD7iY_5N71ZBHSoOuUw",
    );

    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

//Statelesswidget

class _MyAppState extends State<MyApp> {
  //variables
  late Widget _screen;

  final appColor = ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 3, 68, 246),
  );

  //fuctions

  void _getScreen() {
    try {
      User? currentUser = Supabase.instance.client.auth.currentUser;

      if (currentUser == null) {
        setState(() {
          _screen = const StartUpScreen();
        });
      }

      if (currentUser != null) {
        setState(() {
          _screen = const homeScreen();
        });
      }
    } catch (error) {
      setState(() {
        _screen = const ErrorStartup();
      });
    }
  }

  //init fuction

  @override
  void initState() {
    _getScreen();
    super.initState();
  }

  //build

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _screen,
      theme: ThemeData(
        fontFamily: "RobotoFlex",
      ).copyWith(colorScheme: appColor),
    );
  }
}
