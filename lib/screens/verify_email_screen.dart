import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dyslexia_project/screens/home_screen.dart';
import 'package:dyslexia_project/services/snack_bar.dart';
import 'package:dyslexia_project/screens/login_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
            (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    print(isEmailVerified);

    if (isEmailVerified) timer?.cancel();
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));

      setState(() => canResendEmail = true);
    } catch (e) {
      print(e);
      if (mounted) {
        SnackBarService.showSnackBar(
          context,
          '$e',
          //'Неизвестная ошибка! Попробуйте еще раз или обратитесь в поддержку.',
          true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? const HomeScreen()
      : Scaffold(
    resizeToAvoidBottomInset: false,
    // appBar: AppBar(
    //   title: const Text('Верификация Email адреса'),
    // ),
    body: Scaffold(body: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset("assets/images/back_light2.png", fit: BoxFit.cover,),
        // Positioned(top: 50, left: 15, child: IconButton(icon: Icon(Icons.arrow_back),
        //     onPressed: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => Lessons()),)
        // )),

        Positioned(
            top: 50,
            left: 15,
            child: IconButton(
                icon: Icon(Icons.arrow_back),
            //     onPressed: () =>
            //         Navigator.of(context).pop(),
            // )
              onPressed: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()))},
        )),
            Center(child:
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Padding(
                //     padding: const EdgeInsets.all(16.0),
                //     child: Container(color: Colors.white,
                //         width: 300, child: Text(name, softWrap: true,
                //           textAlign: TextAlign.center,
                //           style: TextStyle(
                //             fontSize: 18.0,
                //             fontWeight: FontWeight.bold,
                //           ),))),
                //
                const Text(
                  'Письмо с подтверждением было отправлено на вашу электронную почту',
              style: TextStyle(
                fontSize: 18,),
                softWrap: true,
                textAlign: TextAlign.center,
              ),

                const SizedBox(height: 40),

                ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.black), // Установка цвета фона кнопки
                  ),
                  onPressed: canResendEmail ? sendVerificationEmail : null,
                  icon: const Icon(Icons.email, color: Colors.white),
                  label: const Text('Повторно отправить', style: TextStyle(
                    color: Colors.white,
                  ),
                  ),
        ),
            const SizedBox(height: 20),
                TextButton(
                  onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));},
                  child: const Text(
                    'Войти',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                )
              ]),)
      ],
        ),
      ),
  );
}
