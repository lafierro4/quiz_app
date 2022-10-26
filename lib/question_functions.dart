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

Future<Image> _imageGet(String imageUrl) async{
  HttpOverrides.global = MyHttpOverrides();
  return Image.network("https://www.cs.utep.edu/cheon/cs4381/homework/quiz/figure.php?name=$imageUrl");
}

Widget _loadImage(String imageUrl){
  var image = _imageGet(imageUrl);
  return Scaffold(
      body: Center(
          child: FutureBuilder(
            future: image,
            builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
              if (snapshot.hasData) {
                return snapshot.data as Image;
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }else {
                return const CircularProgressIndicator();
              }},
          )
      )
  );
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
    backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AnimatedTextKit( animatedTexts: [
              TyperAnimatedText('Connecting to Server...', textStyle: const TextStyle(color: Colors.white, fontSize: 25)),
              TyperAnimatedText('Getting Questions...', textStyle: const TextStyle(color: Colors.white, fontSize: 25)),
              TyperAnimatedText('Making Quiz...', textStyle: const TextStyle(color: Colors.white, fontSize: 25)),
            ], ),
            const Padding(padding: EdgeInsets.all(20)),
            const CircularProgressIndicator(semanticsLabel: 'Making Quiz', color: Colors.purple, backgroundColor: Colors.white,)
          ],
        ),
      )
  );
}

class AskQuestion extends StatefulWidget{
  final Question question;

  const AskQuestion({super.key, required this.question});

  @override
  State<StatefulWidget> createState() => _AskQuestion();
}

class _AskQuestion extends State<AskQuestion> {
  late Widget figure;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding( padding: const EdgeInsets.only(top: 20, bottom: 10),
            child:Text(widget.question.stem, style: const TextStyle(fontSize: 20, color: Colors.purple),),
        ),
        if(widget.question.figure != null) ...[
          SizedBox(height: 200,width: 100, child: _loadImage(widget.question.figure as String)),
        ],
        if(widget.question.type == 1 )
          _ShowOptions(question: widget.question as MultipleChoice,),
        if(widget.question.type == 2)...[
          const Padding(padding: EdgeInsets.only(bottom: 20)),
          _AnswerField(question: widget.question as FillInBlank),
        ],
      ]
    );
  }
}
class _AnswerField extends StatefulWidget{
  const _AnswerField({super.key, required this.question});
  final FillInBlank question;

  @override
  State<_AnswerField> createState () => _AnswerFieldW();
}

class _AnswerFieldW extends State<_AnswerField> {
  TextEditingController userResponse = TextEditingController();
  notEmpty(String value) => value.isNotEmpty;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: userResponse,
      style: const TextStyle(color: Colors.purple),
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'Insert Answer Here',
      ),
      validator: (value) =>  notEmpty(value!) ? null : 'A Response is required',
      onChanged: (userResponse) => setState( (){
        widget.question.response = userResponse;
      }),
      );
  }
}



class _ShowOptions extends StatefulWidget {

  const _ShowOptions({super.key, required this.question});
  final MultipleChoice question;

  @override
  State<_ShowOptions> createState() => _ShowOptionsW();
}

class _ShowOptionsW extends State<_ShowOptions>{
  @override
  Widget build(BuildContext context) {
      return Column(
          children: <Widget>[
            for(int i = 1; i <= widget.question.options.length;i++)...[
              Row( children: <Widget>[
                Radio<int>(
                  value: widget.question.options.indexOf(widget.question.options[i  - 1]) + 1 ,
                  groupValue: widget.question.response,
                  onChanged: (value) => { setState(() {
                    widget.question.response = value; } )},
                  fillColor: MaterialStateProperty.all(Colors.purple),
                  overlayColor: MaterialStateProperty.all(Colors.white),
              ),
                Flexible(child: Text((widget.question.options[i-1]),
                  style: const TextStyle(fontSize: 15, color: Colors.white),textAlign: TextAlign.left,),
                )
    ]
              ) ]
          ]
      );
  }
}


class QuizStart extends StatefulWidget{
  const QuizStart({super.key, required this.quiz});
  final Quiz quiz;

  @override
  State<QuizStart> createState() => _QuizStart();
}

class _QuizStart extends State<QuizStart>{
  int numQuestions = 0;
  int _currentIndex = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
            currentIndex: _currentIndex,
            items: const [
          BottomNavigationBarItem(
            backgroundColor: Colors.black,
              label: 'Previous',
              icon: Icon(Icons.navigate_before)),
          BottomNavigationBarItem(
            backgroundColor: Colors.black,
            label:  'Next',
              icon: Icon(Icons.navigate_next),
            ),
          ],
          onTap: (index){
            _currentIndex = index;
            setState(() {
              if(_currentIndex == 0){
                numQuestions-1;
              }else if(_currentIndex == 1){
                numQuestions+1;
              }
            });
          },
        ),
        appBar: AppBar(
          title: Text("Question ${numQuestions+1}"),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
              children: <Widget> [
                  Expanded(flex: 2,child:AskQuestion(question: widget.quiz.question[numQuestions],)),
              ]
          ),
        )
    );
  }
}

class GradeQuiz extends StatefulWidget {
  final Quiz quiz;

  const GradeQuiz({super.key, required this.quiz});

  @override
  State<StatefulWidget> createState() => _GradeQuiz();

}

class _GradeQuiz extends State<GradeQuiz>{
  double finalGrade = 0;
  int numRight = 0;
  gradeQuiz(Quiz quiz){
    double worth = 100.0 / quiz.question.length;
    for(Question q in quiz.question){
      if(q.type == 1){
        if((q as MultipleChoice).response == (q).answer){
          finalGrade += worth;
          numRight++;
        }
      }else if(q.type ==2){
        if((q as FillInBlank).response != null && equalsIgnoreCase(q.response!, q.answer)){
          finalGrade += worth;
          numRight++;
        }
      }
    }
  }
  bool equalsIgnoreCase(String s1, String s2){
    return s1.toLowerCase() == s2.toLowerCase();
  }
  @override
  void initState() {
    super.initState();
    gradeQuiz(widget.quiz);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Complete',)
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text("You Completed the Quiz",
              style: TextStyle(fontSize: 20, color: Colors.purple),),
            Text("You got $numRight out of ${widget.quiz.question.length}",
              style: const TextStyle(fontSize: 20, color: Colors.purple),),
            Text("Your Final Score is $finalGrade",
              style: const TextStyle(fontSize: 20, color: Colors.purple),),
            const Text("Have a Good Day",
              style: TextStyle(fontSize: 20, color: Colors.purple),),
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
