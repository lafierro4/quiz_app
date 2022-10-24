import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:quiz_app/question.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

Future<Quiz> makeCurrentQuiz(String username, String pin) async {
  List<Question> questions = await _getQuestionPool(username, pin);
  Quiz currentQuiz = Quiz(name: "Quiz", question: []);
  int numberQuestions = Random().nextInt(11) + 5; //min # of questions 5 & max # of question 15
  for(int i = 0; i < numberQuestions;i++) {
    currentQuiz.getQuestions().add(_getRandomQuestion(questions));
  }
  return currentQuiz;
}

_getQuestionPool(String username, String pin) async{
  HttpOverrides.global = MyHttpOverrides();
  String cQuiz;
  List<Question> questionPool = [];
  for(int i = 1; i <= 15; i++) {
    if(i < 10) {cQuiz = 'quiz0$i';
    } else{ cQuiz = 'quiz$i';}
    var url = Uri.https("www.cs.utep.edu",
        "/cheon/cs4381/homework/quiz/get.php/", {
          "user": username,
          "pin": pin,
          "quiz": cQuiz,
        });
    var response = await http.get(url);
    var decode = json.decode(response.body);

    Quiz q = Quiz.fromJson(decode);
    questionPool.addAll(q.getQuestions());
  }
  return questionPool;
}

Question _getRandomQuestion<Question>(List<Question> list) {
  final random = Random();
  var i = random.nextInt(list.length);
  return list[i];
}

Widget quizProcess(){
  return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AnimatedTextKit( animatedTexts: [
              TyperAnimatedText('Connecting to Server...'),
              TyperAnimatedText('Getting Questions...'),
              TyperAnimatedText('Making Quiz...'),
            ], ),
            const CircularProgressIndicator(semanticsLabel: 'Making Quiz', color: Colors.black, backgroundColor: Colors.purple,)
          ],
        ),
      )
  );
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
