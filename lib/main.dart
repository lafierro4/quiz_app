import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:quiz_app/question.dart';
import 'package:quiz_app/login_form.dart';
import 'package:quiz_app/question_functions.dart';
import 'package:quiz_app/route_generator.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      initialRoute: '/login',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key, required this.username, required this.pin});
  final String username;
  final String pin;
  @override
  State<HomeScreen> createState() => _HomeScreen();
}


class _HomeScreen extends State<HomeScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome ${widget.username}"),),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:   <Widget>[
             const Text("This is a Quiz making app\nIt will make a Quiz composed of randomly selected questions\nTap the Button below to start\n\n",
              style: TextStyle(color: Colors.white, fontSize: 25,),
            textAlign: TextAlign.center  ),
            TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/makingQuiz',arguments: LoginArguments(widget.username, widget.pin)),
                style: ButtonStyle( backgroundColor: MaterialStateProperty.all(Colors.purple)),
                child: const Text("Make Quiz", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),))
          ],
        )
      ),
    );
  }

}

class MakeQuiz extends StatefulWidget {
  const MakeQuiz({super.key, required this.username, required this.pin});

  final String username;
  final String pin;

  @override
  State<MakeQuiz> createState() => _QuizMaking();

}
class _QuizMaking extends State<MakeQuiz> {
  late Future<Quiz> quiz;

  @override
  void initState() {
    super.initState();
    quiz = makeCurrentQuiz(widget.username, widget.pin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Quizzing Time'),),
        body: Center(
          child: FutureBuilder(
    future: quiz,
    builder: (BuildContext context, AsyncSnapshot<Quiz> fQuiz) {
    if(fQuiz.hasData){
    return QuizReady(title: 'Quizzing Time', quiz: fQuiz.data as Quiz);
    }else if(fQuiz.hasError){
    return Text("Error has occurred: ${fQuiz.error}");
    }else{
    return quizProcess();
    }}   ),
    )
    );
  }
}
class QuizReady extends StatefulWidget {
  const QuizReady({super.key, required this.title, required this.quiz});

  final String title;
  final Quiz quiz;

  @override
  State<QuizReady> createState() => _QuizReady();
}
class _QuizReady extends State<QuizReady>{
  @override
  Widget build(BuildContext context){
    double questionWorth = 100.0 / widget.quiz.getQuestions().length;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text("Quiz is ready"),
            Text("Consist of ${widget.quiz.getQuestions().length} Questions"),
            Text("Each Question is worth ${questionWorth.toStringAsFixed(2)} for a total of 100.0 points"),
            //button to Quiz here
          ],

        ),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
