import 'dart:developer';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Chuỗi ngày học tập tuần này',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            _DaysOfWeek(
              streakStream: getIt<StudyStreakService>().getStudyStreak(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DaysOfWeek extends StatefulWidget {
  const _DaysOfWeek({required this.streakStream});

  final Stream<List<int>> streakStream;

  @override
  State<_DaysOfWeek> createState() => _DaysOfWeekState();
}

class _DaysOfWeekState extends State<_DaysOfWeek> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<int>>(
      stream: widget.streakStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Có lỗi xảy ra',
            style: TextStyle(color: Colors.white),
          );
        }

        final studiedDays = snapshot.data ?? [];
        log('studiedDays: $studiedDays');
        return Row(
          children: List.generate(7, (index) {
            final isToday = index == DateTime.now().weekday % 7;
            final isStudied = studiedDays.contains(index);

            return Expanded(
              child: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
                child:
                    isStudied
                        ? Icon(Icons.check, color: Colors.red)
                        : Text(
                          textAlign: TextAlign.center,
                          daysInWeek[index],
                          style: TextStyle(
                            color:
                                isToday
                                    ? Colors.deepOrange[600]
                                    : isStudied
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.7),
                          ),
                        ),
              ),
            );
          }),
        );
      },
    );
  }
}
