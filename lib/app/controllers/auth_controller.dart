import 'package:chatapp/app/data/models/chats_model.dart';
import 'package:chatapp/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../data/models/users_model.dart';

class AuthController extends GetxController {
  var isSkipIntro = false.obs;
  var isAuth = false.obs;

  GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;
  UserCredential? userCredential;

  var user = UsersModel().obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Auto Login
  Future<void> firstInitialized() async {
    await autoLogin().then((value) {
      if (value) {
        isAuth.value = true;
      }
    });

    await skipIntro().then((value) {
      if (value) {
        isSkipIntro.value = true;
      }
    });

    // Kita akan Mengubah isAuth => true => Auto Login
    try {
      final isSignIn = await _googleSignIn.isSignedIn();
      if (isSignIn) {
        isAuth.value = true;
      }
    } catch (err) {
      print(err);
    }
    // Kita akan Mengubah isSkipIntro => true
    final box = GetStorage();
    if (box.read('skipIntro') != null || box.read('skipIntro') == true) {
      isSkipIntro.value = true;
    }
  }

  Future<bool> skipIntro() async {
    final box = GetStorage();
    if (box.read('skipIntro') != null || box.read('skipIntro') == true) {
      return true;
    }
    return false;
  }

  Future<bool> autoLogin() async {
    // Kita akan Mengubah isAuth => true => Auto Login
    try {
      final isSignIn = await _googleSignIn.isSignedIn();
      if (isSignIn) {
        await _googleSignIn
            .signInSilently()
            .then((value) => _currentUser = value);
        final googleAuth = await _currentUser!.authentication;

        final creditial = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        await FirebaseAuth.instance
            .signInWithCredential(creditial)
            .then((value) => userCredential = value);

        print("User Credential");
        print(userCredential);
        CollectionReference users = firestore.collection('users');

        await users.doc(_currentUser!.email).update({
          "lastSignInTime":
              userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
        });

        final currentUser = await users.doc(_currentUser!.email).get();
        final currentUserData = currentUser.data() as Map<String, dynamic>;

        user(UsersModel.fromJson(currentUserData));

        user.refresh();
        final listChat =
            await users.doc(_currentUser!.email).collection('chats').get();

        if (listChat.docs.length != 0) {
          List<ChatUser> dataListChats = [];
          listChat.docs.forEach((element) {
            var dataDocChat = element.data();
            var dataDocChatId = element.id;
            dataListChats.add(ChatUser(
              chatId: dataDocChatId,
              connection: dataDocChat['connection'],
              lastTime: dataDocChat['lastTime'],
              totalUnread: dataDocChat['total_unread'],
            ));
          });
          user.update((user) {
            user!.chats = dataListChats;
          });
        } else {
          user.update((user) {
            user!.chats = [];
          });
        }

        user.refresh();

        return true;
      }
      return false;
    } catch (err) {
      return false;
    }
  }

  Future<void> login() async {
    try {
      // Ini untuk handle kebocoran data sebelum login
      await _googleSignIn.signOut();
      // Ini digunakan untuk medapatkan google account
      await _googleSignIn.signIn().then((value) => _currentUser = value);
      // Ini untuk mengecek status login user
      final isSignIn = await _googleSignIn.isSignedIn();

      if (isSignIn) {
        // Login Berhasil
        print("Sudah berhasil login dengan akun : ");
        print(_currentUser);

        final googleAuth = await _currentUser!.authentication;

        final creditial = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        await FirebaseAuth.instance
            .signInWithCredential(creditial)
            .then((value) => userCredential = value);

        print("User Credential");
        print(userCredential);

        //Simpan Status user bahwa sudah pernah Login dan tidak akan menampilkan introducition lagi
        final box = GetStorage();
        if (box.read('skipIntro') != null) {
          box.remove('skipIntro');
        }
        box.write('skipIntro', true);

        // Masukan data ke firebase
        CollectionReference users = firestore.collection('users');
        final checkuser = await users.doc(_currentUser!.email).get();

        if (checkuser.data() == null) {
          await users.doc(_currentUser!.email).set({
            "uid": userCredential!.user!.uid,
            "name": _currentUser!.displayName,
            "keyName": _currentUser!.displayName!.substring(0, 1).toUpperCase(),
            "email": _currentUser!.email,
            "photoUrl": _currentUser!.photoUrl ?? "no image",
            "status": "",
            "creationTime":
                userCredential!.user!.metadata.creationTime!.toIso8601String(),
            "lastSignInTime": userCredential!.user!.metadata.lastSignInTime!
                .toIso8601String(),
            "updateAt": DateTime.now().toIso8601String(),
          });

          await users.doc(_currentUser!.email).collection('chats');
        } else {
          await users.doc(_currentUser!.email).update({
            "lastSignInTime": userCredential!.user!.metadata.lastSignInTime!
                .toIso8601String(),
          });
        }

        final currentUser = await users.doc(_currentUser!.email).get();
        final currentUserData = currentUser.data() as Map<String, dynamic>;

        user(UsersModel.fromJson(currentUserData));

        user.refresh();
        final listChat =
            await users.doc(_currentUser!.email).collection('chats').get();

        if (listChat.docs.length != 0) {
          List<ChatUser> dataListChats = [];
          listChat.docs.forEach((element) {
            var dataDocChat = element.data();
            var dataDocChatId = element.id;
            dataListChats.add(ChatUser(
              chatId: dataDocChatId,
              connection: dataDocChat['connection'],
              lastTime: dataDocChat['lastTime'],
              totalUnread: dataDocChat['total_unread'],
            ));
          });
          user.update((user) {
            user!.chats = dataListChats;
          });
        } else {
          user.update((user) {
            user!.chats = [];
          });
        }

        user.refresh();

        isAuth.value = true;
        Get.offAllNamed(Routes.HOME);
      } else {
        print("Tidak berhasil login");

        // Login GAGAL
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> logout() async {
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
  // PROFILE

  void changeProfile(String name) {
    String date = DateTime.now().toIso8601String();
    // Update Firebase
    CollectionReference users = firestore.collection('users');

    users.doc(_currentUser!.email).update({
      "name": name,
      "keyName": name.substring(0, 1).toUpperCase(),
      "lastSignInTime":
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
      "updatedTime": date
    });

    // Update Models
    user.update(
      (user) {
        user!.name = name;
        user.keyName = name.substring(0, 1).toUpperCase();
        user.lastSignInTime =
            userCredential!.user!.metadata.lastSignInTime!.toIso8601String();
        user.updatedTime = date;
      },
    );

    user.refresh();

    Get.defaultDialog(
        title: "Sukses",
        middleText: "Update Profile Success",
        actions: [
          TextButton(
              onPressed: () {
                Get.toNamed(Routes.PROFILE);
              },
              child: Text('Back to Home'))
        ]);
  }

  void updateStatus(String status) {
    // Update Firebase
    CollectionReference users = firestore.collection('users');

    users.doc(_currentUser!.email).update({
      "status": status,
      "lastSignInTime":
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
      "updatedTime": DateTime.now().toIso8601String()
    });

    // Update Models
    user.update(
      (user) {
        user!.status = status;
        user.lastSignInTime =
            userCredential!.user!.metadata.lastSignInTime!.toIso8601String();
        user.updatedTime = DateTime.now().toIso8601String();
      },
    );

    user.refresh();

    Get.defaultDialog(title: "Sukses", middleText: "Update Status Success");
  }

  void updatePhotoUrl(String url) async {
    String date = DateTime.now().toIso8601String();

    CollectionReference users = firestore.collection('users');

    await users
        .doc(_currentUser!.email)
        .update({"photoUrl": url, "updatedTime": date});

    // Update Models
    user.update(
      (user) {
        user!.photoUrl = url;
        user.updatedTime = date;
      },
    );

    user.refresh();

    Get.defaultDialog(
        title: "Sukses", middleText: "Change photo profile Success");
  }
//SEARCH

  void addNewConnection(String friendsEmail) async {
    bool flagNewConnection = false;
    var chat_id;
    String date = DateTime.now().toIso8601String();
    CollectionReference chats = firestore.collection("chats");
    CollectionReference users = firestore.collection('users');

    // TODO : FIXING COLLECTION CHATS USER

    final docChats =
        await users.doc(_currentUser!.email).collection('chats').get();

    if (docChats.docs.length != 0) {
      // user sudah pernah chat dengan siapapun
      final checkConnection = await users
          .doc(_currentUser!.email)
          .collection('chats')
          .where('connection', isEqualTo: friendsEmail)
          .get();

      if (checkConnection.docs.length != 0) {
        // Sudah pernah buat koneksi dengan => friendEmail
        flagNewConnection = false;
        chat_id = checkConnection.docs[0].id; // chat_id from chatsCollection
      } else {
        // belum pernah  buat koneksi dengan => friendEmail
        // buat koneksi ...
        flagNewConnection = true;
      }
    } else {
      // Belom pernah chat dengan siapapun
      // buat koneksi ...
      flagNewConnection = true;
    }

// FIXING
    if (flagNewConnection) {
      // Cek dari chats collection => connection => mereka berdua
      // 1. kalo misalnya ada...
      final chatDocs = await chats.where(
        'connections',
        whereIn: [
          [
            _currentUser!.email, // zaeni project
            friendsEmail // zaeni
          ],
          [
            friendsEmail, // zaeni
            _currentUser!.email, // zaeni project
          ]
        ],
      ).get();

      if (chatDocs.docs.length != 0) {
        // Terdapat data chat(sudah ada koneksi antara mereka berdua)
        final chatDataId = chatDocs.docs[0].id;
        final chatData = chatDocs.docs[0].data() as Map<String, dynamic>;

        await users
            .doc(_currentUser!.email)
            .collection('chats')
            .doc(chatDataId)
            .set({
          "connection": friendsEmail,
          "lastTime": date,
          "total_unread": 0,
        });

        final listChat =
            await users.doc(_currentUser!.email).collection('chats').get();

        if (listChat.docs.length != 0) {
          List<ChatUser> dataListChats = List<ChatUser>.empty(growable: true);
          listChat.docs.forEach((element) {
            var dataDocChat = element.data();
            var dataDocChatId = element.id;
            dataListChats.add(ChatUser(
              chatId: dataDocChatId,
              connection: dataDocChat['connection'],
              lastTime: dataDocChat['lastTime'],
              totalUnread: dataDocChat['total_unread'],
            ));
          });
          user.update((user) {
            user!.chats = dataListChats;
          });
        } else {
          user.update((user) {
            user!.chats = [];
          });
        }

        chat_id = chatDataId;

        user.refresh();
      } else {
        // buat baru, mereka berdua benar2 belom ada koneksi
        final newChatDoc = await chats.add({
          "connections": [_currentUser!.email, friendsEmail],
        });

        await chats.doc(newChatDoc.id).collection('chat');

        await users
            .doc(_currentUser!.email)
            .collection('chats')
            .doc(newChatDoc.id)
            .set({
          "connection": friendsEmail,
          "lastTime": date,
          "total_unread": 0,
        });

        final listChat =
            await users.doc(_currentUser!.email).collection('chats').get();

        if (listChat.docs.length != 0) {
          List<ChatUser> dataListChats = List<ChatUser>.empty(growable: true);
          listChat.docs.forEach((element) {
            var dataDocChat = element.data();
            var dataDocChatId = element.id;
            dataListChats.add(ChatUser(
              chatId: dataDocChatId,
              connection: dataDocChat['connection'],
              lastTime: dataDocChat['lastTime'],
              totalUnread: dataDocChat['total_unread'],
            ));
          });
          user.update((user) {
            user!.chats = dataListChats;
          });
        } else {
          user.update((user) {
            user!.chats = [];
          });
        }

        chat_id = newChatDoc.id;

        user.refresh();
      }
    }

    final updateStatusChat = await chats
        .doc(chat_id)
        .collection('chat')
        .where("isRead", isEqualTo: false)
        .where('penerima', isEqualTo: _currentUser!.email)
        .get();
    // Update Status Chat
    updateStatusChat.docs.forEach((element) async {
      await chats
          .doc(chat_id)
          .collection('chat')
          .doc(element.id)
          .update({'isRead': true});
    });
    // Update Total Unread/ Mengubah Unread menjadi 0
    await users
        .doc(_currentUser!.email)
        .collection('chats')
        .doc(chat_id)
        .update({"total_unread": 0});

    Get.toNamed(Routes.CHAT_ROOM, arguments: {
      "chat_id": "$chat_id",
      "friendEmail": friendsEmail,
    });
  }

  // void deleteChat() async {
  //  await FirebaseFirestore.instance
  //       .collection('chat')
  //       .snapshots()
  //       .forEach((querySnapshot) {
  //     for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
  //       docSnapshot.reference.delete();
  //     }
  //   });
  // }
}


// Kondisi
// 1. Dia belum pernah buat koneksi/histori chat dengan => friendEmail

// 2. Dia sudah pernah buat koneksi/histori chat dengan => friendEmail
