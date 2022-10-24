class Question {
  final int _type; //will hold the type of question is being asked(either multiple choice or fill in blank)
  final String _stem; //Holds the question string
  int grade; //holds whether the user answered correctly

  Question(this._type,this._stem, this.grade);

  int get type => _type;
  String get stem => _stem;

  factory Question.fromJson(Map <String,dynamic> data){
    final type = data['type'];
    final stem = data['stem'];
    if(type == 1 ){
      return MultipleChoice.fromJson(data);
    }else if(type == 2){
      return FillInBlank.fromJson(data);
    }
    return Question(type, stem, 0);
  }
}


class MultipleChoice extends Question {
  final List<String> _options; //holds the list of answer choices
  late int response; //holds the user's answer
  final int _answer; //holds the correct answer
  get answer => _answer;
  get options => _options;
  MultipleChoice(type,stem, this._options, this._answer) : super(type,stem, 0);
  factory MultipleChoice.fromJson(Map<String,dynamic> data){
    final type = data['type'];
    final stem = data['stem'];
    var list = data['option'] as List;
    final List<String> options = list.map((i) => i as String).toList();
    final answer = data['answer'];
    return MultipleChoice(type, stem, options, answer);
  }
}

class FillInBlank extends Question {
  late String response;
  final List<String> _answer;
  get answer => _answer;
  FillInBlank(type,stem, this._answer) : super(type,stem, 0);
  factory FillInBlank.fromJson(Map<String,dynamic> data){
    final type = data['type'];
    final stem = data['stem'];
    var list = data['answer'] as List;
    final answer = list.map((i) => i as String).toList();
    return FillInBlank(type, stem, answer);
  }
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

