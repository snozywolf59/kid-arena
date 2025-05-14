import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_arena/blocs/theme/theme_bloc.dart';
import 'package:kid_arena/blocs/theme/theme_event.dart';
import 'package:kid_arena/blocs/theme/theme_state.dart';
import 'package:kid_arena/screens/student/class/my_notification.dart';
import 'package:kid_arena/utils/index.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text(
              'Bảng xếp hạng',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            floating: true,
            pinned: true,
            automaticallyImplyLeading: false,

            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransitions.slideTransition(const MyNotification()),
                  );
                },
                icon: Icon(Icons.notifications),
              ),
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, state) {
                  return IconButton(
                    icon: Icon(
                      state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    ),
                    onPressed: () {
                      context.read<ThemeBloc>().add(ThemeToggled());
                    },
                  );
                },
              ),
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primary,
                child: const Icon(Icons.person, size: 16),
              ),
              const SizedBox(width: 16),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _buildTopThree(),
                  const SizedBox(height: 24),
                  _buildLeaderboardList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopThree() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTopThreeItem(
          '2nd',
          'Sarah',
          95,
          Colors.grey[400]!,
          const Offset(0, 0),
        ),
        _buildTopThreeItem(
          '1st',
          'John',
          98,
          Colors.amber,
          const Offset(0, -20),
        ),
        _buildTopThreeItem(
          '3rd',
          'Mike',
          92,
          Colors.brown[300]!,
          const Offset(0, 0),
        ),
      ],
    );
  }

  Widget _buildTopThreeItem(
    String rank,
    String name,
    int score,
    Color color,
    Offset offset,
  ) {
    return Transform.translate(
      offset: offset,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
            ),
            child: Center(
              child: Text(
                rank,
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
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '$score points',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return Column(
      children: List.generate(
        10,
        (index) => _buildLeaderboardItem(
          index + 4,
          'Student ${index + 4}',
          90 - index,
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(int rank, String name, int score) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(26),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$score pts',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
