import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatRoomController extends GetxController {
  var isShowEmoji = false.obs;
  int total_unread = 0;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  late FocusNode focusNode;
  late TextEditingController chatC;
  late ScrollController scrollC;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamChats(String chat_id) {
    CollectionReference chats = firestore.collection('chats');

    return chats.doc(chat_id).collection('chat').orderBy('time').snapshots();
  }

  Stream<DocumentSnapshot<Object?>>streamFriendData(String friendEmail){
    CollectionReference users = firestore.collection('users');

    return users.doc(friendEmail).snapshots();
  }

  void deleteEmoji() {
    chatC.text = chatC.text.substring(0, chatC.text.length - 2);
  }

  void newChat(
      String email, Map<String, dynamic> arguments, String chat) async {
        if(chat != ""){
    CollectionReference chats = firestore.collection("chats");
    CollectionReference users = firestore.collection("users");

    String date = DateTime.now().toIso8601String();

        await chats.doc(arguments["chat_id"]).collection('chat').add({
      "pengirim": email,
      "penerima": arguments["friendEmail"],
      "pesan": chat,
      "time": date,
      "isRead": false,
      "groupTime" : DateFormat.yMMMMd('en_US').format(DateTime.parse(date)),
    });
    // Auto Scroll
    Timer(
        Duration.zero, () => scrollC.jumpTo(scrollC.position.maxScrollExtent));
    //Menghapus di TextController
    chatC.clear();


    await users
        .doc(email)
        .collection('chats')
        .doc(arguments["chat_id"])
        .update({
      "lastTime": date,
    });

    final checkChatsFriend = await users
        .doc(arguments["friendEmail"])
        .collection('chats')
        .doc(arguments["chat_id"])
        .get();

    if (checkChatsFriend.exists) {
      //Ini ada data chat di temen kita
      // Pertama Cek total unread
      final checkTotalUnread = await chats
          .doc(arguments["chat_id"])
          .collection('chat')
          .where('isRead', isEqualTo: false)
          .where('pengirim', isEqualTo: email)
          .get();

      // total unread for friend
      total_unread = checkTotalUnread.docs.length;

      await users
          .doc(arguments["friendEmail"])
          .collection('chats')
          .doc(arguments["chat_id"])
          .update({"lastTime": date, "total_unread": total_unread});
    } else {
      // ini tidak ada di temen kita
      // Buat Baru untuk teman di database
      await users
          .doc(arguments["friendEmail"])
          .collection('chats')
          .doc(arguments["chat_id"])
          .set({
        "connection": email,
        "lastTime": date,
        "total_unread": total_unread + 1
      });
    }}
  }

  void addEmojiToChat(Emoji emoji) {
    chatC.text = chatC.text + emoji.emoji;
  }

  @override
  void onInit() {
    chatC = TextEditingController();
    scrollC = ScrollController();
    focusNode = FocusNode();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        isShowEmoji.value = false;
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    scrollC.dispose();
    chatC.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
