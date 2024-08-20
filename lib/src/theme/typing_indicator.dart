import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _dotScales;
  late List<Animation<Color?>> _dotColors;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 800,
      ),
      vsync: this,
    )..repeat(
        period: const Duration(
          seconds: 2,
          milliseconds: 1500,
        ),
      );
    _dotScales = List.generate(3, (index) {
      final start = index * 0.1;
      final end = start + 0.4;
      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(
            begin: 1,
            end: 1.4,
          ),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween(
            begin: 1.4,
            end: 1,
          ),
          weight: 50,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            start,
            end,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
    _dotColors = List.generate(3, (index) {
      final start = index * 0.1;
      final end = start + 0.4;
      return TweenSequence<Color?>([
        TweenSequenceItem(
          tween: ColorTween(
            begin: Colors.grey[400],
            end: Colors.grey[500],
          ),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: ColorTween(
            begin: Colors.grey[500],
            end: Colors.grey[600],
          ),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: ColorTween(
            begin: Colors.grey[600],
            end: Colors.grey[700],
          ),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: ColorTween(
            begin: Colors.grey[700],
            end: Colors.grey[700],
          ),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: ColorTween(
            begin: Colors.grey[700],
            end: Colors.grey[600],
          ),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: ColorTween(
            begin: Colors.grey[600],
            end: Colors.grey[500],
          ),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: ColorTween(
            begin: Colors.grey[500],
            end: Colors.grey[400],
          ),
          weight: 50,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            start,
            end,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return ScaleTransition(
          scale: _dotScales[index],
          child: AnimatedBuilder(
            animation: _dotColors[index],
            builder: (context, child) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(
                  horizontal: 2,
                ),
                decoration: BoxDecoration(
                  color: _dotColors[index].value,
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
