import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kid_arena/models/question.dart';
import 'package:kid_arena/models/test.dart';
import 'package:kid_arena/models/class.dart';
import 'package:kid_arena/services/test_service.dart';
import 'package:kid_arena/services/class_service.dart';
import 'package:kid_arena/services/getIt.dart';

class CreateTestScreen extends StatefulWidget {
  final String? classId;

  const CreateTestScreen({super.key, this.classId});

  @override
  State<CreateTestScreen> createState() => _CreateTestScreenState();
}

class _CreateTestScreenState extends State<CreateTestScreen> {
  // Form and state management
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Test information
  String _testTitle = '';
  String _subject = 'Mixed';
  String _testDescription = '';
  int _duration = 60;
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(days: 1));
  String? _selectedClassId;
  List<Class> _classes = [];

  // Questions management
  final List<Question> _questions = [];
  final TestService _testService = TestService();
  final List<String> _options = ['A', 'B', 'C', 'D'];
  final List<TextEditingController> _optionControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  String _currentQuestionText = '';
  int _currentCorrectAnswer = 0;

  @override
  void initState() {
    super.initState();
    _selectedClassId = widget.classId;
    if (widget.classId == null) {
      _loadClasses();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo bài thi'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / 2,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [_buildTestInfoPanel(), _buildQuestionsPanel()],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha(125),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
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
        _showErrorSnackBar('Lỗi khi tải danh sách lớp: $e');
      }
    }
  }

  Future<void> _selectDateTime(bool isStartTime) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartTime ? _startTime : _endTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStartTime ? _startTime : _endTime),
    );

    if (pickedTime == null) return;

    setState(() {
      final newDateTime = DateTime(
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
      } else if (newDateTime.isAfter(_startTime)) {
        _endTime = newDateTime;
      } else {
        _showErrorSnackBar('Thời gian kết thúc phải sau thời gian bắt đầu');
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (context) => _buildAddQuestionDialog(),
    );
  }

  Widget _buildAddQuestionDialog() {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
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
                ...List.generate(4, (index) => _buildOptionInput(index)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: _resetQuestionForm, child: const Text('Hủy')),
            TextButton(
              onPressed: () => _handleAddQuestion(context),
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptionInput(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Radio<int>(
            value: index,
            groupValue: _currentCorrectAnswer,
            onChanged:
                (value) => setState(() => _currentCorrectAnswer = value!),
          ),
          Expanded(
            child: TextFormField(
              controller: _optionControllers[index],
              decoration: InputDecoration(
                labelText: 'Đáp án ${_options[index]}',
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetQuestionForm() {
    for (var controller in _optionControllers) {
      controller.clear();
    }
    _currentQuestionText = '';
    _currentCorrectAnswer = 0;
    Navigator.pop(context);
  }

  void _handleAddQuestion(BuildContext context) {
    final options =
        _optionControllers
            .map((controller) => controller.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();

    if (_currentQuestionText.isEmpty || options.length < 2) {
      _showErrorSnackBar('Vui lòng nhập đầy đủ câu hỏi và ít nhất 2 lựa chọn');
      return;
    }

    setState(() {
      _questions.add(
        Question(
          questionText: _currentQuestionText,
          correctAnswer: _currentCorrectAnswer,
          options: options,
        ),
      );
      _resetQuestionForm();
    });
  }

  Future<void> _saveTest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_questions.isEmpty) {
      _showErrorSnackBar('Vui lòng thêm ít nhất một câu hỏi');
      return;
    }
    if (_selectedClassId == null) {
      _showErrorSnackBar('Vui lòng chọn lớp học');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final test = Test(
        id: '',
        title: _testTitle,
        subject: _subject,
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
        _showSuccessSnackBar('Tạo bài thi thành công!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Lỗi khi tạo bài thi: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTestInfoPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.classId == null) _buildClassDropdown(),
            const SizedBox(height: 16),
            _buildTitleInput(),
            const SizedBox(height: 16),
            _buildSubjectInput(),
            const SizedBox(height: 16),
            _buildDescriptionInput(),
            const SizedBox(height: 16),
            _buildDurationInput(),
            const SizedBox(height: 16),
            _buildDateTimePickers(),
            const SizedBox(height: 24),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildClassDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Chọn lớp học',
        border: OutlineInputBorder(),
      ),
      value: _selectedClassId,
      items:
          _classes
              .map(
                (classroom) => DropdownMenuItem<String>(
                  value: classroom.id,
                  child: Text(classroom.name),
                ),
              )
              .toList(),
      onChanged: (value) => setState(() => _selectedClassId = value),
      validator:
          (value) =>
              value == null || value.isEmpty ? 'Vui lòng chọn lớp học' : null,
    );
  }

  Widget _buildTitleInput() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Tiêu đề bài thi',
        border: OutlineInputBorder(),
      ),
      validator:
          (value) =>
              value == null || value.isEmpty
                  ? 'Vui lòng nhập tiêu đề bài thi'
                  : null,
      onChanged: (value) => _testTitle = value,
    );
  }

  Widget _buildSubjectInput() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Môn học',
        border: OutlineInputBorder(),
      ),
      validator:
          (value) =>
              value == null || value.isEmpty ? 'Vui lòng nhập môn học' : null,
      onChanged: (value) => _subject = value,
    );
  }

  Widget _buildDescriptionInput() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Mô tả bài thi',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      onChanged: (value) => _testDescription = value,
    );
  }

  Widget _buildDurationInput() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Thời gian làm bài (phút)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      initialValue: _duration.toString(),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Vui lòng nhập thời gian';
        final number = int.tryParse(value);
        if (number == null || number <= 0) return 'Thời gian phải lớn hơn 0';
        return null;
      },
      onChanged: (value) => _duration = int.tryParse(value) ?? 60,
    );
  }

  Widget _buildDateTimePickers() {
    return Row(
      children: [
        _buildDateTimePicker(true, 'Thời gian bắt đầu', _startTime),
        const SizedBox(width: 8),
        _buildDateTimePicker(false, 'Thời gian kết thúc', _endTime),
      ],
    );
  }

  Widget _buildDateTimePicker(bool isStartTime, String title, DateTime date) {
    return Expanded(
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: () => _selectDateTime(isStartTime),
      ),
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: const Text('Tiếp tục thêm câu hỏi'),
    );
  }

  Widget _buildQuestionsPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildQuestionHeader(),
          const SizedBox(height: 16),
          ..._questions.asMap().entries.map(
            (entry) => _buildQuestionCard(entry),
          ),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Danh sách câu hỏi',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ElevatedButton.icon(
          onPressed: _addQuestion,
          icon: const Icon(Icons.add),
          label: const Text('Thêm câu hỏi'),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(MapEntry<int, Question> entry) {
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
          onPressed: () => setState(() => _questions.removeAt(index)),
        ),
        children: [_buildQuestionOptions(question)],
      ),
    );
  }

  Widget _buildQuestionOptions(Question question) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Các lựa chọn:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...question.options.asMap().entries.map(
            (option) => _buildOptionItem(
              option.key,
              option.value,
              question.correctAnswer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(int index, String text, int correctAnswerIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 12,
            color: correctAnswerIndex == index ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            '${index + 1}. $text',
            style: TextStyle(
              fontWeight:
                  correctAnswerIndex == index
                      ? FontWeight.bold
                      : FontWeight.normal,
              color: correctAnswerIndex == index ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed:
                () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
            child: const Text('Quay lại'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveTest,
            child:
                _isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Tạo bài thi'),
          ),
        ),
      ],
    );
  }
}
