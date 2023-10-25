import 'package:chatapp/app/routes/app_pages.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/introduction_controller.dart';

import 'package:introduction_screen/introduction_screen.dart';

class IntroductionView extends GetView<IntroductionController> {
  const IntroductionView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            title: "Berinteraksi dengan mudah",
            body: "Kamu hanya perlu di rumah saja untuk mendapatkan teman baru",
            image: Center(
                child: Container(
                    width: Get.width * 0.6,
                    height: Get.height * 0.6,
                    child:
                        Lottie.asset('assets/lottie/main-laptop-duduk.json'))),
          ),
          PageViewModel(
            title: "Temukan sahabat baru",
            body:
                "Jika kamu memang jodoh karena aplikasi ini, kami sangat bahagia",
            image: Center(
                child: Container(
                    width: Get.width * 0.6,
                    height: Get.height * 0.6,
                    child: Lottie.asset('assets/lottie/ojek.json'))),
          ),
          PageViewModel(
            title: "Aplikasi bebas biaya",
            body: "Kamu tidak perli khawatir, aplikasi ini bebas biaya apapun",
            image: Center(
                child: Container(
                    width: Get.width * 0.6,
                    height: Get.height * 0.6,
                    child: Lottie.asset('assets/lottie/payment.json'))),
          ),
          PageViewModel(
            title: "Gabung sekarang juga",
            body:
                "Daftar diri kamu untuk menjadi bagian dari kami. Kami akan menghubungkan dengan 1000 teman lainnya",
            image: Center(
                child: Container(
                    width: Get.width * 0.6,
                    height: Get.height * 0.6,
                    child: Lottie.asset('assets/lottie/register.json'))),
          ),
        ],
        onDone: () => Get.offAllNamed(Routes.LOGIN),
        showBackButton: false,
        showSkipButton: true,
        skip: Text("Skip"),
        next: Text("Next"),
        done: const Text("Login", style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
