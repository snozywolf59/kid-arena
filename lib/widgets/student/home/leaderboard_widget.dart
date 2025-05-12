import 'package:flutter/material.dart';

class LeaderboardWidget extends StatelessWidget {
  const LeaderboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bảng vinh danh',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  spreadRadius: 1,

                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: List.generate(3, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: index < 2 ? 12 : 0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 40,
                        color:
                            index == 0
                                ? Colors.amber
                                : index == 1
                                ? Colors.grey
                                : Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Học sinh ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${(100 - index * 10)} điểm',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              index == 0
                                  ? Colors.amber[50]
                                  : index == 1
                                  ? Colors.grey[100]
                                  : Colors.orange[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${(100 - index * 10)}%',
                          style: TextStyle(
                            color:
                                index == 0
                                    ? Colors.amber[700]
                                    : index == 1
                                    ? Colors.grey[700]
                                    : Colors.orange[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
