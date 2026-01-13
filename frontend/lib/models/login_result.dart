import 'package:firebase_auth/firebase_auth.dart';

class LoginResult {
  final User? user;
  final bool isDisabled;

  LoginResult({this.user, this.isDisabled = false});
}
