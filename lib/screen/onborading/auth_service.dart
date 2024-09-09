import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  Future<String> createUser(String userEmail, String userPassword) async {
    String flag = "false";
    try {
      await firebaseAuth
          .createUserWithEmailAndPassword(
              email: userEmail, password: userPassword)
          .then((userCredential) async {
        await userCredential.user!
            .sendEmailVerification()
            .whenComplete(() async {
          flag = "true ${userCredential.user!.uid}";
        });
      });
    } on FirebaseException catch (e) {
      flag = e.message!;
    }
    return flag;
  }

  Future<String> loginUser(String userEmail, String password) async {
    String flag = "false";
    try {
      await firebaseAuth
          .signInWithEmailAndPassword(email: userEmail, password: password)
          .then((userInfo) async {
        if (firebaseAuth.currentUser!.emailVerified) {
          flag = "true";
        } else {
          await userInfo.user!.sendEmailVerification().whenComplete(() {
            flag = "Email verification message sent to $userEmail";
          });
        }
      });
    } on FirebaseException catch (e) {
      flag = e.message!;
    }
    return flag;
  }

  storeUserInfo(dynamic data) async {
    try {
      await fireStore.collection('user').doc(data["uid"]).set(data);
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }

  resetPassword(String userEmail) async {
    String flag = "false";
    try {
      await firebaseAuth
          .sendPasswordResetEmail(email: userEmail)
          .whenComplete(() {
        flag = "true";
      });
    } on FirebaseException catch (e) {
      flag = e.message!;
    }
    return flag;
  }
}
