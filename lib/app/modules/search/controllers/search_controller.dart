import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchController1 extends GetxController {
  late TextEditingController searchC;

  var queryAwal = [].obs;
  var tempSearch = [].obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void searchFriend(String data, String email) async {
    if (data.length == 0) {
      queryAwal.value = [];
      tempSearch.value = [];
    } else {
      var capitalized = data.substring(0, 1).toUpperCase() + data.substring(1);

      if (queryAwal.length == 0 && data.length == 1) {
        // Fungsi yang akan di jalankan pada 1 ketikan pertama
        CollectionReference users = await firestore.collection("users");
        final keyNameResult = await users
            .where("keyName", isEqualTo: data.substring(0, 1).toUpperCase())
            .where("email", isNotEqualTo: email)
            .get();

        if (keyNameResult.docs.length > 0) {
          for (int i = 0; i < keyNameResult.docs.length; i++) {
            queryAwal.add(keyNameResult.docs[i].data() as Map<String, dynamic>);
          }
          print("Query Result : ");
          print(queryAwal);
        } else {
          print('Tidak ada data');
        }
      }

      if (queryAwal.length != 0) {
        tempSearch.value = [];
        queryAwal.forEach(
          (element) {
            if (element['name'].startsWith(capitalized)) {
              tempSearch.add(element);
            }
          },
        );
      }
    }

    queryAwal.refresh();
    tempSearch.refresh();
  }

  @override
  void onInit() {
    searchC = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    searchC.dispose();
    super.onClose();
  }
}
