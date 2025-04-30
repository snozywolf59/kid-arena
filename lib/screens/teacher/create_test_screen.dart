import 'package:flutter/material.dart';
import 'package:kid_arena/models/question.dart';
import 'package:kid_arena/models/test.dart';
import 'package:kid_arena/services/test_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateTestScreen extends StatefulWidget {
  const CreateTestScreen({super.key});

  @override
  State<CreateTestScreen> createState() => _CreateTestScreenState();
}

class _CreateTestScreenState extends State<CreateTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Question> _questions = [];
  final TestService _testService = TestService();
  String _testTitle = '';
  String _testDescription = '';
  bool _isLoading = false;

  String _currentQuestionText = '';
  String _currentCorrectAnswer = '';
  List<String> _currentOptions = [];

  void _addQuestion() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Question'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Question Text',
                    ),
                    onChanged: (value) => _currentQuestionText = value,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Correct Answer',
                    ),
                    onChanged: (value) => _currentCorrectAnswer = value,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Options (comma separated)',
                    ),
                    onChanged:
                        (value) =>
                            _currentOptions =
                                value.split(',').map((e) => e.trim()).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (_currentQuestionText.isNotEmpty &&
                      _currentCorrectAnswer.isNotEmpty &&
                      _currentOptions.isNotEmpty) {
                    setState(() {
                      _questions.add(
                        Question(
                          questionText: _currentQuestionText,
                          correctAnswer: _currentCorrectAnswer,
                          options: _currentOptions,
                        ),
                      );
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  Future<void> _saveTest() async {
    if (!_formKey.currentState!.validate() || _questions.isEmpty) {
      if (_questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one question')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final test = Test(
        id: '', // Will be set by Firestore
        title: _testTitle,
        description: _testDescription,
        questions: _questions,
        teacherId: FirebaseAuth.instance.currentUser?.uid ?? '',
        createdAt: DateTime.now(),
      );

      await _testService.createTest(test);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating test: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Test')),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Test Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a test title';
                    }
                    return null;
                  },
                  onChanged: (value) => _testTitle = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Test Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (value) => _testDescription = value,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Questions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ..._questions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final question = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(question.questionText),
                          const SizedBox(height: 8),
                          Text('Correct Answer: ${question.correctAnswer}'),
                          const SizedBox(height: 8),
                          Text('Options: ${question.options.join(", ")}'),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _questions.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _addQuestion,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Question'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveTest,
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Create Test'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
