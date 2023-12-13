import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swifty_chat/src/chat.dart';
import 'package:swifty_chat/src/extensions/date_extensions.dart';
import 'package:swifty_chat/src/extensions/theme_context.dart';
import 'package:swifty_chat/src/protocols/has_avatar.dart';
import 'package:swifty_chat/src/protocols/incoming_outgoing_message_widgets.dart';
import 'package:swifty_chat_data/swifty_chat_data.dart';
import 'package:uuid/uuid.dart';

final class ImageMessageWidget extends HookWidget
    with HasAvatar, IncomingOutgoingMessageWidgets {
  const ImageMessageWidget(this._chatMessage);

  final Message _chatMessage;

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

  Widget imageContainer(BuildContext context) {
    final theme = context.theme;
    final String type = message.messageKind.file!.type;
    final status = useState<String?>('');
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: theme.imageBorderRadius,
          child: Stack(
            children: [
              if (type == "Image") ...[
                Image(
                  width: _imageWidth(context),
                  image: NetworkImage(
                    message.messageKind.file!.url,
                  ),
                ),
              ] else if (type == "Video") ...[
                Container(
                  height: 150,
                  width: _imageWidth(context),
                  color: theme.secondaryColor,
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      size: 50,
                    ),
                  ),
                ),
              ] else if (type == "Audio") ...[
                Container(
                  height: 50,
                  width: _imageWidth(context),
                  color: theme.secondaryColor,
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      size: 20,
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  height: 50,
                  width: _imageWidth(context),
                  color: theme.secondaryColor,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.file_open,
                        size: 50,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      Text(
                        message.messageKind.file!.subText,
                      ),
                    ],
                  ),
                ),
              ],
              Positioned(
                right: 12,
                bottom: 6,
                child: Text(
                  message.date.relativeTimeFromNow(),
                  style: theme.imageWidgetTextTime,
                ),
              ),
            ],
          ),
        ),
        Text(
          message.messageKind.file!.subText,
          style: TextStyle(
            color: theme.secondaryColor,
          ),
        ),
        ElevatedButton(
          style: theme.quickReplyButtonStyle,
          onPressed: () async {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return ValueListenableBuilder(
                  valueListenable: status,
                  builder: (context, value, child) {
                    return AlertDialog(
                      content: SizedBox(
                        height: 50,
                        child: Center(
                          child: status.value == "progress"
                              ? const CircularProgressIndicator()
                              : status.value == "error"
                                  ? const Column(
                                      children: [
                                        Text("Error"),
                                        Icon(Icons.error),
                                      ],
                                    )
                                  : const Column(
                                      children: [
                                        Text("Download Complete"),
                                        Icon(Icons.done),
                                      ],
                                    ),
                        ),
                      ),
                    );
                  },
                );
              },
            );

            downloadFileDeneme(
              message.messageKind.file!.url,
              message.messageKind.file!.mime,
              status,
            ).then((value) => Navigator.of(context).pop());
          },
          child: const Icon(
            Icons.download,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => message.isMe
      ? outgoingMessageWidget(context)
      : incomingMessageWidget(context);

  double _imageWidth(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return ChatStateContainer.of(context)
        .messageCellSizeConfigurator
        .imageCellMaxWidthConfiguration(screenWidth);
  }

  @override
  Message get message => _chatMessage;
}

Future<void> downloadFileDeneme(
  String url,
  String mime,
  ValueNotifier<String?> status,
) async {
  final Dio dio = Dio();

  try {
    status.value = "progress";

    final dirIos = await getApplicationDocumentsDirectory();
    final dirAndroid =
        await getDownloadsDirectory().then((value) => value!.path);
    final dir = Platform.isIOS ? dirIos.path : dirAndroid;
    final String mimeType = mime.split('/').last;
    final fileId = const Uuid().v1();
    final String fileName = "$fileId.$mimeType";
    print("path $dir");
    await dio.download(
      url,
      "$dir/$fileName",
      onReceiveProgress: (rec, total) {
        print("rec: $rec , total: $total");
      },
    );
  } catch (e) {
    status.value = "error";
    await Future.delayed(
      const Duration(
        seconds: 2,
      ),
    );
  }

  status.value = "done";
  await Future.delayed(
    const Duration(
      seconds: 2,
    ),
  );
}
