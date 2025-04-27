import 'package:flutter/material.dart';
import 'package:kid_arena/screens/student/exam_result_screen.dart';

class ExamScreen extends StatelessWidget {
  const ExamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bài thi'),
      ),
      body: Column(
        children: [
          Text('Điểm: ...'),
          Text('Thời gian: ...'),
          Expanded(
            child: ListView(
              children: [
                Text('Câu hỏi 1: ...'),
                ElevatedButton(onPressed: () {}, child: Text('Đáp án A')),
                ElevatedButton(onPressed: () {}, child: Text('Đáp án B')),
                ElevatedButton(onPressed: () {}, child: Text('Đáp án C')),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ExamResultScreen()),
              );
            },
            child: Text('Nộp bài'),
          ),
        ],
      ),
    );
  }
}
