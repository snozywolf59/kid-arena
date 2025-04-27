import 'package:flutter/material.dart';

class ExamResultScreen extends StatelessWidget {
  const ExamResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kết quả thi'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Chúc mừng bạn đã hoàn thành bài thi!'),
            Text('Điểm: 10/10'),
            Text('Thời gian: 20 phút'),
          ],
        ),
      ),
    );
  }
}
