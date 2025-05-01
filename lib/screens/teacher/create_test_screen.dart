import 'package:flutter/material.dart';
import 'package:kid_arena/models/question.dart';
import 'package:kid_arena/models/test.dart';
import 'package:kid_arena/models/class.dart';
import 'package:kid_arena/services/test_service.dart';
import 'package:kid_arena/services/class_service.dart';
import 'package:kid_arena/services/getIt.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateTestScreen extends StatefulWidget {
  final String? classId;

  const CreateTestScreen({super.key, this.classId});

  @override
  State<CreateTestScreen> createState() => _CreateTestScreenState();
}

class _CreateTestScreenState extends State<CreateTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Question> _questions = [];
  final TestService _testService = TestService();
  String _testTitle = '';
  String _testDescription = '';
  int _duration = 60; // Default duration in minutes
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(days: 1));
  bool _isLoading = false;
  String? _selectedClassId;
  List<Class> _classes = [];

  String _currentQuestionText = '';
  int _currentCorrectAnswer = 0;

  List<String> options = ['A', 'B', 'C', 'D'];

  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedClassId = widget.classId;
    if (widget.classId == null) {
      _loadClasses();
    }
  }

  Future<void> _loadClasses() async {
    try {
      final classes = await getIt<ClassService>().getClasses().first;
      setState(() {
        _classes = classes;
        if (classes.isNotEmpty) {
          _selectedClassId = classes.first.id;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách lớp: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDateTime(bool isStartTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartTime ? _startTime : _endTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStartTime ? _startTime : _endTime,
        ),
      );
      if (pickedTime != null) {
        setState(() {
          final DateTime newDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isStartTime) {
            _startTime = newDateTime;
            if (_endTime.isBefore(_startTime)) {
              _endTime = _startTime.add(const Duration(days: 1));
            }
          } else {
            if (newDateTime.isAfter(_startTime)) {
              _endTime = newDateTime;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Thời gian kết thúc phải sau thời gian bắt đầu',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        });
      }
    }
  }

  void _addQuestion() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Thêm câu hỏi'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Nội dung câu hỏi',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                          onChanged: (value) => _currentQuestionText = value,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Các lựa chọn:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(4, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Radio<int>(
                                  value: index,
                                  groupValue: _currentCorrectAnswer,
                                  onChanged: (value) {
                                    setState(() {
                                      _currentCorrectAnswer = value!;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: _optionControllers[index],
                                    decoration: InputDecoration(
                                      labelText: 'Đáp án ${options[index]}',
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Reset controllers
                        for (var controller in _optionControllers) {
                          controller.clear();
                        }
                        _currentQuestionText = '';
                        _currentCorrectAnswer = 0;
                        Navigator.pop(context);
                      },
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        final options =
                            _optionControllers
                                .map((controller) => controller.text.trim())
                                .where((text) => text.isNotEmpty)
                                .toList();

                        if (_currentQuestionText.isNotEmpty &&
                            options.length >= 2) {
                          this.setState(() {
                            _questions.add(
                              Question(
                                questionText: _currentQuestionText,
                                correctAnswer: _currentCorrectAnswer,
                                options: options,
                              ),
                            );
                          });
                          // Reset controllers
                          for (var controller in _optionControllers) {
                            controller.clear();
                          }
                          _currentQuestionText = '';
                          _currentCorrectAnswer = 0;
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Vui lòng nhập đầy đủ câu hỏi và ít nhất 2 lựa chọn',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text('Thêm'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _saveTest() async {
    if (!_formKey.currentState!.validate() || _questions.isEmpty) {
      if (_questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng thêm ít nhất một câu hỏi')),
        );
      }
      return;
    }

    if (_selectedClassId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn lớp học')));
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
        duration: _duration,
        startTime: _startTime,
        endTime: _endTime,
        classId: _selectedClassId!,
        questions: _questions,
        teacherId: FirebaseAuth.instance.currentUser?.uid ?? '',
        createdAt: DateTime.now(),
      );

      await _testService.createTest(test);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo bài thi thành công!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tạo bài thi: $e'),
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
      appBar: AppBar(title: const Text('Tạo bài thi')),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (widget.classId == null) ...[
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Chọn lớp học',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedClassId,
                    items:
                        _classes.map((Class classroom) {
                          return DropdownMenuItem<String>(
                            value: classroom.id,
                            child: Text(classroom.name),
                          );
                        }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedClassId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng chọn lớp học';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề bài thi',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tiêu đề bài thi';
                    }
                    return null;
                  },
                  onChanged: (value) => _testTitle = value,
                ),

                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Mô tả bài thi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (value) => _testDescription = value,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Thời gian làm bài (phút)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: _duration.toString(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập thời gian';
                          }
                          final number = int.tryParse(value);
                          if (number == null || number <= 0) {
                            return 'Thời gian phải lớn hơn 0';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _duration = int.tryParse(value) ?? 60;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Thời gian bắt đầu'),
                        subtitle: Text(
                          '${_startTime.day}/${_startTime.month}/${_startTime.year} ${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDateTime(true),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('Thời gian kết thúc'),
                        subtitle: Text(
                          '${_endTime.day}/${_endTime.month}/${_endTime.year} ${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDateTime(false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Danh sách câu hỏi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addQuestion,
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm câu hỏi'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._questions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final question = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ExpansionTile(
                      title: Text(
                        'Câu ${index + 1}: ${question.questionText}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        'Đáp án đúng: ${question.options[question.correctAnswer]}',
                        style: const TextStyle(color: Colors.green),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _questions.removeAt(index);
                          });
                        },
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Các lựa chọn:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ...question.options.asMap().entries.map((option) {
                                final optionIndex = option.key;
                                final optionText = option.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 12,
                                        color:
                                            question.correctAnswer ==
                                                    optionIndex
                                                ? Colors.green
                                                : Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${optionIndex + 1}. $optionText',
                                        style: TextStyle(
                                          fontWeight:
                                              question.correctAnswer ==
                                                      optionIndex
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                          color:
                                              question.correctAnswer ==
                                                      optionIndex
                                                  ? Colors.green
                                                  : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveTest,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Tạo bài thi'),
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
