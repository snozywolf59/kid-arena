// Dart packages
// Flutter packages
import 'package:flutter/material.dart';
import 'package:kid_arena/constants/index.dart';

// Pub packages
// Project packages

class PrivateTestCard extends StatelessWidget {
  final String title;
  final String subject;
  final String className;
  final String dueDate;
  final Color color;
  final VoidCallback onTap;
  final bool isCompleted;
  final double? score;
  final int? timeTaken;

  const PrivateTestCard({
    super.key,
    required this.title,
    required this.subject,
    required this.className,
    required this.dueDate,
    required this.color,
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
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(75), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.check_circle_outline
                          : Subject.getIcon(subject),
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$subject • Lớp: $className',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isCompleted && score != null) ...[
                const SizedBox(height: 16),
                _buildScoreIndicator(),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: color),
                  const SizedBox(width: 4),
                  Text(
                    dueDate,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  if (isCompleted && timeTaken != null) ...[
                    const SizedBox(width: 16),
                    _buildTimeTakenChip(),
                  ],
                  const Spacer(),
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(isCompleted ? 'Xem lại' : 'Bắt đầu'),
                  ),
                ],
              ),
            ],
          ),
        ),
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
          Flexible(
            child: Text(
              'Điểm số: ${(score! * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: scoreColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
      constraints: const BoxConstraints(maxWidth: 140),
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
          Flexible(
            child: Text(
              'Thời gian: ${minutes}m ${seconds}s',
              style: TextStyle(
                color: Colors.purple[700],
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
