import 'package:flutter/material.dart';
import 'package:quiz_app/main.dart';
import 'package:quiz_app/login_form.dart';

class RouteGenerator {
  static Route generateRoute(Key key, RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/loginPage' :
        return MaterialPageRoute(builder: (_) => LoginForm(key: key));
      default: return _errorPage();
    }
  }
  static Route<dynamic> _errorPage(){
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text ('Unexpected Page Route'),
        ),
        body: const Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}