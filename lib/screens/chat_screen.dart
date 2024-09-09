import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/api/apis.dart';
import 'package:chat/main.dart';
import 'package:chat/models/chat_user.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/widgets/message_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({required this.user, super.key});
  final ChatUser user;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageModel> _messages = [];
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: _appBar(),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: APIs.getAllMessages(user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        // print(jsonEncode(data?[0].data()));
                        _messages = data
                                ?.map((message) =>
                                    MessageModel.fromJson(message.data()))
                                .toList() ??
                            <MessageModel>[];

                        // To reverse the list
                        _messages = _messages.reversed.toList();
                    }
                    if (_messages.isNotEmpty) {
                      return ListView.builder(
                        itemCount: _messages.length,
                        padding: EdgeInsets.only(top: mq.height * .01),
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return MessageCard(message: _messages[index]);
                        },
                      );
                    } else {
                      return Center(
                        child: Text(
                          'Say Hii! 👋',
                          style: TextStyle(
                              fontSize: TextTheme().headlineSmall?.fontSize),
                        ),
                      );
                    }
                  }),
            ),
            _chatInput(),
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          //back button
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.black54)),
          ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * 0.3),
            child: CachedNetworkImage(
                fit: BoxFit.fill,
                height: mq.height * 0.05,
                width: mq.height * 0.05,
                imageUrl: widget.user.image,
                errorWidget: (_, __, ___) =>
                    CircleAvatar(child: Icon((CupertinoIcons.person)))),
          ),
          //for adding some space
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //user name
              Text(
                widget.user.name,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),

              //for adding some space
              const SizedBox(height: 2),

              Text(
                'Last seen not available',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // bottom chat input field
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        children: [
          //input field & buttons
          Expanded(
            child: Card(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Row(
                children: [
                  //emoji button
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        // setState(() => _showEmoji = !_showEmoji);
                      },
                      icon: const Icon(Icons.emoji_emotions,
                          color: Colors.blueAccent, size: 25)),

                  Expanded(
                      child: TextField(
                    // controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: () {
                      // if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
                    },
                    decoration: const InputDecoration(
                        hintText: 'Type Something...',
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none),
                  )),

                  //pick image from gallery button
                  IconButton(
                      onPressed: () async {
                        // final ImagePicker picker = ImagePicker();

                        // // Picking multiple images
                        // final List<XFile> images =
                        //     await picker.pickMultiImage(imageQuality: 70);

                        // // uploading & sending image one by one
                        // for (var i in images) {
                        //   log('Image Path: ${i.path}');
                        //   setState(() => _isUploading = true);
                        //   await APIs.sendChatImage(widget.user, File(i.path));
                        //   setState(() => _isUploading = false);
                        // }
                      },
                      icon: const Icon(Icons.image,
                          color: Colors.blueAccent, size: 26)),

                  //take image from camera button
                  IconButton(
                      onPressed: () async {
                        // final ImagePicker picker = ImagePicker();

                        // // Pick an image
                        // final XFile? image = await picker.pickImage(
                        //     source: ImageSource.camera, imageQuality: 70);
                        // if (image != null) {
                        //   log('Image Path: ${image.path}');
                        //   setState(() => _isUploading = true);

                        //   await APIs.sendChatImage(
                        //       widget.user, File(image.path));
                        //   setState(() => _isUploading = false);
                        // }
                      },
                      icon: const Icon(Icons.camera_alt_rounded,
                          color: Colors.blueAccent, size: 26)),

                  //adding some space
                  SizedBox(width: mq.width * .02),
                ],
              ),
            ),
          ),

          //send message button
          MaterialButton(
            onPressed: () {
              // if (_textController.text.isNotEmpty) {
              //   if (_list.isEmpty) {
              //     //on first message (add user to my_user collection of chat user)
              //     APIs.sendFirstMessage(
              //         widget.user, _textController.text, Type.text);
              //   } else {
              //     //simply send message
              //     APIs.sendMessage(
              //         widget.user, _textController.text, Type.text);
              //   }
              //   _textController.text = '';
              // }
            },
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            color: Colors.green,
            child: const Icon(Icons.send, color: Colors.white, size: 28),
          )
        ],
      ),
    );
  }
}
