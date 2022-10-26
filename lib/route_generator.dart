import 'package:flutter/material.dart';
import 'package:quiz_app/main.dart';
import 'package:quiz_app/login_form.dart';
import 'package:quiz_app/question.dart';
import 'package:quiz_app/question_functions.dart';

class LoginArguments{
  late final String username;
  late final String pin;
  LoginArguments(this.username, this.pin);
}
class QuizArgs{
  late final Quiz quiz;
  QuizArgs(this.quiz);
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
      case '/quizStart' :
        QuizArgs argument = args as QuizArgs;
        return MaterialPageRoute (builder: (_) => QuizStart(quiz: argument.quiz));

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