import 'package:flutter/material.dart';
import 'package:flutter_meizi/feature/home/home_container.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Mei Zi',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new HomeContainer(),
    );
  }
}
