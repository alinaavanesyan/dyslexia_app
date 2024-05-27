import 'package:firebase_auth/firebase_auth.dart';
import 'package:dyslexia_project/screens/home_screen.dart';
import 'package:dyslexia_project/screens/login_screen.dart';
import 'package:dyslexia_project/screens/register_screen.dart';
import 'package:dyslexia_project/screens/account_screen.dart';
import 'package:dyslexia_project/screens/google_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // print(user!.email!);
    if (user == null) {
      return Scaffold(body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset("assets/images/back3.png", fit: BoxFit.cover,),

          Center(
              child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Spacer(),
                      // SizedBox(height: 30),
                      Text("Добро пожаловать! ",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                                    // Spacer(),
                      Text("Здесь мы помогаем справляться с трудностями чтения",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.black54,
                                        // wordSpacing: 2.5,
                                        // height: 1.5,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 40),
                      // Spacer(),

                      Stack(children: [Positioned(
                                      // width: 0.4,
                                      //   // heightFactor: 1.7,
                          child: SizedBox(width: 250, child: Image.asset("assets/images/ping.png"))
                      )]),

                      SizedBox(height: 40),

                                    // Expanded(child: Image.asset("assets/images/ping.png",  width: 200, fit: BoxFit.fitWidth)),
                      // Spacer(),
                                    Container(margin: const EdgeInsets.all(0), child: Column(children: [
                                      Container(alignment: Alignment.center, child: MaterialButton(
                                        height: 55,
                                        minWidth: 250,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25.0)),
                                        color: Color(0xff294CFF),

                                        onPressed: () {
                                          if ((user == null)) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const RegisterPage()),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => const EditAccountScreen()),
                                            );
                                          }
                                        },
                                        child: Text(
                                          "Регистрация",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.white),
                                        ),
                                      )),

                                      SizedBox(height: 8, width: 10),
                                      Container(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [

                                        MaterialButton(
                                          minWidth: 125,
                                          height: 55,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(25.0)),
                                          color: Color(0xff303030),
                                          onPressed: () {
                                            //home screen path
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => LoginScreen()));
                                          },
                                          child: Text(
                                            "Вход",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Colors.white),
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        MaterialButton(
                                            minWidth: 125,
                                            height: 55,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(25.0)),
                                            color: Color(0xff3ffffff),
                                            onPressed: () {
                                              Authentication.signInWithGoogle().then((returnedUser) {
                                                if ((returnedUser != null) | (user !=null)) {
                                                  Navigator.pushReplacement<void, void>(
                                                    context,
                                                    MaterialPageRoute<void>(
                                                      builder: (BuildContext context) => const HomeScreen(),
                                                    ),
                                                  );
                                                } else {

                                                  // Do something if user is not null
                                                }
                                              });

                                            },

                                            child: Row(children: [
                                              SvgPicture.asset(
                                                'assets/icons/google.svg',
                                                height: 25,
                                                width: 25,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                "Google",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.black),
                                              ),
                                            ])

                                        )

                                    //
                                    //
                                    // Spacer(),

          ])

                                              )]))]))


            )]));

    }
    else {
      print(user.email);
      return HomeScreen();
    }
  }
}
