import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dyslexia_project/screens/account_screen.dart';
import 'package:dyslexia_project/screens/login_screen.dart';
import 'package:dyslexia_project/elems.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:dyslexia_project/tasks/tasks.dart';
import 'package:dyslexia_project/screens/reading_section.dart';
import 'package:dyslexia_project/screens/lessons.dart';
import 'package:dyslexia_project/screens/instruction.dart';
import 'package:dyslexia_project/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dyslexia_project/screens/themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:dyslexia_project/recorder/recognizer.dart';
import 'package:dyslexia_project/recorder/new.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  getUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? email = user.email;
      String userId = user.uid;
      return {"userId": userId, "email": email};
    } else {
      String userId = 'None';
      String email = 'None';
      return {"userId": userId, "email": email};
    }
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Future<void> signOut() async {
    final navigator = Navigator.of(context);

    await FirebaseAuth.instance.signOut();

    navigator.pushNamedAndRemoveUntil('/welcome', (Route<dynamic> route) => false);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Переход на соответствующую страницу при выборе элемента
      switch (_selectedIndex) {
        case 0:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
          break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Lessons()
      ),
          );
          break;
          case 2:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TextListScreen()),
          );
          break;
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AccountScreen()),
          );
          break;
      }
    });
  }

  final User user = FirebaseAuth.instance.currentUser!;
  @override
  void initState() {
    super.initState();
    _checkInfo(user);
  }

  _checkInfo(User user) async {
    try {
      await user!.reload();
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(
          'passwords_storage').doc(user!.uid).get();
      final DocumentReference docRef = FirebaseFirestore.instance.collection(
          'passwords_storage').doc(user!.uid);
      var data = userDoc.data();
      if (user!.email != json.decode(json.encode(data))['Email']) {
          docRef.update({
            'Email': user!.email,
          });
      }
    }
    on FirebaseAuthException catch (e) {
      signOut();
    }
  }

  bool showInstructions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavyBar(
          selectedIndex: _selectedIndex,
          showElevation: true, // use this to remove appBar's elevation
          onItemSelected: _onItemTapped,
          items: [
            BottomNavyBarItem(
                icon: const Icon(Icons.home),
                title: const Text('Главная'),
                activeColor: Colors.orange,//Color(0xffFFF6D4),
                inactiveColor: Colors.grey[300]),
            BottomNavyBarItem(
              icon: const Icon(Icons.favorite_rounded),
              title: const Text('Уроки'),
              inactiveColor: Colors.grey[300],
              activeColor: Colors.orange,
            ),
            BottomNavyBarItem(
              icon: const Icon(Icons.message),
              title: const Text('Чтение'),
              inactiveColor: Colors.grey[300],
              activeColor: Colors.orange,
            ),
            BottomNavyBarItem(
              icon: const Icon(Icons.person),
              title: const Text('Профиль'),
              inactiveColor: Colors.grey[300],
              activeColor: Colors.orange,
            ),
          ],
        ),
        body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                "assets/images/back_star.png",
                fit: BoxFit.cover,
              ),

              SizedBox(height: 4, width: 10),

              Positioned(
                  top: 120,
                  left: 28,
                  child: Text(user!.displayName!,
                    style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 36),
              )),

              Positioned(
                  top: 130,
                  right: 28,
                  child: ElevatedButton(
                    // style: ElevatedButton.styleFrom(
                    //   backgroundColor: Color(0xffFFEBA4),
                    // ),
                    child:
                    Icon(Icons.contact_support_outlined, size: 20),
                    onPressed: () {
                      Navigator.push(
                          context,
                      MaterialPageRoute(builder: (context) => PageViewInstruction())
                      );
                    },
                  )),


              // Positioned(
              //     top: 130,
              //     right: 28,
              //     child:
              // IconButton(
              //   icon: Icon(Icons.info_outline),
              //   onPressed: () {
              //     setState(() {
              //       showInstructions = !showInstructions;
              //       onPressed: () {
              //         showDialog(
              //             context: context,
              //             builder: (BuildContext context) {
              //           return AlertDialog(
              //             title: Text('Popup Window'),
              //             content: Text('This is a popup window.'),
              //             actions: <Widget>[
              //               TextButton(
              //                 onPressed: () {
              //                   Navigator.of(context).pop();
              //                 },
              //                 child: Text('Close'),
              //               ),
              //             ],
              //           );
              //         },
              //
              //         );
              //       };});
              //   },
              // )),
              // if (showInstructions)
              //   SingleChildScrollView(
              //     scrollDirection: Axis.horizontal,
              //     padding: EdgeInsets.all(10.0),
              //     child: Row(
              //       children: <Widget>[
              //         Container(
              //           width: 200.0,
              //           height: 200.0,
              //           color: Colors.red,
              //           margin: EdgeInsets.all(10.0),
              //         ),
              //         Container(
              //           width: 200.0,
              //           height: 200.0,
              //           color: Colors.blue,
              //           margin: EdgeInsets.all(10.0),
              //         ),
              //         Container(
              //           width: 200.0,
              //           height: 200.0,
              //           color: Colors.green,
              //           margin: EdgeInsets.all(10.0),
              //         ),
              //       ],
              //     ),
              //   ),


        Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 200),
                // height: 200,
                decoration: BoxDecoration(
                    color: Color(0xffffffff),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      )
                    ]),
                child:
    SingleChildScrollView(
    scrollDirection: Axis.vertical,
    padding: const EdgeInsets.all(8),
    child: Column(children: [

    SizedBox(height: 4,),

    SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child:
    Padding(
    padding: EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 5),
    child: Column(children: [

    Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height,
                  child: Column(children: [

                    SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Lessons())
                              // Lessons()),
                          // SpeechToTextScreen()
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        elevation: MaterialStateProperty.all<double>(0),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(0)),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xffFFDF6D), Color(0xffFDA5FF)],
                          ),
                          borderRadius: BorderRadius.circular(16.0),),
                        padding: EdgeInsets.all(10.0),
                        child:Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 20.0),
                              Icon(Icons.play_circle_fill, color: Colors.white, size: 23),
                              SizedBox(width: 20.0),
                              Text('ПЕРЕЙТИ К УРОКАМ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                              SizedBox(width: 14.0),
                              Image.asset('assets/icons/buttonIcon.png', width: 55.0, height: 55.0), // Путь к изображению
                            ],
                          ),
                        ],
                      ),
                    )),

                    SizedBox(height: 20),
                    Padding(padding: EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 0), child:
                    Text('ПРАКТИКА ПО ТЕМАМ',  style: TextStyle(
                      fontSize: 18,
                      height: 0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: Color(0xff484643),
                      )),
                    ),
                    Divider(),

                    Container(child:
                    SingleChildScrollView(scrollDirection: Axis.vertical,
                        child: Column(children: [CategoryList()])))

                  ],),)
                ])))
            ])))]));
  }

  Column background_container(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 20),
          // height: 200,
          decoration: BoxDecoration(
            // color: Color(0xff294CFF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                )
              ]),
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

  Column background(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/images/back_star.png"), fit: BoxFit.fill)),
          child: Column(
            children: [
            ],
          ),
        ),
      ],
    );
  }

  Container main(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      // height: MediaQuery.of(context).size.height, // Устанавливаем высоту контейнера равной высоте экрана
      //     child: ListView(
      //     physics: const AlwaysScrollableScrollPhysics(),
      // children: [Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              )
            ]),

        // height:MediaQuery.of(context).size.height,
        // width: 340,
        child:
        Column(
            children: <Widget>[
              SizedBox(child:
              ListView(       // scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: [
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                            color: Colors.white,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(children: [Container(
                                      padding: const EdgeInsets.all(0),
                                      child:
                                      ListView(
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                if ((user == null)) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (
                                                            context) => const LoginScreen()),
                                                  );
                                                } else {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (
                                                            context) => const EditAccountScreen()),
                                                  );
                                                }
                                              },
                                              icon: Icon(
                                                Icons.person,
                                                color: (user == null)
                                                    ? Colors.white
                                                    : Colors.yellow,
                                              )),
                                          const CustomeAppBar(),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal: 10.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    const Column(
                                                      crossAxisAlignment: CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Text(
                                                          "Hi Julia",
                                                          style: TextStyle(
                                                            fontSize: 28,
                                                            fontWeight: FontWeight
                                                                .bold,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10.0,
                                                        ),
                                                        Text(
                                                          "Today is a good day\nto learn something new!",
                                                          style: TextStyle(
                                                            color: Colors
                                                                .black54,
                                                            wordSpacing: 2.5,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight
                                                                .w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const Spacer(),
                                                    Column(
                                                      children: [
                                                        Container(
                                                          height: 70,
                                                          width: 70,
                                                          decoration: BoxDecoration(
                                                              color: Colors.purple,
                                                              borderRadius: BorderRadius
                                                                  .circular(
                                                                  15.0)),
                                                          child: Image
                                                              .asset(
                                                            "assets/images/profile.png",
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                //sorting
                                                const Sorting(),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                //category list

                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    const Text(
                                                      "Categories",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight
                                                            .bold,
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {},
                                                      child: const Text(
                                                        "See All",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.blue),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                //now we create model of our images and colors which we will use in our app
                                                const SizedBox(
                                                  height: 20,
                                                ),

//                                                 const CategoryList(),


                                                const SizedBox(
                                                  height: 20,
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                  )])
                                ])))
                  ]))]));
  }}



