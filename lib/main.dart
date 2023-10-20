import 'package:flutter/material.dart';
import 'package:webapp/screens/display_details.dart';
import '../screens/login_page.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/displayDetails': (context) => DisplayDetailsPage(),
      },
      home: LoginPage(),
    );
  }
}
