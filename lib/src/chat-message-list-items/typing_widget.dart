import 'package:flutter/material.dart';
import 'package:swifty_chat/src/extensions/theme_context.dart';
import 'package:swifty_chat/src/theme/typing_indicator.dart';

class TypingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final messageBorderRadius = theme.messageBorderRadius;

    final borderRadius = BorderRadius.only(
      bottomRight: Radius.circular(messageBorderRadius),
      topLeft: Radius.circular(messageBorderRadius),
      topRight: Radius.circular(messageBorderRadius),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: theme.secondaryColor,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Padding(
          padding: EdgeInsets.all(
            theme.textMessagePadding,
          ),
          child: TypingIndicator(),
        ),
      ),
    );
  }
}
