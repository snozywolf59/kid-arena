import 'package:flutter/material.dart';
import 'package:kid_arena/constants/index.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildOverallProgress(),
              const SizedBox(height: 24),
              _buildSubjectProgress(),
              const SizedBox(height: 24),
              _buildRecentActivity(),
            ]),
          ),
        ),
        SliverFillRemaining(),
      ],
    );
  }

  Widget _buildOverallProgress() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông số chung',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildProgressCircle(
                    'Đã hoàn thành',
                    '24',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildProgressCircle(
                    'Điểm trung bình',
                    '85%',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildProgressCircle('Xếp hạng', '12', Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCircle(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubjectProgress() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tiến độ môn học',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _SubjectProgress(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hoạt động gần đây',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              'Bài thi Toán - Chương 5',
              'Đã hoàn thành',
              '2 ngày trước',
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              'Bài thi Vật lý - Chương 3',
              'Đang tiếp tục',
              '1 giờ trước',
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              'Bài tập Tiếng Anh',
              'Đã hoàn thành',
              '3 ngày trước',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildActivityItem(
  String title,
  String status,
  String time,
  Color color,
) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.assignment_outlined, color: color),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    ],
  );
}

Widget _buildSubjectProgressItem(String subject, int score, Color color) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            subject,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            '$score%',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      const SizedBox(height: 8),
      LinearProgressIndicator(
        value: score / 100,
        backgroundColor: color.withAlpha(26),
        valueColor: AlwaysStoppedAnimation<Color>(color),
        borderRadius: BorderRadius.circular(10),
        minHeight: 8,
      ),
    ],
  );
}

class _SubjectProgress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          Subject.values
              .map(
                (subject) =>
                    _buildSubjectProgressItem(subject.name, 85, subject.color),
              )
              .toList(),
    );
  }
}
