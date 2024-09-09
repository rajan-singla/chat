import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat/models/chat_user.dart';
import 'package:chat/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accesing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accesing cloud firestore storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // to return current user
  static User get user => auth.currentUser!;

  // for checking if user exists or not
  static Future<bool> isUserExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // for storing self information
  static ChatUser me = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, I'm using We Chat!",
      image: user.photoURL.toString(),
      createdAt: '',
      isOnline: false,
      lastActive: '',
      pushToken: '');

  // to create the new user
  static Future<void> createUser() async {
    final chatUser = ChatUser(
      id: user.uid,
      name: '${user.displayName}',
      email: '${user.email}',
      image: '${user.photoURL}',
      isOnline: false,
      about: 'Hey! I\'m using WhatsApp.',
      pushToken: '',
      createdAt: '${DateTime.now().millisecondsSinceEpoch}',
      lastActive: '${DateTime.now().millisecondsSinceEpoch}',
    );
    return (await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson()));
  }

  // for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        // await getFirebaseMessagingToken();

        //for setting user status to active
        // APIs.updateActiveStatus(true);
        log('My Data: ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return APIs.firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  static Future<void> updateProfilePicture(File file) async {
    // getting image file extension
    final ext = file.path.split('.').last;
    log(ext);

    // Storage file ref with path
    final ref = await storage.ref().child('profile_pictures/${user.uid}.$ext');

    // uploading image
    final value =
        await ref.putFile(file, SettableMetadata(contentType: 'images/$ext'));
    log('${value.totalBytes / 1000} KB');

    // updating the image
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  /// ----------------------Chat Screen Related API's----------------------- ///
  ///
  /// chats (collection) > Conversation_id (doc) > messages (collection) > message (doc)

  // Useful for getting conveersation id
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .snapshots();
  }

  static Future<void> sendMessage(ChatUser chatUser, String msg) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final MessageModel messageModel = MessageModel(
      msg: msg,
      toId: chatUser.id,
      read: '',
      type: Type.text,
      sent: time,
      fromId: user.uid,
    );

    final ref = await firestore
        .collection('chats/${getConversationId(chatUser.id)}/messages/');
    await ref.doc(time).set(messageModel.toJson());
  }
}
