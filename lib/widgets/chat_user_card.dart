import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/main.dart';
import 'package:chat/models/chat_user.dart';
import 'package:chat/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({required this.user, super.key});
  final ChatUser user;

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      // color: Colors.blue.shade100,
      elevation: 0.5,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(user: user),)),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * 0.3),
            child: CachedNetworkImage(
              fit: BoxFit.fill,
              height: mq.height * 0.055,
              width: mq.height * 0.055,
              imageUrl: user.image,
              errorWidget: (_, __, ___) => CircleAvatar(child: Icon((CupertinoIcons.person)))),
          ),
          title: Text(user.name),
          subtitle: Text(user.about, maxLines: 1,),
          trailing: Text('12:00 PM'),
        ),
      ),
    );
  }
}