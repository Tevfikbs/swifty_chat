import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../models/message.dart';
import '../models/user_avatar.dart';
import '../protocols/has_avatar.dart';

class TextMessageWidget extends StatelessWidget with HasAvatar {
  final Message _chatMessage;

  const TextMessageWidget(this._chatMessage);

  List<Widget> avatarAndSpacer({required bool isMe, double space = 8}) => [
        SizedBox(width: space),
        if (avatarUri != null)
          CircleAvatar(
            backgroundImage: NetworkImage(avatarUri!.toString()),
          ),
        SizedBox(width: space),
      ].toList();

  Widget incomingMessage(BuildContext context) => Row(
        crossAxisAlignment: avatarPosition.alignment,
        children: [
          ...avatarAndSpacer(isMe: false),
          textContainer(context),
        ],
      );

  Widget outgoingMessage(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: avatarPosition.alignment,
        children: [
          textContainer(context),
          ...avatarAndSpacer(isMe: true),
        ],
      );

  Widget textContainer(BuildContext context) {
    final cardTheme = Theme.of(context).cardTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: Text(
        _chatMessage.messageKind.text!,
        softWrap: true,
        style: Theme.of(context).textTheme.bodyText1,
      ).padding(all: 8).card(color: cardTheme.color, margin: cardTheme.margin),
    ).flexible();
  }

  @override
  Widget build(BuildContext context) =>
      _chatMessage.isMe ? outgoingMessage(context) : incomingMessage(context);

  @override
  Message get message => _chatMessage;
}
