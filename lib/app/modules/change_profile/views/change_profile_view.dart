import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:chatapp/app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/change_profile_controller.dart';

class ChangeProfileView extends GetView<ChangeProfileController> {
  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    controller.emailC.text = authC.user.value.email!;
    controller.nameC.text = authC.user.value.name!;
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  authC.changeProfile(
                      controller.nameC.text,);
                },
                icon: Icon(Icons.save_as_outlined))
          ],
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(Icons.arrow_back)),
          title: const Text('Change Profile'),
          backgroundColor: Colors.red[900],
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              AvatarGlow(
                endRadius: 110,
                glowColor: Colors.black,
                child: Container(
                  width: 125,
                  height: 125,
                  child: Obx(() => ClipRRect(
                        borderRadius: BorderRadius.circular(200),
                        child: authC.user.value.photoUrl == "no image"
                            ? Image.asset(
                                'assets/logo/noimage.png',
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                authC.user.value.photoUrl!,
                                fit: BoxFit.cover,
                              ),
                      )),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                readOnly: true,
                controller: controller.emailC,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: BorderSide(color: Colors.red)),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 30, vertical: 20)),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                textInputAction: TextInputAction.next,
                controller: controller.nameC,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: BorderSide(color: Colors.red)),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 30, vertical: 20)),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GetBuilder<ChangeProfileController>(
                      builder: (c) => c.pickedImage != null
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 110,
                                  width: 125,
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(100),
                                          image: DecorationImage(
                                            image: FileImage(
                                              File(c.pickedImage!.path),
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                       Positioned(
                                        top: -13,
                                        right: -5,
                                         child: IconButton(
                                            onPressed: () {
                                              c.resetImage();
                                            },
                                            icon: Icon(Icons.disabled_by_default_outlined, color: Colors.red[900],)),
                                       ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                    onPressed: () {
                                      c.uploadImage(authC.user.value.uid!).then((hasilKembalian){
                                      if(hasilKembalian != null){
                                        authC.updatePhotoUrl(hasilKembalian);
                                      }
                                      });
                                    }, child: Text('Upload'))
                                
                              ],
                            )
                          : Text('No image'),
                    ),
                    TextButton(
                        onPressed: () {
                          controller.selectImage();
                        },
                        child: Text(
                          'Pilih file',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ))
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  width: Get.width,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                          backgroundColor: Colors.red[900]),
                      onPressed: () {
                        authC.changeProfile(
                            controller.nameC.text,);
                      },
                      child: Text(
                        'UPDATE',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      )))
            ],
          ),
        ));
  }
}
