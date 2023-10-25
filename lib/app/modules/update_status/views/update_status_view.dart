import 'package:chatapp/app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/update_status_controller.dart';

class UpdateStatusView extends GetView<UpdateStatusController> {
  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    controller.statusC.text = authC.user.value.status!;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: (){
            Get.back();
          }, icon: Icon(Icons.arrow_back)),
          title: const Text('Update Status'),
          backgroundColor: Colors.red[900],
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                autocorrect: false,
                textInputAction: TextInputAction.done,
                onEditingComplete: (){
                  authC.updateStatus(controller.statusC.text);
                },
                controller: controller.statusC,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  labelText: 'Status',
                  labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide(color: Colors.red)
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 30, vertical: 20)),
              ),
              SizedBox(height: 30,),
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
                        authC.updateStatus(controller.statusC.text);
                      },
                      child: Text(
                        'UPDATE',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )))
            ],
          ),
        ));
  }
}
