import 'package:chatapp/app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
final authC = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: Get.width * 0.7,
                height: Get.width * 0.7,
                child: Lottie.asset('assets/lottie/login.json'),
              ),
              SizedBox(
                height: 100,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    backgroundColor: Colors.grey[300]),
                onPressed: () {authC.login();},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      child: Image.asset('assets/logo/google.png'),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Sign in with Google',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class LoadingScrenn extends StatelessWidget {
  const LoadingScrenn({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: Get.width * 0.7,
                    height: Get.width * 0.7,
                    child: Lottie.asset('assets/lottie/login.json'),
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: Colors.grey[300]),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          child: Image.asset('assets/logo/google.png'),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Sign in with Google',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ),
          ),
          Center(child: CircularProgressIndicator(),)
        ],
      ));
  }
}
