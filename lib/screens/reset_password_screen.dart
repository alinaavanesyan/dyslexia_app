import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dyslexia_project/services/snack_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController emailTextInputController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  FirebaseStorage storage = FirebaseStorage.instance;

  @override
  void dispose() {
    emailTextInputController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    final navigator = Navigator.of(context);
    final scaffoldMassager = ScaffoldMessenger.of(context);

    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailTextInputController.text);
          scaffoldMassager.showSnackBar(
              SnackBar(
            content: Text('Сброс пароля осуществен. Проверьте почту'),
            backgroundColor: Colors.green,
            )
          );
    } on FirebaseAuthException catch (e) {
      print(e.code);

      if (e.code == 'user-not-found') {
        SnackBarService.showSnackBar(
          context,
          'Такой email незарегистрирован!',
          true,
        );
        return;
      } else {
        SnackBarService.showSnackBar(
          context,
          'Неизвестная ошибка! Попробуйте еще раз или обратитесь в поддержку.',
          true,
        );
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: Stack(
        fit: StackFit.expand,
        children: [
        Image.asset("assets/images/back_light2.png", fit: BoxFit.cover,),

          Positioned(
              top: 50,
              left: 15,
              child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {Navigator.of(context).pop();},
              )
          ),
      Center(child:Padding(
        padding: EdgeInsets.all(16.0),
        child:
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                controller: emailTextInputController,
                validator: (email) =>
                    email != null && !EmailValidator.validate(email)
                        ? 'Введите правильный Email'
                        : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Введите Email',
                ),
              ),
              const SizedBox(height: 60),

            SizedBox(width: MediaQuery.of(context).size.width * 0.7, height: 50, child:
              ElevatedButton(
                onPressed: resetPassword,
                child: const Center(child: Text('Сбросить пароль', style: TextStyle(
                  color: Colors.white,
                ),
                )),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue), // Установка цвета фона кнопки
                ),
              )),
            ],
          ),
        ),
      ]),
    ))]));
  }
}
