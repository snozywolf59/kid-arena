import 'package:flutter/material.dart';

class OptionWidget extends StatelessWidget {
  final String optionText;
  final String optionChar; // A, B, C, D
  final bool isSelected;
  final VoidCallback onTap;
  final bool? isCorrect; // null: chưa submit, true: đúng, false: sai (dùng khi review)
  final bool? revealed; // true: đã submit và hiện đáp án

  const OptionWidget({
    super.key,
    required this.optionText,
    required this.optionChar,
    required this.isSelected,
    required this.onTap,
    this.isCorrect,
    this.revealed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color borderColor = Colors.grey.shade300;
    Color backgroundColor = theme.colorScheme.surface;
    Color textColor = theme.hintColor;
    Color charColor = theme.primaryColor;
    Color charBackgroundColor = Colors.transparent;
    IconData? trailingIcon;
    Color? trailingIconColor;

    bool isRevealed = revealed ?? false;

    if (isRevealed) {
      if (isSelected) {
        if (isCorrect == true) { // Chọn đúng
          borderColor = Colors.green.shade600;
          backgroundColor = Colors.green.withOpacity(0.1);
          textColor = Colors.green.shade700;
          charColor = Colors.white;
          charBackgroundColor = Colors.green.shade600;
          trailingIcon = Icons.check_circle_rounded;
          trailingIconColor = Colors.green.shade600;
        } else { // Chọn sai
          borderColor = Colors.red.shade600;
          backgroundColor = Colors.red.withOpacity(0.1);
          textColor = Colors.red.shade700;
          charColor = Colors.white;
          charBackgroundColor = Colors.red.shade600;
          trailingIcon = Icons.cancel_rounded;
          trailingIconColor = Colors.red.shade600;
        }
      } else if (isCorrect == true) { // Không chọn nhưng đây là đáp án đúng
         borderColor = Colors.green.shade400;
         // backgroundColor = Colors.green.withOpacity(0.05);
         // textColor = Colors.green.shade600;
         // charColor = Colors.green.shade600;
      }
    } else if (isSelected) { // Đang chọn, chưa submit
      borderColor = theme.primaryColor;
      backgroundColor = theme.primaryColor.withOpacity(0.1);
      textColor = theme.primaryColor;
      charColor = Colors.white;
      charBackgroundColor = theme.primaryColor;
      trailingIcon = Icons.radio_button_checked_rounded;
      trailingIconColor = theme.primaryColor;
    }


    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 7.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: borderColor,
            width: isSelected || (isRevealed && isCorrect == true) ? 2.0 : 1.5,
          ),
          boxShadow: (isSelected && !isRevealed) ? [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0,2),
            )
          ] : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1.5),
                color: charBackgroundColor,
              ),
              child: Center(
                child: Text(
                  optionChar,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: charColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                optionText,
                style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: textColor,
                    ),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(trailingIcon, color: trailingIconColor, size: 22),
            ]
          ],
        ),
      ),
    );
  }
}