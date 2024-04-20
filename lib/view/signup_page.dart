import 'package:flutter/material.dart';  //次回、controllerの追加
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart'; //誰が使用中かはリバポ使う

final userProvider = StateProvider<User?>((ref) => null);

class SignUpPage extends HookWidget {
  SignUpPage({super.key});
  final emailState = useState("");
  final passState = useState("");

  void onSignupButton() async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailState.value,
        password: passState.value,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');  //エラーポップアップ
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      else {
        print("作成エラー");
      }
    } catch (e) {
      return;  //calendarPageへ遷移
    }
  }

  Future<void> onLoginButton() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailState.value,
        password: passState.value,
      );
      //ここで画面遷移
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      } else {
        print('ログインエラー');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SignUp'),
      ),
      body: Stack(
        children: <Widget>[
          TextField(
            decoration: const InputDecoration(labelText:"Email"),
            onChanged: (value) => emailState.value,
          ),
          TextField(
            decoration: const InputDecoration(labelText: "Password"),
            obscureText: true,
            onChanged: (value) => passState.value,
          ),
          ElevatedButton(  //よくあるボタン
            child: const Text('新規登録'),
            onPressed: () => onSignupButton(),
          ),
          ElevatedButton(  //よくあるボタン
            child: const Text('ログイン'),
            onPressed: () => onLoginButton(),
          ),
        ]
      ),
    );
  }
}