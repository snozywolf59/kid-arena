import 'package:flutter/material.dart';

class OptionWidget extends StatelessWidget {
  final String optionText;
  final String optionChar; // A, B, C, D
  final bool isSelected;
  final VoidCallback onTap;
  final bool?
  isCorrect; // null: chưa submit, true: đúng, false: sai (dùng khi review)
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
    final colorScheme = theme.colorScheme;

    Color borderColor = colorScheme.outlineVariant;
    Color backgroundColor = colorScheme.surface;
    Color textColor = colorScheme.onSurface;
    Color charColor = colorScheme.primary;
    Color charBackgroundColor = Colors.transparent;
    IconData? trailingIcon;
    Color? trailingIconColor;

    bool isRevealed = revealed ?? false;

    if (isRevealed) {
      if (isSelected) {
        if (isCorrect == true) {
          // Chọn đúng
          borderColor = colorScheme.primary;
          backgroundColor = colorScheme.primaryContainer;
          textColor = colorScheme.onPrimaryContainer;
          charColor = colorScheme.onPrimary;
          charBackgroundColor = colorScheme.primary;
          trailingIcon = Icons.check_circle_rounded;
          trailingIconColor = colorScheme.primary;
        } else {
          // Chọn sai
          borderColor = colorScheme.error;
          backgroundColor = colorScheme.errorContainer;
          textColor = colorScheme.onErrorContainer;
          charColor = colorScheme.onError;
          charBackgroundColor = colorScheme.error;
          trailingIcon = Icons.cancel_rounded;
          trailingIconColor = colorScheme.error;
        }
      } else if (isCorrect == true) {
        // Không chọn nhưng đây là đáp án đúng
        borderColor = colorScheme.primary;
        backgroundColor = colorScheme.primaryContainer.withOpacity(0.5);
        textColor = colorScheme.onPrimaryContainer;
        charColor = colorScheme.primary;
      }
    } else if (isSelected) {
      // Đang chọn, chưa submit
      borderColor = colorScheme.primary;
      backgroundColor = colorScheme.primaryContainer;
      textColor = colorScheme.onPrimaryContainer;
      charColor = colorScheme.onPrimary;
      charBackgroundColor = colorScheme.primary;
      trailingIcon = Icons.radio_button_checked_rounded;
      trailingIconColor = colorScheme.primary;
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
          boxShadow:
              (isSelected && !isRevealed)
                  ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.15),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [],
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
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: charColor,
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
            ],
          ],
        ),
      ),
    );
  }
}
