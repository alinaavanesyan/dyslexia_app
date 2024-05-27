import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:dyslexia_project/services/database.dart';

class Auth {
  signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
    await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Sign in with the credential
    final authResult = await FirebaseAuth.instance.signInWithCredential(credential);
    final User? user = authResult.user;
  }
}

Future<UserCredential> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );
  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}


class Authentication {
  static Future<User?> signInWithGoogle() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
    await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
        await auth.signInWithCredential(credential);

        user = userCredential.user;
        FirestoreService().updateGoogleEmail(user);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          Get.showSnackbar(const GetSnackBar(
            message: "You already have an account with this email. Use other login method.",
            duration: Duration(seconds: 3),
          ));
        }
        else if (e.code == 'invalid-credential') {
          Get.showSnackbar(const GetSnackBar(
            message: "Invalid Credential!",
            duration: Duration(seconds: 3),
          ));
        } else if (e.code == 'wrong-password') {
          Get.showSnackbar(const GetSnackBar(
            message: "Wrong password!",
            duration: Duration(seconds: 3),
          ));
        }
      } catch (e) {
        Get.showSnackbar(const GetSnackBar(
          message: "Unknown Error. Try again later",
          duration: Duration(seconds: 3),
        ));
      }
    }

    return user;
  }
}
