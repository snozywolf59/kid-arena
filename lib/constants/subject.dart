import 'package:flutter/material.dart';

enum Subject {
  mathematics(
    name: 'Toán học',
    icon: Icons.calculate,
    color: Color(0xFF61A3FE),
  ),
  literature(name: 'Ngữ văn', icon: Icons.menu_book, color: Color(0xFFFF8C42)),
  english(name: 'Tiếng Anh', icon: Icons.translate, color: Color(0xFF6A5AE0)),
  naturalScience(
    name: 'Khoa học tự nhiên',
    icon: Icons.eco,
    color: Color(0xFF4CD97B),
  ),
  socialScience(
    name: 'Khoa học xã hội',
    icon: Icons.people,
    color: Color(0xFFE15FED),
  );

  final String name;
  final IconData icon;
  final Color color;

  const Subject({required this.name, required this.icon, required this.color});

  static IconData getIcon(String subjectName) {
    switch (subjectName) {
      case 'Toán học':
        return Icons.calculate;
      case 'Ngữ văn':
        return Icons.menu_book;
      case 'Tiếng Anh':
        return Icons.translate;
      case 'Khoa học tự nhiên':
        return Icons.eco;
      case 'Khoa học xã hội':
        return Icons.people;
      default:
        return Icons.subject;
    }
  }
}
