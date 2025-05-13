import 'package:flutter/material.dart';
import 'package:kid_arena/models/class.dart';

class Ranking extends StatelessWidget {
  final Class classroom;
  const Ranking({super.key, required this.classroom});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng xếp hạng'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Placeholder(),
    );
  }
}
