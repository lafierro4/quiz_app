import 'dart:io';
import 'package:flutter/material.dart';
import 'package:quiz_app/main.dart';

class Question{
  final int _type; //will hold the type of question is being asked(either multiple choice or fill in blank)
  final String _stem; //Holds the question string
  bool grade; //holds whether the user answered correctly
  String? figure; //holds an optional image url string that links to the webservice

  Question(this._type,this._stem,this.grade,this.figure);

  int get type => _type;
  String get stem => _stem;

  factory Question.fromJson(Map <String,dynamic> data){
    final type = data['type'];
    final stem = data['stem'];
    final figure = data['figure'];
    if(type == 1 ){
      return MultipleChoice.fromJson(data);
    }else if(type == 2){
      return FillInBlank.fromJson(data);
    }
    return Question(type, stem,false,figure);
  }

}


Future<Image> _imageGet(String imageUrl) async{
    HttpOverrides.global = MyHttpOverrides();
    return Image.network("https://www.cs.utep.edu/cheon/cs4381/homework/quiz/figure.php?name=$imageUrl");
}

Widget? _loadImage(String imageUrl){
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

class MultipleChoice extends Question {
  final List<String> _options; //holds the list of answer choices
  int? response; //holds the user's answer
  final int _answer; //holds the correct answer
  get answer => _answer;
  List<String> get options => _options;
  MultipleChoice(type,stem, figure, this._options, this._answer,) : super(type,stem,false,figure);
  factory MultipleChoice.fromJson(Map<String,dynamic> data){
    final type = data['type'];
    final stem = data['stem'];
    final figure = data['figure'];
    var list = data['option'] as List;
    final List<String> options = list.map((i) => i as String).toList();
    final answer = data['answer'];
    return MultipleChoice(type, stem,figure, options, answer, );
  }
}

class FillInBlank extends Question {
  late String response;
  final List<String> _answer;
  get answer => _answer;

  FillInBlank(type,stem,figure, grade, this._answer) : super(type,stem,false,figure);
  factory FillInBlank.fromJson(Map<String,dynamic> data){
    final type = data['type'];
    final stem = data['stem'];
    final figure = data['figure'];
    var list = data['answer'] as List;
    final answer = list.map((i) => i as String).toList();
    return FillInBlank(type,stem,figure,false, answer);
  }
  setResponse(String r) => response = r;
}
class Quiz {
  final String name;
  final List<Question> question;

  Quiz({required this.name, required this.question});

  List<Question> getQuestions(){
    return question;
  }
  String getName() => name;
  factory Quiz.fromJson(Map<String, dynamic> decode) {
    var list = decode['quiz']['question'] as List;
    List<Question> qL = list.map((i) => Question.fromJson(i)).toList();
    return Quiz(
        name : decode['quiz']['name'],
        question: qL
    );
  }
}

Widget askQuestion(Question question){
  Widget? figure;
  if(question.figure != null){
    figure = _loadImage(question.figure!);
  }
   return Scaffold(
     backgroundColor: Colors.black,
     body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(padding: const EdgeInsets.only(left:15, bottom: 20, right: 20, top:10),
                child: Text(question.stem, style: const TextStyle(color: Colors.white, fontSize: 20,),
                  textAlign: TextAlign.left,),),
            if(figure != null) SizedBox(height: 200.0,width: 750.0, child: figure),
            if(question.type == 1 ) _showOptions(question as MultipleChoice),
            if(question.type == 2) _showAnswerField(question as FillInBlank),
       ],
   )));
}

Widget _showAnswerField(FillInBlank question) {
  TextEditingController response = TextEditingController();
  notEmpty(String value) => value.isNotEmpty;
  return TextFormField(
    controller: response,
    style: const TextStyle(color: Colors.purple),
    decoration: const InputDecoration(
      labelText: 'Insert Answer Here',
      filled: true,
      fillColor: Colors.white,
    ),
    validator: (value) =>  notEmpty(value!) ? null : 'A Response is required',
    onChanged: question.setResponse(response.text),
  );
}


Widget _showOptions(MultipleChoice question) {
    return Column(
      children: <Widget>[
        for(int i = 1; i <= question.options.length;i++) ...[
          Radio<int>(value: question.options.indexOf(question.options[i]), groupValue: question.response,
              onChanged: (value) => { question.response = value! } ),
          Expanded(child: textFormatted(question.options[i])) ],
      ]
    );
}

class QuizWidget extends StatelessWidget{
  const QuizWidget({super.key, required this.quiz});
  final Quiz quiz;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget> [
            for(int i = 1; i< quiz.question.length;i++)...[
              Padding(padding: const EdgeInsets.only(bottom: 5),
                child: Text ('Question $i', style: const TextStyle( fontSize: 30,color: Colors.purple),),),
              askQuestion(quiz.question[i]),
          ]
        ]),
      )
    );
  }
}


