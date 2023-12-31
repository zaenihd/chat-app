import 'package:chatapp/app/controllers/auth_controller.dart';
import 'package:chatapp/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Material(
            elevation: 5,
            child: Container(
              margin: EdgeInsets.only(top: context.mediaQueryPadding.top),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black38)),
              ),
              padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chats',
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: () {
                      Get.toNamed(Routes.PROFILE);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.red[900],
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: authC.user.value.photoUrl == "no image"
                                    ? Image.asset(
                                        'assets/logo/noimage.png',
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        authC.user.value.photoUrl!,
                                        fit: BoxFit.cover,
                                      ),
                      ),
                    ),
                  )
                  // Material(
                  //   borderRadius: BorderRadius.circular(50),
                  //   color: Colors.red[900],
                  //   child: InkWell(
                  //     borderRadius: BorderRadius.circular(50),
                  //     onTap: () {
                  //       Get.toNamed(Routes.PROFILE);
                  //     },
                  //     child: Padding(
                  //       padding: const EdgeInsets.all(5.0),
                  //       child: Icon(
                  //         Icons.person,
                  //         size: 35,
                  //         color: Colors.white,
                  //       ),
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: controller.chatStream(authC.user.value.email!),
                builder: (context, snapshot1) {
                  if (snapshot1.connectionState == ConnectionState.active) {
                  var listDocsChats = snapshot1.data!.docs;
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: listDocsChats.length,
                    itemBuilder: (context, index) {
                      return StreamBuilder<
                              DocumentSnapshot<Map<String, dynamic>>>(
                          stream: controller
                              .friendStream(listDocsChats[index]['connection']),
                          builder: (context, snapshot2) {
                            if (snapshot2.connectionState ==
                                ConnectionState.active) {
                              var data = snapshot2.data!.data();
                              return data!["status"] == ""
                                  ? ListTile(
                                    onLongPress: (){
                                            Get.defaultDialog(title: "Hapus Chat ini?",
                                            middleText: ""
                                            );
                                          },
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      onTap: () => controller.goToChatRoom(
                                          "${listDocsChats[index].id}",
                                          authC.user.value.email!,
                                          listDocsChats[index]['connection']),
                                      leading:
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: 
                                          Container(
                                            width: 50,
                                            height: 50,
                                          child : data["photoUrl"] == "noimage"
                                              ? Image.asset(
                                                  'assets/logo/noimage.png',
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.network(
                                                  data["photoUrl"],
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                      title: Text(
                                        '${data["name"]}',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      trailing: listDocsChats[index]
                                                  ["total_unread"] ==
                                              0
                                          ? SizedBox()
                                          : Chip(
                                              backgroundColor: Colors.red[900],
                                              label: Text(
                                                "${listDocsChats[index]["total_unread"]}",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                    )
                                  : ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      onTap: () => controller.goToChatRoom(
                                          "${listDocsChats[index].id}",
                                          authC.user.value.email!,
                                          listDocsChats[index]['connection']),
                                          onLongPress: (){
                                            Get.defaultDialog(title: "Hapus Chat ini?");
                                          },
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.black38,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: data["photoUrl"] == "noimage"
                                              ? Image.asset(
                                                  'assets/logo/noimage.png',
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.network(
                                                  data["photoUrl"],
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                        radius: 30,
                                      ),
                                      title: Text(
                                        '${data["name"]}',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Text(
                                        '${data["status"]}',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      trailing: listDocsChats[index]
                                                  ["total_unread"] ==
                                              0
                                          ? SizedBox()
                                          : Chip(
                                              backgroundColor: Colors.red[900],
                                              label: Text(
                                                "${listDocsChats[index]["total_unread"]}",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                    );
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          }
                          );
                    },
                  );
                  }return Center(child: CircularProgressIndicator());
                } 
                ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red[900],
        onPressed: () {
          Get.toNamed(Routes.SEARCH);
        },
        child: Icon(Icons.message_rounded),
      ),
    );
  }
}
