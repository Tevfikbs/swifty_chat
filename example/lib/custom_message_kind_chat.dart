import 'package:flutter/material.dart';
import 'package:swifty_chat/swifty_chat.dart';
import 'package:swifty_chat_mocked_data/swifty_chat_mocked_data.dart';

class CustomMessageKindChat extends StatelessWidget {
  const CustomMessageKindChat({super.key});

  List<MockMessage> _mockMessages() => generateRandomTextMessages(count: 5)
    ..insert(
      0,
      MockMessage(
        date: DateTime.now(),
        user: MockChatUser.incomingUser,
        id: DateTime.now().toString(),
        isMe: false,
        messageKind:
            MessageKind.custom("⚙️ Hey! This is my custom message!!!! ⚙️"),
      ),
    );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Chat')),
      body: _chatWidget(context),
    );
  }

  Chat _chatWidget(BuildContext context) => Chat(
        customMessageWidget: (message) =>
            MyCustomMessageWidget(message: message),
        theme: const DarkChatTheme(),
        messages: _mockMessages(),
        chatMessageInputField: MessageInputField(
          key: const Key('message_input_field'),
          sendButtonTapped: (msg) {},
        ),
      );
}

class MyCustomMessageWidget extends StatelessWidget {
  final Message message;

  const MyCustomMessageWidget({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.lightGreenAccent,
      padding: const EdgeInsets.all(8),
      child: Text(
        message.messageKind.custom as String? ?? "Not a String",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

// You can check type with `if` in case you have different types of custom Message
}
