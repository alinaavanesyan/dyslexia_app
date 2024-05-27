import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dyslexia_project/services/snack_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dyslexia_project/services/database.dart';

FirebaseStorage storage = FirebaseStorage.instance;

String password123 = '';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isHiddenPassword = true;
  TextEditingController emailTextInputController = TextEditingController();
  TextEditingController passwordTextInputController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? userpassword;
  FirebaseStorage storage = FirebaseStorage.instance;

  @override
  void dispose() {
    emailTextInputController.dispose();
    passwordTextInputController.dispose();
    // password123 = passwordTextInputController.text.trim();
    super.dispose();
  }

  // getpassword() {
  //   var password = passwordTextInputController;
  // }

  void togglePasswordView() {
    setState(() {
      isHiddenPassword = !isHiddenPassword;
    });
  }

  Future<void> signOut() async {
    final navigator = Navigator.of(context);

    await FirebaseAuth.instance.signOut();

    navigator.pushNamedAndRemoveUntil('/welcome', (Route<dynamic> route) => false);
  }

  Future<void> login() async {
    final navigator = Navigator.of(context);

    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextInputController.text.trim(),
        password: passwordTextInputController.text.trim(),
      );
      userpassword = passwordTextInputController.text.trim();
    } on FirebaseAuthException catch (e) {
      print(e.code);

      if (emailTextInputController.text.trim() == null &&
          passwordTextInputController.text.trim() != null){
        print(emailTextInputController.text.trim());
        SnackBarService.showSnackBar(
          context,
          'Введите корректную электронную почту',
          true,
        );
        return;
      } if (emailTextInputController.text.trim() != null &&
          passwordTextInputController.text.trim() == null){
        SnackBarService.showSnackBar(
          context,
          'Введите пароль',
          true,
        );
        return;
      }
      print(emailTextInputController.text.trim());
      print(passwordTextInputController.text.trim());
      print(e.code);
      // if (e.code == 'user-not-found' || e.code == 'wrong-password') {
      if (e.code == 'invalid-credential') {
        SnackBarService.showSnackBar(
          context,
          'Неправильный email или пароль. Повторите попытку',
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

    try {
      final User user = FirebaseAuth.instance.currentUser!;
      print(user!.uid);
      FirestoreService().updatePassword(user, passwordTextInputController.text.trim());
      navigator.pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    }
    on FirebaseAuthException
    catch(e) {
      signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAFBEC),
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            background_container(context),
            Positioned(
              top: 120,
              child: main_container(context),
            ),
          ],
        ),
      ),
    );
  }

  Container main_container(BuildContext contex) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xd9FFFFFF),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),

        height: 500,
        width: 340,
        child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          SizedBox(width: 5, height: 20),
                          Text(
                            'Вход',
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff1B1B1B)),
                          ),
                          SizedBox(width: 5, height: 10),

                          FractionallySizedBox(
                            widthFactor: 0.85,
                            child:
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              controller: emailTextInputController,
                              validator: (email) =>
                              email != null && !EmailValidator.validate(email)
                                  ? 'Введите правильный Email'
                                  : null,
                              decoration: const InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green, width: 2.0),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                  ),
                                  // border: OutlineInputBorder(),
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  hintText: 'Введите Email',
                                  hintStyle: TextStyle(fontSize: 16.0, color: Colors.grey, fontWeight: FontWeight.w100)
                              ),
                              // C3E2F9
                            ),),

                          FractionallySizedBox(
                              widthFactor: 0.85,
                              child:  TextFormField(
                                  autocorrect: false,
                                  controller: passwordTextInputController,
                                  obscureText: isHiddenPassword,
                                  validator: (value) => value != null && value.length < 6
                                      ? 'Минимум 6 символов'
                                      : null,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  decoration: InputDecoration(
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.green, width: 2.0),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                      ),
                                      labelText: 'Пароль',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                      ),

                                      hintText: 'Введите пароль',
                                      suffix: InkWell(
                                        onTap: togglePasswordView,
                                        child: Icon(
                                          isHiddenPassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.black,
                                        ),
                                      ),
                                      hintStyle: TextStyle(fontSize: 16.0, color: Colors.grey, fontWeight: FontWeight.w100)
                                  ))),

                          SizedBox(height: 45),
                          SizedBox(height: 50,
                            child:
                            FractionallySizedBox(
                              widthFactor: 0.85,
                              // width: 250,
                              // height: 50,
                              child:
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25.0)),
                                  backgroundColor: Color(0xff294CFF),
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white),
                                ),
                                onPressed: login,
                                child: const Center(child: Text('Войти', style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white),
                                ),
                                ),
                              ),),),

                          SizedBox(height: 15),

                          TextButton(
                            onPressed: () =>
                                Navigator.of(context).pushNamed('/reset_password'),
                            child: const Text('Сбросить пароль'),
                          ),
                        ],

                      )))]));
  }


  Column background_container(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xffB5C1FF), Color(0xffFFCAF7)]),
              // color: Color(0xff294CFF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                )]),
          child: Column(
            children: [
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ],
    );
  }
}
