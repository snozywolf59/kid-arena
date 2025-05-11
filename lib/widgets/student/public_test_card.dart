import 'package:flutter/material.dart';

class PublicTestCard extends StatelessWidget {
  final String title;
  final String description;
  final String subject;
  final int duration;
  final VoidCallback onTap;
  final bool isCompleted;
  final double? score;
  final int? timeTaken;

  const PublicTestCard({
    super.key,
    required this.title,
    required this.description,
    required this.subject,
    required this.duration,
    required this.onTap,
    this.isCompleted = false,
    this.score,
    this.timeTaken,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildSubjectChip(),
                  const Spacer(),
                  _buildDurationChip(),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              if (isCompleted && score != null) ...[
                const SizedBox(height: 16),
                _buildScoreIndicator(),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  if (isCompleted && timeTaken != null)
                    Expanded(child: _buildTimeTakenChip()),
                  const Spacer(),
                  _buildStartButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        subject,
        style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDurationChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, size: 16, color: Colors.green[700]),
          const SizedBox(width: 4),
          Text(
            duration % 60 == 0
                ? '${(duration / 60).toInt()} phút'
                : '${(duration / 60).toInt()} phút ${duration % 60} giây',
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreIndicator() {
    final scoreColor =
        score! >= 0.8
            ? Colors.green
            : score! >= 0.6
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: scoreColor.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scoreColor.withAlpha(75)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_outlined, color: scoreColor, size: 20),
          const SizedBox(width: 8),
          Text(
            'Điểm số: ${(score!).toStringAsFixed(0)}%',
            style: TextStyle(
              color: scoreColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTakenChip() {
    final minutes = (timeTaken! / 60).floor();
    final seconds = (timeTaken! % 60).floor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.purple.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 16, color: Colors.purple[700]),
          const SizedBox(width: 4),
          Text(
            'Thời gian: ${minutes}m ${seconds}s',
            style: TextStyle(
              color: Colors.purple[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isCompleted ? Colors.green : Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(isCompleted ? 'Xem lại' : 'Bắt đầu'),
    );
  }
}
