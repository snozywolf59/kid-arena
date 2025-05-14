import 'package:flutter/material.dart';

class LeaderboardWidget extends StatelessWidget {
  const LeaderboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),

      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bậc thang top 3
            SizedBox(
              height: 220,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Hạng 2 (bên trái)
                  Positioned(
                    left: 30,
                    bottom: 0,
                    child: _buildPodiumItem(
                      context,
                      name: 'Lê Toàn',
                      rank: 2,
                      height: 100,
                      color: Colors.grey,
                    ),
                  ),
                  // Hạng 1 (giữa, cao nhất)
                  Positioned(
                    bottom: 0,
                    child: _buildPodiumItem(
                      context,
                      name: 'Nguyễn Hà',
                      rank: 1,
                      height: 140,
                      color: Colors.amber,
                    ),
                  ),
                  // Hạng 3 (bên phải)
                  Positioned(
                    right: 30,
                    bottom: 0,
                    child: _buildPodiumItem(
                      context,
                      name: 'Tô Bằng',
                      rank: 3,
                      height: 80,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumItem(
    BuildContext context, {
    required String name,
    required int rank,
    required double height,
    required Color color,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            '$rank',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Center(
            child: Text(
              '${100 - (rank - 1) * 10} điểm',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Text(
          name,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
