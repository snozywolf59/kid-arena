import 'package:flutter/material.dart';
import 'exam_screen.dart';

class ExamSelectionScreen extends StatelessWidget {
  const ExamSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn bài thi'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {},
            child: Text('Lịch sử dự thi'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5, // giả lập 5 bài thi
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Bài thi ${index + 1}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ExamScreen()),
                      );
                    },
                    child: Text('Làm bài'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
