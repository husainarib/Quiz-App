import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import 'quiz_screen.dart';

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  final List<int> _numQuestionsOptions = [5, 10, 15];
  final List<String> _difficultyOptions = ['easy', 'medium', 'hard'];
  final List<String> _typeOptions = ['multiple', 'boolean'];

  int _selectedNumQuestions = 5;
  String _selectedDifficulty = 'easy';
  String _selectedType = 'multiple';
  Category? _selectedCategory;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final response =
        await http.get(Uri.parse('https://opentdb.com/api_category.php'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['trivia_categories'] as List;
      setState(() {
        _categories = data.map((json) => Category.fromJson(json)).toList();
      });
      // DEBUG fetched categories
      print('Categories fetched: ${_categories.map((c) => c.name).toList()}');
    }
  }

  // DEBUG fetched categories
  void _showValidationError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid Input'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QUESTIONS
            DropdownButtonFormField<int>(
              value: _selectedNumQuestions,
              onChanged: (value) =>
                  setState(() => _selectedNumQuestions = value!),
              items: _numQuestionsOptions
                  .map((num) => DropdownMenuItem(
                      value: num, child: Text('$num Questions')))
                  .toList(),
              decoration:
                  const InputDecoration(labelText: 'Number of Questions'),
            ),
            const SizedBox(height: 16),
            // DIFFICULTY
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              onChanged: (value) =>
                  setState(() => _selectedDifficulty = value!),
              items: _difficultyOptions
                  .map((difficulty) => DropdownMenuItem(
                      value: difficulty, child: Text(difficulty)))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Difficulty'),
            ),
            const SizedBox(height: 16),
            // TYPE OF QUESTION
            DropdownButtonFormField<String>(
              value: _selectedType,
              onChanged: (value) => setState(() => _selectedType = value!),
              items: _typeOptions
                  .map((type) =>
                      DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            const SizedBox(height: 16),
            // CATEGORY
            DropdownButtonFormField<Category>(
              value: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              items: _categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.name),
                      ))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 32),
            // If category is not selected
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedCategory == null) {
                    _showValidationError('Please select a category.');
                  } else if (_selectedCategory!.id == 0) {
                    // Example: Invalid ID
                    _showValidationError('Invalid category selected.');
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          settings: {
                            'numQuestions': _selectedNumQuestions,
                            'difficulty': _selectedDifficulty,
                            'type': _selectedType,
                            'category': _selectedCategory?.id,
                          },
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Start Quiz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
