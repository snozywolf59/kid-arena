import 'package:flutter/material.dart';

/// A utility class that provides various page transition animations for navigation.
///
/// This class contains static methods that return [PageRouteBuilder] objects
/// with different transition animations:
/// - [slideTransition]: Creates a sliding animation from right to left
/// - [fadeTransition]: Creates a fade-in animation
/// - [scaleTransition]: Creates a scaling animation
///
/// Example usage:
/// ```dart
/// Navigator.push(
///   context,
///   PageTransitions.slideTransition(MyNextScreen()),
/// );
/// ```
///
/// These transitions provide a more engaging user experience compared to
/// the default Material page transitions, and can be used consistently
/// throughout the application for better visual coherence.


class PageTransitions {
  /// Creates a slide transition animation from right to left.
  ///
  /// This transition slides the new page in from the right edge of the screen
  /// while using an easeOutCubic curve for a smooth, natural motion.
  /// 
  /// Parameters:
  ///   - page: The widget to transition to
  ///
  /// Returns a PageRouteBuilder with the configured slide animation.
  static PageRouteBuilder slideTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  /// Creates a fade transition animation.
  ///
  /// This transition gradually increases the opacity of the new page,
  /// creating a smooth fade-in effect.
  /// 
  /// Parameters:
  ///   - page: The widget to transition to
  ///
  /// Returns a PageRouteBuilder with the configured fade animation.
  static PageRouteBuilder fadeTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Creates a scale transition animation.
  ///
  /// This transition animates the new page from a smaller size to its full size,
  /// creating a "zoom in" effect.
  /// 
  /// Parameters:
  ///   - page: The widget to transition to
  ///
  /// Returns a PageRouteBuilder with the configured scale animation.
  static PageRouteBuilder scaleTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(scale: animation, child: child);
      },
    );
  }
}
