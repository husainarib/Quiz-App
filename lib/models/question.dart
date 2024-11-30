class Question {
  final String questionText;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  late final List<String> shuffledAnswers;

  Question({
    required this.questionText,
    required this.correctAnswer,
    required this.incorrectAnswers,
  }) {
    shuffledAnswers = List<String>.from(incorrectAnswers)
      ..add(correctAnswer)
      ..shuffle();
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionText: json['question'] as String,
      correctAnswer: json['correct_answer'] as String,
      incorrectAnswers: List<String>.from(json['incorrect_answers']),
    );
  }
}
