import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kid_arena/constants/subject.dart';
import 'package:kid_arena/models/public_test.dart';
import 'package:kid_arena/models/question.dart';
import 'package:kid_arena/models/student_answer.dart';
import 'package:kid_arena/widgets/student/subject_card.dart';
import 'package:kid_arena/widgets/student/test_card.dart';
import 'package:kid_arena/services/test_service.dart';
import 'package:kid_arena/services/get_it.dart';

List<PublicTest> getExamsBySubject(Subject subject) {
  if (subject == Subject.mathematics) {
    return [
      PublicTest(
        id: 'math_1',
        title: 'Đại số lớp 7',
        description: 'Dễ',
        duration: 30,
        subject: subject.name,
        grade: 1,
        questions: [
          Question(
            questionText: 'Giải phương trình: 2x + 5 = 15',
            options: ['x = 5', 'x = 10', 'x = 7.5', 'x = 8'],
            correctAnswer: 0,
          ),
          Question(
            questionText: 'Tính: (3x + 2)(x - 1)',
            options: [
              '3x² - x - 2',
              '3x² + x - 2',
              '3x² - x + 2',
              '3x² + x + 2',
            ],
            correctAnswer: 0,
          ),
        ],
        createdAt: DateTime.now(),
      ),
      PublicTest(
        id: 'math_2',
        title: 'Hình học lớp 7',
        description: 'Trung bình',
        duration: 45,
        subject: subject.name,
        questions: [
          Question(
            questionText:
                'Tính diện tích hình chữ nhật có chiều dài 5cm và chiều rộng 3cm',
            options: ['15cm²', '16cm²', '14cm²', '17cm²'],
            correctAnswer: 0,
          ),
          Question(
            questionText: 'Tính chu vi hình tròn có bán kính 4cm',
            options: ['25.12cm', '25.13cm', '25.14cm', '25.15cm'],
            correctAnswer: 0,
          ),
        ],
        createdAt: DateTime.now(),
        grade: 1,
      ),
    ];
  }
  if (subject == Subject.literature) {
    return [
      PublicTest(
        id: 'lit_1',
        title: 'Tác phẩm văn học lớp 7',
        description: 'Dễ',
        duration: 30,
        subject: subject.name,
        grade: 1,
        questions: [
          Question(
            questionText: 'Tác giả của bài thơ "Qua Đèo Ngang" là ai?',
            options: [
              'Bà Huyện Thanh Quan',
              'Nguyễn Du',
              'Hồ Xuân Hương',
              'Nguyễn Trãi',
            ],
            correctAnswer: 0,
          ),
        ],
        createdAt: DateTime.now(),
      ),
    ];
  }
  if (subject == Subject.english) {
    return [
      PublicTest(
        id: 'eng_1',
        title: 'Ngữ pháp cơ bản',
        description: 'Dễ',
        duration: 20,
        subject: subject.name,
        questions: [
          Question(
            questionText: 'Chọn đáp án đúng: She ___ to school every day.',
            options: ['go', 'goes', 'going', 'went'],
            correctAnswer: 1,
          ),
        ],
        createdAt: DateTime.now(),
        grade: 1,
      ),
    ];
  }
  if (subject == Subject.naturalScience) {
    return [
      PublicTest(
        id: 'sci_1',
        title: 'Cơ học đơn giản',
        description: 'Dễ',
        duration: 30,
        subject: subject.name,
        questions: [
          Question(
            questionText: 'Đơn vị đo lực là gì?',
            options: ['Newton', 'Pascal', 'Joule', 'Watt'],
            correctAnswer: 0,
          ),
        ],
        createdAt: DateTime.now(),
        grade: 1,
      ),
    ];
  }
  if (subject == Subject.socialScience) {
    return [
      PublicTest(
        id: 'soc_1',
        title: 'Lịch sử đơn giản',
        description: 'Dễ',
        duration: 30,
        subject: subject.name,
        grade: 1,
        questions: [
          Question(
            questionText:
                'Năm 1945, sự kiện nào đánh dấu sự kết thúc của Chiến tranh thế giới thứ hai?',
            options: [
              'Nhật Bản đầu hàng',
              'Đức đầu hàng',
              'Ý đầu hàng',
              'Pháp đầu hàng',
            ],
            correctAnswer: 0,
          ),
        ],
        createdAt: DateTime.now(),
      ),
    ];
  }
  return [];
}

class PublicTestsScreen extends StatelessWidget {
  const PublicTestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xin chào, Học sinh!',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Hãy cùng học nào! 🚀',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue[100],
                    child: const Icon(
                      Icons.person,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A5AE0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lightbulb,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Mẹo học tập',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Ôn tập 30 phút mỗi ngày sẽ giúp bạn nhớ kiến thức tốt hơn!',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: const Text(
                'Chọn môn học',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: Subject.values.length,
                  itemBuilder: (context, index) {
                    return SubjectCard(
                      subject: Subject.values[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ExamsScreen(subject: Subject.values[index]),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExamsScreen extends StatefulWidget {
  final Subject subject;

  const ExamsScreen({super.key, required this.subject});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  final TestService _testService = getIt<TestService>();
  List<PublicTest> _tests = [];
  List<StudentAnswer> _studentAnswers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final studentId = FirebaseAuth.instance.currentUser?.uid;
      if (studentId == null) return;

      final tests = getExamsBySubject(widget.subject);
      final answers = await _testService.getStudentAnswersForPublicTests(
        studentId,
      );

      setState(() {
        _tests = tests;
        _studentAnswers = answers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')));
      }
    }
  }

  List<PublicTest> _getUncompletedTests() {
    final completedTestIds = _studentAnswers.map((a) => a.testId).toSet();
    return _tests.where((test) => !completedTestIds.contains(test.id)).toList();
  }

  List<PublicTest> _getCompletedTests() {
    final completedTestIds = _studentAnswers.map((a) => a.testId).toSet();
    return _tests.where((test) => completedTestIds.contains(test.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(26),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.subject.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: widget.subject.color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.subject.icon,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bắt đầu học',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hãy chọn một bài thi để bắt đầu ôn tập',
                              style: TextStyle(
                                color: Colors.white.withAlpha(230),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[600],
                    indicator: BoxDecoration(
                      color: widget.subject.color,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    tabs: const [
                      Tab(text: 'Chưa làm'),
                      Tab(text: 'Đã hoàn thành'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: [
                    // Tab 1: Uncompleted Tests
                    _uncompletedTests(),
                    // Tab 2: Completed Tests
                    _completedTests(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListView _completedTests() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _getCompletedTests().length,
      itemBuilder: (context, index) {
        final exam = _getCompletedTests()[index];
        final studentAnswer = _studentAnswers.firstWhere(
          (answer) => answer.testId == exam.id,
          orElse:
              () => StudentAnswer(
                id: '',
                studentId: '',
                answers: [],
                testId: exam.id,
                submittedAt: DateTime.now(),
                timeTaken: 0,
              ),
        );
        return TestCard(
          title: exam.title,
          description: exam.description,
          subject: widget.subject.name,
          duration: exam.duration,
          isCompleted: true,
          score: studentAnswer.score,
          timeTaken: studentAnswer.timeTaken,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Xem lại bài thi: ${exam.title}'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }

  ListView _uncompletedTests() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _getUncompletedTests().length,
      itemBuilder: (context, index) {
        final exam = _getUncompletedTests()[index];
        return TestCard(
          title: exam.title,
          description: exam.description,
          subject: widget.subject.name,
          duration: exam.duration,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Bạn đã chọn bài thi: ${exam.title}'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }
}
