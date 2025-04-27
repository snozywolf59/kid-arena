import 'package:flutter/material.dart';

class ExamHistoryScreen extends StatelessWidget {
  const ExamHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử dự thi'),
      ),
      body: Column(
        children: [
          Expanded(
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('STT')),
                DataColumn(label: Text('Bài thi')),
                DataColumn(label: Text('Điểm')),
                DataColumn(label: Text('Thời gian')),
                DataColumn(label: Text('Số lần')),
              ],
              rows: List<DataRow>.generate(
                5,
                (index) => DataRow(
                  cells: <DataCell>[
                    DataCell(Text('${index + 1}')),
                    DataCell(Text('Bài thi ${index + 1}')),
                    DataCell(Text('8')),
                    DataCell(Text('20p')),
                    DataCell(Text('1')),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            color: Colors.grey[200],
            child: Center(child: Text('Biểu đồ kết quả')),
          ),
        ],
      ),
    );
  }
}
