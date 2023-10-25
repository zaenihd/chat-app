import 'package:chatapp/app/controllers/auth_controller.dart';
import 'package:chatapp/app/modules/search/controllers/search_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';


class SearchView extends GetView<SearchController1> {
  final authC = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: AppBar(
          backgroundColor: Colors.red[900],
          title: const Text('Search'),
          centerTitle: true,
          leading: IconButton(
              onPressed: () => Get.back(), icon: Icon(Icons.arrow_back)),
          flexibleSpace: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 50, 30, 20),
                child: TextField(
                  onChanged: (value) =>
                      controller.searchFriend(value, authC.user.value.email!),
                  controller: controller.searchC,
                  cursorColor: Colors.red[900],
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.white, width: 1),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.white, width: 1),
                      ),
                      hintText: "Search new friends..",
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                      suffixIcon: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {},
                          child: Icon(
                            Icons.search,
                            color: Colors.red[900],
                          ))),
                ),
              )),
        ),
        preferredSize: Size.fromHeight(135),
      ),
      body: Obx(
        () => controller.tempSearch.length == 0
            ? Center(
                child: Container(
                  width: Get.width * 0.7,
                  height: Get.height * 0.7,
                  child:
                      Lottie.asset('assets/lottie/empty.json', repeat: false),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: controller.tempSearch.length,
                itemBuilder: (context, index) => ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  leading: CircleAvatar(
                    backgroundColor: Colors.black38,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: controller.tempSearch[index]["photoUrl"] ==
                                "noimage"
                            ? Image.asset(
                                'assets/logo/noimage.png',
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                controller.tempSearch[index]["photoUrl"],
                                fit: BoxFit.cover,
                              )),
                    radius: 30,
                  ),
                  title: Text(
                    '${controller.tempSearch[index]["name"]}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "${controller.tempSearch[index]["email"]}",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  trailing: GestureDetector(
                      onTap: () {
                        authC.addNewConnection(
                            controller.tempSearch[index]["email"]);
                      },
                      child: Chip(label: Text('Message'))),
                ),
              ),
      ),
    );
  }
}
