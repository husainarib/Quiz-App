import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/question.dart';
import 'summary_screen.dart';

class QuizScreen extends StatefulWidget {
  final Map<String, dynamic> settings;

  const QuizScreen({super.key, required this.settings});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  Timer? _timer;
  int _remainingTime = 10;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  // Fetch questions method
  Future<void> _fetchQuestions() async {
    final url =
        'https://opentdb.com/api.php?amount=${widget.settings['numQuestions']}&category=${widget.settings['category']}&difficulty=${widget.settings['difficulty']}&type=${widget.settings['type']}';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['results'] != null &&
        data['results'].isNotEmpty) {
      setState(() {
        _questions = data['results']
            .map<Question>((json) => Question.fromJson(json))
            .toList();
        _isLoading = false;
      });
      _startTimer();
    } else {
      setState(() {
        _isLoading = false;
      });
      _showNoQuestionsDialog();
    }
  }

  // DEBUG for no questions appearing
  void _showNoQuestionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Questions Found'),
        content: const Text(
            'The selected quiz settings returned no questions. Please try a different category.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Timer method
  void _startTimer() {
    _remainingTime = 10;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          timer.cancel();
          _nextQuestion();
        }
      });
    });
  }

  // Next question method
  void _nextQuestion() {
    if (_currentQuestionIndex + 1 < _questions.length) {
      setState(() {
        _currentQuestionIndex++;
        _remainingTime = 10;
      });
      _startTimer();
    } else {
      _timer?.cancel();
      _showSummary();
    }
  }

  // Show summary method
  void _showSummary() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SummaryScreen(score: _score, total: _questions.length),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(
          child: Text('No questions available. Please go back and try again.'),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Question ${_currentQuestionIndex + 1}/${_questions.length}'),
      ),
      body: Container(
        color: Colors.lightBlue[50],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              question.questionText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 32),
            ...question.shuffledAnswers.map((option) {
              return Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (option == question.correctAnswer) {
                        _score++;
                      }
                      _nextQuestion();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                      ),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }).toList(),
            // Timer text
            Text(
              'Time Remaining: $_remainingTime seconds',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
