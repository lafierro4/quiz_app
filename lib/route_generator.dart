import 'package:flutter/material.dart';
import 'package:quiz_app/main.dart';
import 'package:quiz_app/login_form.dart';

class LoginArguments{
  late final String username;
  late final String pin;
  LoginArguments(this.username, this.pin);
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/login' :
        return MaterialPageRoute(builder: (_) => const LoginForm());
      case '/homeScreen' :
        LoginArguments arguments = args as LoginArguments;
          return MaterialPageRoute(builder: (_) =>
              HomeScreen(username: arguments.username, pin: arguments.pin));
      case '/makingQuiz':
        LoginArguments arguments = args as LoginArguments;
        return MaterialPageRoute(builder: (_) =>
          MakeQuiz(username: arguments.username, pin: arguments.pin));
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