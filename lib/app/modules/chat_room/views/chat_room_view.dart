import 'dart:async';

import 'package:chatapp/app/controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/chat_room_controller.dart';

class ChatRoomView extends GetView<ChatRoomController> {
  final authC = Get.find<AuthController>();
  final String chat_id = (Get.arguments as Map<String, dynamic>)['chat_id'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        leadingWidth: 88,
        leading: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(Icons.arrow_back)),
            CircleAvatar(
              backgroundColor: Colors.grey,
              child: StreamBuilder<DocumentSnapshot<Object?>>(
                stream: controller.streamFriendData(
                    (Get.arguments as Map<String, dynamic>)['friendEmail']),
                builder: (context, snapFriendUser) {
                  if (snapFriendUser.connectionState ==
                      ConnectionState.active) {
                    var dataFriend =
                        snapFriendUser.data!.data() as Map<String, dynamic>;
                    if (dataFriend['photoUrl'] == "noimage") {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset('assets/logo/noimage.png',
                              fit: BoxFit.cover),
                        ),
                      );
                    } else {
                      return InkWell(
                        onTap: () {
                          showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        title: authC.user.value.photoUrl == "no image"
                                  ? Image.asset(
                                      'assets/logo/noimage.png',
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      dataFriend['photoUrl'],
                                      fit: BoxFit.cover,
                                    ),));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            width: 50,
                            height: 50,
                            child: Image.network(
                              dataFriend['photoUrl'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    }
                  }
                  return Image.asset('assets/logo/noimage.png',
                      fit: BoxFit.cover);
                },
              ),
            )
          ],
        ),
        title: StreamBuilder<DocumentSnapshot<Object?>>(
            stream: controller.streamFriendData(
                (Get.arguments as Map<String, dynamic>)['friendEmail']),
            builder: (context, snapFriendUser) {
              if (snapFriendUser.connectionState == ConnectionState.active) {
                var dataFriend =
                    snapFriendUser.data!.data() as Map<String, dynamic>;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dataFriend['name'],
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      dataFriend['status'],
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Loading..',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Loading...',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              );
            }),
        centerTitle: false,
      ),
      body: WillPopScope(
        onWillPop: () {
          if (controller.isShowEmoji.isTrue) {
            controller.isShowEmoji.value = false;
          } else {
            Navigator.pop(context);
          }
          return Future.value(false);
        },
        child: Column(
          children: [
            Expanded(
                child: Container(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: controller.streamChats(chat_id),
                  builder: (context, snapshot) {
                    print(snapshot.data!.docs.length);
                    var allData = snapshot.data!.docs;
                    if (snapshot.connectionState == ConnectionState.active) {
                      Timer(
                          Duration.zero,
                          () => controller.scrollC.jumpTo(
                              controller.scrollC.position.maxScrollExtent));
                      return ListView.builder(
                        padding: EdgeInsets.all(15),
                          controller: controller.scrollC,
                          itemCount: allData.length,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Column(
                                children: [
                                  SizedBox(height: 10,),
                                  Text("${allData[index]['groupTime']}", style: TextStyle(fontWeight: FontWeight.bold),),
                                  Chats(
                                    msg: "${allData[index]['pesan']}",
                                    isSender: allData[index]['pengirim'] ==
                                            authC.user.value.email!
                                        ? true
                                        : false,
                                    time: "${allData[index]['time']}",
                                  ),
                                ],
                              );
                            } else {
                              if (allData[index]['groupTime'] ==
                                  allData[index - 1]['groupTime']) {
                                return Chats(
                                  msg: "${allData[index]['pesan']}",
                                  isSender: allData[index]['pengirim'] ==
                                          authC.user.value.email!
                                      ? true
                                      : false,
                                  time: "${allData[index]['time']}",
                                );
                              } else {
                                return Column(
                                  children: [
                                    Text("${allData[index]['groupTime']}", style: TextStyle(fontWeight: FontWeight.bold),),
                                    Chats(
                                      msg: "${allData[index]['pesan']}",
                                      isSender: allData[index]['pengirim'] ==
                                              authC.user.value.email!
                                          ? true
                                          : false,
                                      time: "${allData[index]['time']}",
                                    ),
                                  ],
                                );
                              }
                            }
                          });
                    }else{
                    return Center(
                      child: SizedBox(),
                    );}
                  }),
            )),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              margin: EdgeInsets.only(
                  bottom: controller.isShowEmoji.isTrue
                      ? 5
                      : context.mediaQueryPadding.bottom),
              child: Padding(
                padding: const EdgeInsets.only(bottom : 15.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        child: TextField(
                          onEditingComplete: () => controller.newChat(
                              authC.user.value.email!,
                              Get.arguments as Map<String, dynamic>,
                              controller.chatC.text),
                          focusNode: controller.focusNode,
                          controller: controller.chatC,
                          autocorrect: false,
                          decoration: InputDecoration(
                              prefixIcon: IconButton(
                                  onPressed: () {
                                    controller.focusNode.unfocus();
                                    controller.isShowEmoji.toggle();
                                  },
                                  icon: Icon(Icons.emoji_emotions_outlined)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100))),
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: () => controller.newChat(
                          authC.user.value.email!,
                          Get.arguments as Map<String, dynamic>,
                          controller.chatC.text),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.red[900],
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Obx(
              () => (controller.isShowEmoji.isTrue)
                  ? Container(
                      height: 325,
                      child: EmojiPicker(
                        onEmojiSelected: (category, emoji) {
                          controller.addEmojiToChat(emoji);
                        },
                        onBackspacePressed: () {
                          controller.deleteEmoji();
                          // Do something when the user taps the backspace button (optional)
                        }, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                        config: Config(
                          columns: 7,
                          // Issue: https://github.com/flutter/flutter/issues/28894
                          verticalSpacing: 0,
                          horizontalSpacing: 0,
                          gridPadding: EdgeInsets.zero,
                          initCategory: Category.RECENT,
                          bgColor: Color(0xFFF2F2F2),
                          indicatorColor: Color(0xffb71c1c),
                          iconColor: Colors.grey,
                          iconColorSelected: Color(0xffb71c1c),
                          // progressIndicatorColor: Color(0xffb71c1c),
                          backspaceColor: Color(0xffb71c1c),
                          skinToneDialogBgColor: Colors.white,
                          skinToneIndicatorColor: Colors.grey,
                          enableSkinTones: true,
                          // showRecentsTab: true,
                          recentsLimit: 28,
                          noRecents: const Text(
                            'No Recents',
                            style:
                                TextStyle(fontSize: 20, color: Colors.black26),
                            textAlign: TextAlign.center,
                          ),
                          tabIndicatorAnimDuration: kTabScrollDuration,
                          categoryIcons: const CategoryIcons(),
                          buttonMode: ButtonMode.MATERIAL,
                        ),
                      ),
                    )
                  : SizedBox(),
            )
          ],
        ),
      ),
    );
  }
}

class Chats extends StatelessWidget {
  const Chats(
      {Key? key, required this.isSender, required this.msg, required this.time})
      : super(key: key);

  final bool isSender;
  final String msg;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: isSender
                    ? BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      )
                    : BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                color: isSender ? Colors.red[900] : Colors.grey),
            child: Text(
              "$msg",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            DateFormat.jm().format(DateTime.parse(time)),
            style: TextStyle(fontSize: 10),
          ),
        ],
      ),
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
    );
  }
}
