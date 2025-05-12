import 'package:flutter/material.dart';
import 'package:kid_arena/services/study_streak_service.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/constants/index.dart';


class StudyStreakWidget extends StatelessWidget {
  const StudyStreakWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepOrange[400]!, Colors.deepOrange[600]!],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_fire_department,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chuỗi ngày học tập',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<List<int>>(
                    stream: getIt<StudyStreakService>().getStudyStreak(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text(
                          'Có lỗi xảy ra',
                          style: TextStyle(color: Colors.white),
                        );
                      }

                      final studiedDays = snapshot.data ?? [];

                      return Row(
                        children: List.generate(7, (index) {
                          final isToday = index == DateTime.now().weekday % 7;
                          final isStudied = studiedDays.contains(index);

                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  isToday
                                      ? Colors.white
                                      : isStudied
                                      ? Colors.white.withAlpha(80)
                                      : Colors.white.withAlpha(50),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow:
                                  isStudied
                                      ? [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.3),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                      : null,
                            ),
                            child: Text(
                              daysInWeek[index],
                              style: TextStyle(
                                color:
                                    isToday
                                        ? Colors.deepOrange[600]
                                        : isStudied
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
