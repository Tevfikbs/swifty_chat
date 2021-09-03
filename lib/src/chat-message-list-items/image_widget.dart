import 'package:dart_extensions/dart_extensions.dart' hide Message;
import 'package:flutter/material.dart';

import '../chat.dart';
import '../models/message.dart';
import '../models/user_avatar.dart';
import '../protocols/has_avatar.dart';
import '../protocols/incoming_outgoing_message_widgets.dart';

class ImageMessageWidget extends StatelessWidget with HasAvatar, IncomingOutgoingMessageWidgets {
  final Message _chatMessage;

  const ImageMessageWidget(this._chatMessage);

  @override
  Widget incomingMessageWidget(BuildContext context) => Row(
        crossAxisAlignment: avatarPosition.alignment,
        children: [
          ...avatarWithPadding(),
          imageContainer(context),
        ],
      );

  @override
  Widget outgoingMessageWidget(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: avatarPosition.alignment,
        children: [
          imageContainer(context),
          ...avatarWithPadding(),
        ],
      );

  Widget imageContainer(BuildContext context) => Image(
        image: NetworkImage(_chatMessage.messageKind.imageURL!),
        width: _imageWidth(context),
      );

  @override
  Widget build(BuildContext context) =>
      _chatMessage.isMe ? outgoingMessageWidget(context) : incomingMessageWidget(context);

  double _imageWidth(BuildContext context) {
    return ChatStateContainer.of(context)
        .messageCellSizeConfigurator
        .imageCellMaxWidthConfiguration(context.mq.size.width);
  }

  @override
  Message get message => _chatMessage;
}
