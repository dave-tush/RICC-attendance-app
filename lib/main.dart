import 'package:firebase_core/firebase_core.dart';
import 'package:first_project/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Provider/attendance_provider.dart';
import 'tabs/home_tabs.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  print('about to initialise firebase...');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  print("intialized");
  runApp(
    ChangeNotifierProvider(
      create: (context) => AttendanceProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance Sheet',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
