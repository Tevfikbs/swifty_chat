import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swifty_chat/src/extensions/theme_context.dart';
import 'package:swifty_chat/src/theme/typing_indicator.dart';
import 'package:swifty_chat_data/swifty_chat_data.dart';

class TypingWidget extends StatelessWidget {
  const TypingWidget(this._chatMessage);
  final Message _chatMessage;

  UserAvatar? get userAvatar => message.user.avatar;

  AvatarPosition get avatarPosition =>
      userAvatar?.position ?? AvatarPosition.center;

  ImageProvider? get avatarImageProvider => userAvatar?.imageProvider;

  double get _radius => (userAvatar?.size ?? 36) / 2;

  Widget incomingMessageWidget(BuildContext context) => Row(
        crossAxisAlignment: avatarPosition.alignment,
        children: [
          const SizedBox(width: 8),
          if (avatarImageProvider != null)
            CircleAvatar(
              radius: _radius,
              backgroundImage: avatarImageProvider,
            ),
          const SizedBox(width: 8),
          _DecoratedText(message: message).flexible(),
          const SizedBox(width: 24),
        ],
      );

  @override
  Widget build(BuildContext context) => incomingMessageWidget(context);

  Message get message => _chatMessage;
}

final class _DecoratedText extends StatelessWidget {
  const _DecoratedText({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final messageBorderRadius = theme.messageBorderRadius;

    final borderRadius = BorderRadius.only(
      bottomLeft: Radius.circular(message.isMe ? messageBorderRadius : 0),
      bottomRight: Radius.circular(message.isMe ? 0 : messageBorderRadius),
      topLeft: Radius.circular(messageBorderRadius),
      topRight: Radius.circular(messageBorderRadius),
    );

    return Row(
      children: [
        DecoratedBox(
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
              child: Center(child: TypingIndicator()),
            ),
          ),
        ),
      ],
    );
  }
}
