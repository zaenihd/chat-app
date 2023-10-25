import 'package:avatar_glow/avatar_glow.dart';
import 'package:chatapp/app/controllers/auth_controller.dart';
import 'package:chatapp/app/routes/app_pages.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  final autC = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                autC.logout();
              },
              icon: Icon(
                Icons.logout,
                color: Colors.black,
              ))
        ],
        leading: IconButton(
          onPressed: () {
            Get.toNamed(Routes.HOME);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              child: Column(
                children: [
                  Obx(() => AvatarGlow(
                        endRadius: 110,
                        glowColor: Colors.black,
                        child: InkWell(
                          onTap: () {
                            showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        title: autC.user.value.photoUrl == "no image"
                                  ? Image.asset(
                                      'assets/logo/noimage.png',
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      autC.user.value.photoUrl!,
                                      fit: BoxFit.cover,
                                    ),));
                          },
                          child: Container(
                            width: 175,
                            height: 175,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(200),
                              child: autC.user.value.photoUrl == "no image"
                                  ? Image.asset(
                                      'assets/logo/noimage.png',
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      autC.user.value.photoUrl!,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              image: DecorationImage(
                                image: AssetImage('assets/logo/noimage.png'),
                              ),
                            ),
                          ),
                        ),
                      )),
                  SizedBox(
                    height: 15,
                  ),
                  Obx(() => Text(
                        '${autC.user.value.name}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                  Text(
                    '${autC.user.value.email}',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.black38),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Container(
                child: Column(
                  children: [
                    ListTile(
                      onTap: () {
                        Get.toNamed(Routes.UPDATE_STATUS);
                      },
                      title: Text(
                        'Update Status',
                        style: TextStyle(fontSize: 20),
                      ),
                      leading: Icon(Icons.add_circle_outline_rounded),
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                    ListTile(
                      onTap: () {
                        Get.toNamed(Routes.CHANGE_PROFILE);
                      },
                      title: Text(
                        'Change Profile',
                        style: TextStyle(fontSize: 20),
                      ),
                      leading: Icon(Icons.person),
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: context.mediaQueryPadding.bottom),
              child: Column(
                children: [
                  Text(
                    'Chat App',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  Text(
                    'v1.0',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
