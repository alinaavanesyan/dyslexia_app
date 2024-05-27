import 'package:flutter/material.dart';
import 'package:dyslexia_project/screens/home_screen.dart';
import 'package:dyslexia_project/screens/account_screen.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:dyslexia_project/screens/reading_section.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dyslexia_project/services/database.dart';
import 'dart:math';
import 'dart:async';
import 'package:dyslexia_project/tasks/tasks_data.dart';

class Lessons extends StatefulWidget {
  const Lessons({super.key});


  @override
  State<Lessons> createState() => _Lessons();
}

class _Lessons extends State<Lessons> {

  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
            MaterialPageRoute(builder: (context) => Lessons()),
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

  LessonsDonePercent2(index, length) {
    return FirestoreService().LessonsDonePercent(getUserId(), index, length);
  }

  final User user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _checkInfo(user);
  }

  Future<void> signOut() async {
    final navigator = Navigator.of(context);

    await FirebaseAuth.instance.signOut();

    navigator.pushNamedAndRemoveUntil('/welcome', (Route<dynamic> route) => false);
  }

  _checkInfo(User user) async {
    try {
      await user!.reload();
    }
    on FirebaseAuthException catch (e) {
      signOut();
    }
  }

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
                "assets/images/back_yellow.png",
                // "assets/images/back_peurple.png",
                fit: BoxFit.cover,
              ),

              Positioned(
                  top: 50,
                  left: 15,
                  child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () =>
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen()),)
                  )
              ),

              Positioned(
                top: 100,
                // left: 15,
                left: MediaQuery
                  .of(context)
                  .size
                  .width * 0.08,
                child: Center(child: Text(
                  'Уроки',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),

                  Padding(
                  padding: EdgeInsets.only(top: 130.0, right: 10, left: 10),
                  child:
              ListView.builder(
                itemCount: lessonItems.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      height: MediaQuery.of(context).size.height * 0.11,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                  child: ListTile(
                      leading: Container(
                        child: Image.asset('assets/icons/graduate-hat.png'),
                      ),

                      title: Text('Урок №${index+1}'),
                      subtitle:  Text(lessonItems[index].title, style: TextStyle(fontSize: 11),),
                      trailing: FutureBuilder<double>(
                        future: FirestoreService().LessonsDonePercent(getUserId(), index+1, lessonItems[index].tasks.length),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          else {
                            return Container(
                                width: 100, child:LinearProgressIndicator(value: snapshot.data ?? 0.0,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                snapshot.data == 1
                                ? Colors.green
                                    : snapshot.data == 0
                                ? Colors.grey
                                : Colors.orange
                            )));
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.push(context,
                        MaterialPageRoute(
                          builder: (context) => LessonDetailScreen(lessonItems[index]), // lessonItems[index]
                        ),);
                    },
                  ),
                  ));
                },
              )),
            ])
    );
  }
}

class LessonDetailScreen extends StatefulWidget {
  final LessonItem lessonItem;
  // final HearTask hearTask;

  // const LessonDetailScreen({Key? key, required this.hearTask}) : super(key: key);
  LessonDetailScreen(this.lessonItem); // this.hearTask

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  int currentLessonIndex = 0;
  bool change = false;
  var res;

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
  var all_indexes = [];
  late Timer timer;
  var randomImageIndex = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      randomImageIndex = Random().nextInt(6) + 1;
    });
    _handleGameUpdate();
  }

  void _handleGameUpdate() {
    setState(() {
      change = false;
    });
    final all_indexes = List.generate(
        widget.lessonItem.tasks.length, (index) => index + 1);
    res = FirestoreService().LessonCheck2(
        getUserId(), widget.lessonItem.index);
    res.then((done_tasks) {
      List task_indexes = done_tasks.map((e) => int.parse(e)).toList();
      all_indexes.removeWhere((element) =>
          task_indexes.contains(element));
      if (all_indexes.length != 0) {
        setState(() {
          currentLessonIndex = all_indexes[0];
          change = true;
        });
      }
      else {
        setState(() {
          currentLessonIndex = -1;
          change = true;
        });}
    });
}

  Widget finishScreen() {
    return Scaffold(body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/finish_back.png", fit: BoxFit.cover,),
          Positioned(top: 50, left: 15, child: IconButton(icon: Icon(Icons.arrow_back),
              onPressed: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => Lessons()),)
          )),

        Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Центрируем по вертикали
              children: <Widget>[
                randomImageIndex != 0 ?
                Image.asset(
                  "assets/finish_gifs/$randomImageIndex.gif",
                  width: 200,
                  height: 200,
                ) : CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Урок №${widget.lessonItem.index} выполнен. Вы огромный молодец!', textAlign: TextAlign.center, style:
                  TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color(0xff286419)),),
                SizedBox(height: 40),
                TextButton(
                  style: ButtonStyle(
                    // minimumSize: MaterialStateProperty.all(Size(90, 50)), //
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                  ),
                  onPressed: () {

                    FirestoreService().LessonDeleteInfo(
                        getUserId(), widget.lessonItem.index);
                    setState(() {
                      currentLessonIndex = 1;
                    });
                  },
                  child: SizedBox(
                    width: 250,
                    child:
                    Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Начать заново', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold,
                          color: Colors.white)),
                      SizedBox(width: 8), // Промежуток между текстом и значком
                      Icon(Icons.refresh, color: Colors.white),
                    ],
                  )),
                )
            ])),

          SizedBox(height: 15,),
        ]));
  }

  Widget hearTask(index) {
  return widget.lessonItem.tasks[index][3]..onGameUpdate = _handleGameUpdate;
}

  @override
  Widget build(BuildContext context) {
    if (change == false)
      return Container(
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator(),
        ));

    else return
      currentLessonIndex != -1 ?  hearTask(currentLessonIndex) : finishScreen();
  }
}
