import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dyslexia_project/services/snack_bar.dart';
import 'package:dyslexia_project/screens/login_screen.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isHiddenPassword = true;
  TextEditingController nameTextInputController = TextEditingController();
  TextEditingController emailTextInputController = TextEditingController();
  TextEditingController passwordTextInputController = TextEditingController();
  TextEditingController passwordTextRepeatInputController =
  TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameTextInputController.dispose();
    emailTextInputController.dispose();
    passwordTextInputController.dispose();
    passwordTextRepeatInputController.dispose();

    super.dispose();
  }

  void togglePasswordView() {
    setState(() {
      isHiddenPassword = !isHiddenPassword;
    });
  }


  Future<void> signUp() async {
    final navigator = Navigator.of(context);

    if (passwordTextInputController.text !=
        passwordTextRepeatInputController.text) {
      SnackBarService.showSnackBar(
        context,
        'Пароли должны совпадать',
        true,
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextInputController.text.trim(),
        password: passwordTextInputController.text.trim(),
      );

      if (userCredential.user != null) {
        await userCredential.user!.updateProfile(displayName: nameTextInputController.text.trim());
      }

      } on FirebaseAuthException catch (e) {
      print(e.code);

      if (e.code == 'invalid-email') {
        print('tutochki');
      }
        if (e.code == 'email-already-in-use') {
        SnackBarService.showSnackBar(
          context,
          'Такой Email уже используется, повторите попытку с использованием другого Email',
          true,
        );
        return;
      } else {
        SnackBarService.showSnackBar(
          context,
          'Некорректный Email адрес',
          true,
        );
      }
    }

    if (FirebaseAuth.instance.currentUser != null) {
      navigator.pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
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
              child: main_container(),
            ),
          ],
        ),
      ),
    );
  }

  Container main_container() {
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
          SizedBox(width: 5, height: 20),
          Text(
            'Регистрация',
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xff1B1B1B)),
          ),
          SizedBox(width: 5, height: 10),
          FractionallySizedBox(
              widthFactor: 0.85,
              child: TextFormField(
                  keyboardType: TextInputType.name,
                  autocorrect: false,
                  controller: nameTextInputController,
                  validator: (name) =>
                  name != null
                      ? 'Необходимо ввести имя'
                      : null,
                  decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 2.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      labelText: 'Имя',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                      hintText: 'Введите ваше имя',
                      hintStyle: TextStyle(fontSize: 16.0, color: Colors.grey, fontWeight: FontWeight.w100)
                  ))),
          FractionallySizedBox(
            widthFactor: 0.85,
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              controller: emailTextInputController,
              validator: (email) =>
              email != null && EmailValidator.validate(email)
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
            ),),

          FractionallySizedBox(
              widthFactor: 0.85,
              child:
                TextFormField(
                  autocorrect: false,
                  controller: passwordTextInputController,
                  obscureText: isHiddenPassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => value != null && value.length < 6
                      ? 'Минимум 6 символов'
                      : null,
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

                      hintText: 'Придумайте пароль',
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

          FractionallySizedBox(
              widthFactor: 0.85,
              child: TextFormField(
                  autocorrect: false,
                  controller: passwordTextRepeatInputController,
                  obscureText: isHiddenPassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => value != null && value.length < 6
                      ? 'Минимум 6 символов'
                      : null,
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 2.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      labelText: 'Подтверждение пароля',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),

                      hintText: 'Введите пароль еще раз',
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

          const SizedBox(height: 50),

          SizedBox(height: 50, child:
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
              onPressed: signUp,
              child: const Center(child: Text('Регистрация', style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white),
              ),
              ),
            ),),),

          SizedBox(height: 15),
          TextButton(
            onPressed: () {Navigator.push(context, MaterialPageRoute(
                builder: (context) =>   LoginScreen()));},
            child: const Text(
              'Войти',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
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
              const SizedBox(height: 40),
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
