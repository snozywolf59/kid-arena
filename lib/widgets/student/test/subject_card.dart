import 'package:flutter/material.dart';
import 'package:kid_arena/constants/subject.dart';
import 'package:kid_arena/models/test/public_test.dart';

class SubjectCard extends StatefulWidget {
  final Subject subject;
  final VoidCallback onTap;

  const SubjectCard({super.key, required this.subject, required this.onTap});

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard> {
  List<PublicTest> tests = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.subject.color.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.subject.icon,
              size: 32,
              color: widget.subject.color,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 100,
            child: Text(
              widget.subject.name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
              softWrap: true,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
