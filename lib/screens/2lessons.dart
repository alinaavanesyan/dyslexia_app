import 'package:flutter/material.dart';
import 'package:dyslexia_project/screens/home_screen.dart';
import 'package:dyslexia_project/screens/account_screen.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:dyslexia_project/screens/reading_section.dart';
import 'package:dyslexia_project/tasks/tasks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dyslexia_project/services/database.dart';
import 'dart:math';
import 'dart:async';

class LessonItem {
  int index;
  String title;
  String difficulty;
  // String content;
  // StatefulWidget which_widget;
  Map tasks;

  LessonItem(this.index, this.title, this.difficulty, this.tasks);
}

List<LessonItem> lessonItems = [
  LessonItem(1, 'Урок 1. Учимся различать звуки', 'easy',
  { 1: ['optical_dyslexia', '1_hear_letter', 'easy',
    HearTask(TaskType: 'optical_dyslexia', TaskName: '1_hear_letter', TaskDifficulty: 'easy', flag: 'lesson',
        lessonInfo: ['1', '1', DateTime.now()])],
    2: ['optical_dyslexia', '1_hear_letter', 'easy',
      HearTask(TaskType: 'optical_dyslexia', TaskName: '1_hear_letter', TaskDifficulty: 'easy', flag: 'lesson',
          lessonInfo: ['1', '2', DateTime.now()])],
    // 3: ['optical_dyslexia', '2_insert_letter', 'easy'],
    // 4: ['optical_dyslexia', '2_insert_letter', 'easy']
  }),

];

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
                  padding: EdgeInsets.only(top: 90.0, right: 10, left: 10),
                  child:
              ListView.builder(
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      height: MediaQuery.of(context).size.height * 0.10,
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

                      title: Text('Заголовок элемента $index'),
                      trailing: Container(
                        width: 100, // Ширина прогресс-бара
                        child: LinearProgressIndicator(
                          value: 0.5, // Пример прогресса (замените на свою логику)
                        ),
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
  LessonDetailScreen(this.lessonItem);

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  int currentLessonIndex = 1;
  bool change = false;
  int _selectedIndex = 2;
  var res;

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
            MaterialPageRoute(builder: (context) => Lessons()),
          );
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Lessons()),
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
  // widget.lessonItem.tasks[currentLessonIndex][3] state;

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

    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      // if (currentLessonIndex == -1) {
      //   t.cancel();
      // }
      // else {
        setState(() {
          var all_indexes2 = List.generate(
              widget.lessonItem.tasks.length, (index) => index + 1);
          res = FirestoreService().LessonCheck2(
              getUserId(), widget.lessonItem.index);
          print(currentLessonIndex);
          print('Длина списка');
          print(widget.lessonItem.tasks.length);
          // change = widget.lessonItem.tasks[currentLessonIndex][3].done;
          res.then((done_tasks) {
            // print(!done_tasks.contains('no'));
            if (done_tasks.length == 0) {
              print('пусто');
              setState(() {
                currentLessonIndex = 1;
                change = true;
              });
            }
            else {
              List task_indexes = done_tasks.map((e) => int.parse(e)).toList();
              all_indexes2.removeWhere((element) =>
                  task_indexes.contains(element));
              if (all_indexes2.length != 0) {
                setState(() {
                  all_indexes = all_indexes2;
                  currentLessonIndex = all_indexes2[0];
                  change = true;
                });
                print(
                    'Наш индекс: $currentLessonIndex Индексы все $all_indexes');
              }
              else {
                currentLessonIndex = -1;
                change = true;
              }
            }


            //   List task_indexes = done_tasks.map((e) => int.parse(e)).toList();
            //   print('такси');
            //   all_indexes2.removeWhere((element) =>
            //       task_indexes.contains(element));
            //   print('Индексы все');
            //   print(all_indexes2);
            //   if (all_indexes2.length != 0) {
            //     setState(() {
            //       all_indexes = all_indexes2;
            //       currentLessonIndex = all_indexes2[0];
            //       change = true;
            //     });
            //   }
            //   else {
            //     setState(() {
            //       currentLessonIndex = -1;
            //       change = true;
            //     });
            //   }
            // }
            // else {
            //   setState(() {
            //     currentLessonIndex = -1;
            //     change = true;
            //   });
            // }
          });
        });
      // }
  });}

  Widget _BottomNavyBar(){
    return BottomNavyBar(selectedIndex: _selectedIndex,
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
        ]);
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
                SizedBox(height: 20), // Отступ между изображением и текстом
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

                // ElevatedButton(
        //   onPressed: () {
        //     // Ваша функция, которая будет выполняться при нажатии на кнопку
        //     print('Кнопка нажата!');
        //   },
        //   style: ButtonStyle(
        //     backgroundColor: MaterialStateProperty.all(Colors.black), // Убираем стандартный фон кнопкиУбираем тень кнопки
        //   ),
        //   child: Text(
        //     'Моя кнопка',
        //     style: TextStyle(
        //       color: Colors.white,
        //       fontWeight: FontWeight.bold,
        //     ),
        //   )),
            ])),

            // Center(
            // child: Container(alignment: Alignment.center,
            //   child: randomImageIndex != 0 ?
            //       Image.asset(
            //         "assets/finish_gifs/$randomImageIndex.gif",
            //         width: 200,
            //         height: 200,
            //       ) : CircularProgressIndicator(),
            // )),

          SizedBox(height: 15,),
          // Center(
          //     child: Container(alignment: Alignment.center,
          //         child: Text('Карточки закончились', style: TextStyle(fontSize: 24.0),))),

        ]));
  }

  @override
  Widget build(BuildContext context) {
    print('Наш индекс');
    print(currentLessonIndex);
    if (change == false)
      return Container(
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator(),
        ));

    else return
      currentLessonIndex != -1 ? widget.lessonItem.tasks[currentLessonIndex][3] : finishScreen();

  }

}
