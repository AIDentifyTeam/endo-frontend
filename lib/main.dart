import 'package:flutter/material.dart';
import 'theme.dart';
import 'routes.dart';

void main() => runApp(EndoApp());

class EndoApp extends StatelessWidget {
  const EndoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EndoApp',
      theme: appTheme,
      initialRoute: Routes.login,
      routes: Routes.map,
    );
  }
}
