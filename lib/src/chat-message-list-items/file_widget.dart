import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swifty_chat/src/chat-message-list-items/audio_widget.dart';
import 'package:swifty_chat/src/chat.dart';
import 'package:swifty_chat/src/extensions/date_extensions.dart';
import 'package:swifty_chat/src/extensions/theme_context.dart';
import 'package:swifty_chat/src/protocols/has_avatar.dart';
import 'package:swifty_chat/src/protocols/incoming_outgoing_message_widgets.dart';
import 'package:swifty_chat_data/swifty_chat_data.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

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
    final videoPlayerController = useState<VideoPlayerController?>(null);
    final chewieController = useState<ChewieController?>(null);

    useEffect(() {
      if (type == "Video") {
        videoPlayerController.value = VideoPlayerController.networkUrl(
          Uri.parse(
            message.messageKind.file!.url,
          ),
        );
        videoPlayerController.value!.initialize().then((_) {
          chewieController.value = ChewieController(
            videoPlayerController: videoPlayerController.value!,
            aspectRatio: videoPlayerController.value!.value.aspectRatio,
            deviceOrientationsOnEnterFullScreen: [
              DeviceOrientation.portraitUp,
            ],
            deviceOrientationsAfterFullScreen: [
              DeviceOrientation.portraitUp,
            ],
          );
        });
      }
      return () {
        videoPlayerController.value?.dispose();
        chewieController.value?.dispose();
      };
    }, [message.messageKind.file!.url]);

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
                if (chewieController.value != null)
                  Container(
                    height: 150,
                    width: _imageWidth(context),
                    color: Colors.black,
                    child: Chewie(
                      controller: chewieController.value!,
                    ),
                  )
                else
                  Container(
                    height: 150,
                    width: _imageWidth(context),
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ] else if (type == "Audio") ...[
                Container(
                  decoration: BoxDecoration(
                    color: theme.secondaryColor,
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                  height: 60,
                  width: _imageWidth(context),
                  child: AudioPlayerWidget(
                    audioUrl: message.messageKind.file!.url,
                  ),
                ),
              ] else ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.textMessagePadding,
                  ),
                  decoration: BoxDecoration(
                    color: theme.secondaryColor,
                    borderRadius: BorderRadius.circular(
                      theme.messageBorderRadius,
                    ),
                  ),
                  height: 60,
                  width: _imageWidth(context),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: Image.network(
                          "https://cdn-icons-png.flaticon.com/512/337/337946.png",
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        message.messageKind.file!.subText,
                        style: theme.incomingMessageBodyTextStyle,
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
        // Text(
        //   message.messageKind.file!.subText,
        //   style: TextStyle(
        //     color: theme.htmlTextColor,
        //   ),
        // ),
        OutlinedButton(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("Error"),
                                        Icon(Icons.error),
                                      ],
                                    )
                                  : const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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

            await downloadFileDeneme(
              message.messageKind.file!.url,
              message.messageKind.file!.mime,
              status,
            );
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.download,
            color: theme.secondaryColor,
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
