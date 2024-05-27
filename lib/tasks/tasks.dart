import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:dyslexia_project/services/snack_bar.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dyslexia_project/screens/reading_section.dart';
import 'package:dyslexia_project/tasks/tasks_data.dart';
import 'package:dyslexia_project/screens/home_screen.dart';
import 'package:dyslexia_project/screens/account_screen.dart';
import 'package:dyslexia_project/tasks/product_model.dart';
import 'package:dyslexia_project/services/database.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:dyslexia_project/screens/lessons.dart';

final parsedJson = jsonDecode(jsonData);

class CategoryList extends StatelessWidget {
  const CategoryList({super.key,});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        padding: EdgeInsets.only(top: 14),
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 0.85),
        itemBuilder: (context, index) => CategoryCard(
          product: products[index],
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => Detail(product: products[index])),
            );},));
  }
}
class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key,
    required this.product,
    required this.onTap,
    this.selected = false
  });
  final Product product;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: InkWell(
          onTap: () {
            onTap();
          }, child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              color: product.color, borderRadius: BorderRadius.circular(15.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              Text(product.title,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),

              Expanded(
                  child:
                  Image.asset(
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: MediaQuery.of(context).size.height * 0.25,
                    product.icon,
                    fit: BoxFit.contain,
                  )
              ),

              // Text("Сделано ${product.courses} из ${product.courses}",
              //   style: const TextStyle(
              //     fontSize: 15,
              //     color: Colors.white,
              //   ),
              // ),

              // const SizedBox(
              //   height: 10,
              // ),

            ],
          ),),));
  }
}

class Detail extends StatefulWidget {
  final Product product;
  Detail({super.key, required this.product});
  @override
  State<Detail> createState() => _DetailState();
}
class _DetailState extends State<Detail> {
  var product = products[0];
  int _selectedIndex = 0;
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

  @override
  void initState() {
    super.initState();
    product = widget.product;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavyBar(
          selectedIndex: _selectedIndex,
          showElevation: true,
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

        body: Container(
                  child: product.classname
              ));
  }}

typedef GameUpdateCallback = void Function();

class HearTask extends StatefulWidget {
  final String? TaskType;
  final String? TaskName;
  final String? TaskDifficulty;
  final String flag;
  final List? lessonInfo;
  Function? onGameUpdate;
  final back_func;
  final givenIndex;

  HearTask({Key? key, this.TaskType, this.TaskName, this.TaskDifficulty, required this.flag, this.lessonInfo, this.onGameUpdate, this.back_func, this.givenIndex}) : super(key: key);

  @override
  State<HearTask> createState() => _HearTask();
}

class _HearTask extends State<HearTask> {
  FlutterTts flutterTts = FlutterTts();

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("ru-RU");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  String chosenWord = '';
  String rightWord = '';
  String name = '';
  List options = [];
  bool isCorrect = false;
  int pairs = 0;
  bool done = false;
  Color font_color = Colors.black;
  var randomNumber;
  Map info = {};
  var randomImageIndex = 0;
  bool change = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      randomImageIndex = Random().nextInt(6) + 1;
    });
    if (widget.givenIndex == null) {
      FirestoreService().chooseRandomNumber4(
          UserInfo(), parsedJson, widget.TaskType,
          widget.flag == 'lesson' ? 'lesson' : 'no').then((value) {
        setState(() {
          randomNumber = value;
          print(value);
          if (randomNumber != -1) {
            info = parsedJson[widget.TaskType][widget.TaskName][widget
                .TaskDifficulty][randomNumber.toString()];
            print(info);
            name = info['name'];
            rightWord = info['letter'];
            options = info['options'];
          };
        });
      }).then((value) {
        setState(() {
          change = true;
        });
      });
    }
    else {
      setState(() {
        randomNumber = widget.givenIndex;
        print(randomNumber);
        if (randomNumber != -1) {
          info = parsedJson[widget.TaskType][widget.TaskName][widget
              .TaskDifficulty][randomNumber.toString()];
          print(info);
          name = info['name'];
          rightWord = info['letter'];
          options = info['options'];
          change = true;
        };
      });
    }
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

  UserInfo() {
    Map userInfo = getUserId();
    String userId = userInfo['userId']!;
    String email = userInfo['email']!;

    UserTask3 user_task = UserTask3(
      userId: userId,
      email: email,
      taskName: widget.TaskName!,
      taskDifficulty: widget.TaskDifficulty!,
      taskNumber: randomNumber,
      date: DateTime.now(),
      correct_answer: isCorrect,
      wrong_answer: !isCorrect,
    );
    return user_task;
  }

  checkAnswer(String selectedAnswer) {
    setState(() {
      if (selectedAnswer == rightWord) {
        playSound('sounds/right.wav');
        isCorrect = true;
      } else {
        playSound('sounds/wrong.mp3');
        isCorrect = false;
      }
      chosenWord = selectedAnswer;
    });
  }

  void playSound(sound) {
    final player = AudioPlayer();
    player!.play(AssetSource(sound));
  }

  Widget finishScreen() {
    return Scaffold(body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/finish_back.png", fit: BoxFit.cover,),
          Positioned(top: 50, left: 15, child: IconButton(icon: Icon(Icons.arrow_back),
              onPressed: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => widget.back_func),)
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
                    Text('Все задания выполнены. Вы огромный молодец!', textAlign: TextAlign.center, style:
                    TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color(0xff286419)),),
                    SizedBox(height: 40),
                    TextButton(
                      style: ButtonStyle(
                        // minimumSize: MaterialStateProperty.all(Size(90, 50)), //
                        backgroundColor: MaterialStateProperty.all(Colors.green),
                      ),
                      onPressed: () {
                        FirestoreService().TaskDeleteInfo(
                            getUserId(), widget.TaskType,
                            widget.TaskName, widget.TaskDifficulty);

                        if (widget.onGameUpdate != null) {
                          widget.onGameUpdate!();
                        }
                      },

                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => HearTask(flag: 'no', back_func: widget.back_func,)),);
                        // },

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

  Widget buildOptionButton(String option) {
    Color buttonColor = chosenWord == option
        ? (isCorrect ? Colors.green : Colors.red)
        : Colors.white;
    return ElevatedButton(
      onPressed: !isCorrect ? () {
        checkAnswer(option);
        FirestoreService().GameUpdate2(
            UserInfo(), widget.TaskType, widget.flag == 'lesson' ? 'lesson' : 'no');
      } : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey),
        ),
        elevation: 5,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          option,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double panelHeight = MediaQuery.of(context).size.height * 0.14;
    if (change == false) {
        return Container(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ));
    }
    else if (info != null && info.length > 0 && randomNumber != -1 )
    {
      return Scaffold(
          body: Stack(
              fit: StackFit.expand,
              children: [

                Image.asset(
                  "assets/images/match_back.png",
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

                Padding(
                    padding: EdgeInsets.only(top: 90.0),
                    child:
                    Column(children: [
                      Expanded(child:
                      ListView(children: [

                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(color: Colors.white,
                                width: 300, child: Text(name, textAlign: TextAlign.center,
                                  softWrap: true, style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),))),

                        SizedBox(height: 80.0),

                        IconButton(
                          icon: Icon(Icons.volume_up),
                          iconSize: 48,
                          onPressed: () {
                            speak(rightWord.toLowerCase());
                          },
                        ),

                        SizedBox(height: 50.0),

                        if (options.length == 2)

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildOptionButton(options[0]),
                            SizedBox(width: 20),
                            buildOptionButton(options[1]),
                          ],
                        ),

                        SizedBox(height: 20),

                        if (options.length == 3)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildOptionButton(options[0]),
                            SizedBox(width: 4),
                            buildOptionButton(options[1]),
                            SizedBox(width: 4),
                            buildOptionButton(options[2]),
                          ],
                        ),

                        if (options.length == 4)
                          Column(
                          children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildOptionButton(options[0]),
                              SizedBox(width: 20),
                              buildOptionButton(options[1]),
                            ],
                          ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildOptionButton(options[2]),
                            SizedBox(width: 20),
                            buildOptionButton(options[3]),
                          ],
                        ),]),

                      ]))
                    ])),

                if (chosenWord != null && chosenWord == rightWord)
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          height: panelHeight,
                          width: double.infinity,
                          color: Color(0xffCCFFA4),
                          child: Center(
                            child: ElevatedButton(
                                onPressed: () {
                                  done = true;
                                  // widget.onDoneChanged(done);

                                  if (widget.flag == 'lesson') {
                                    FirestoreService().LessonsStatUpdate(
                                        getUserId(), widget.lessonInfo,
                                        widget.TaskType, widget.TaskName, widget.TaskDifficulty,
                                        randomNumber).then((value) {
                                      if (widget.onGameUpdate != null) {
                                        widget.onGameUpdate!();
                                      }
                                    });
                                  }
                                  else {
                                    FirestoreService().GameUpdate2(
                                        UserInfo(), widget.TaskType,
                                        widget.flag == 'lesson'
                                            ? 'lesson'
                                            : 'no').then((value) {
                                      if (widget.onGameUpdate != null) {
                                        widget.onGameUpdate!();
                                      }
                                    });
                                  }

                                },
                                child: Text('Дальше',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(
                                        0xff36FF24), // Укажите цвет текста здесь
                                  ),
                                ),
                                style:
                                ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0),
                                      bottomLeft: Radius.circular(10.0),
                                      bottomRight: Radius.circular(10.0),
                                    ),
                                  ),
                                  backgroundColor: Colors.white,
                                )

                            ),))),

              ]));
    }
    else if (randomNumber == -1 && widget.flag != 'lesson'){
      return finishScreen();
  }
    else {
      return Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          ));
    }
}
}

class HearWriteTask extends StatefulWidget {
  final String TaskType;
  final String TaskName;
  final String? TaskDifficulty;
  final String flag;
  final List? lessonInfo;
  Function? onGameUpdate;
  final back_func;

  HearWriteTask({Key? key, required this.TaskType, required this.TaskName, this.TaskDifficulty, required this.flag, this.lessonInfo, this.onGameUpdate, this.back_func}) : super(key: key);

  @override
  State<HearWriteTask> createState() => _HearWriteTask();
}

class _HearWriteTask extends State<HearWriteTask> {
  FlutterTts flutterTts = FlutterTts();

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("ru-RU");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  String writtenWord = '';
  String answer = '';
  String name = '';
  String task = '';
  bool isCorrect = false;
  Color font_color = Colors.black;
  var randomNumber;
  Map info = {};
  var done = false;
  bool ready = false;


  Random random = Random();
  var randomImageIndex = 0;
  List<String> levels = ['easy', 'middle', 'high'];
  // final index = Random().nextInt(['easy', 'middle', 'high'].length);
  var index = 0;
  String level = '';

  @override
  void initState() {
    super.initState();
    // index = random.nextInt(levels.length);
    setState(() {
      randomImageIndex = Random().nextInt(6) + 1;
      index = Random().nextInt(['easy', 'middle', 'high'].length);
      level = widget.TaskDifficulty == null ? levels[index] : widget.TaskDifficulty!;
    });

    FirestoreService().chooseRandomNumber4(
          UserInfo(), parsedJson, widget.TaskType,
          widget.flag == 'lesson' ? 'lesson' : 'no').then((value) {
        setState(() {
          // index = value;
          randomNumber = value;
          print(level);
          if (randomNumber != -1) {
            info = parsedJson[widget.TaskType][widget.TaskName][widget
                .TaskDifficulty == null ? levels[index] : widget
                .TaskDifficulty][randomNumber.toString()];
            print(info);
            name = info['name'];
            task = info['task'];
            answer = info['answer'];
          };
        });
      }).then((value) {
      setState(() {
        ready = true;
      });
    });;

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

  UserInfo() {
    Map userInfo = getUserId();
    String userId = userInfo['userId']!;
    String email = userInfo['email']!;

    UserTask3 user_task = UserTask3(
      userId: userId,
      email: email,
      taskName: widget.TaskName,
      taskDifficulty: level,
      taskNumber: randomNumber,
      date: DateTime.now(),
      correct_answer: isCorrect,
      wrong_answer: !isCorrect,
    );
    return user_task;
  }

  checkAnswer(String userWord) {
    setState(() {
      if (userWord.toLowerCase() == answer) {
        playSound('sounds/right.wav');
        isCorrect = true;
      } else {
        playSound('sounds/wrong.mp3');
        isCorrect = false;
        SnackBarService.showSnackBar(context,'Неверно, попробуйте ещё раз',
          true,
        );
      }
      writtenWord = userWord;
    });
  }

  void playSound(sound) {
    final player = AudioPlayer();
    player!.play(AssetSource(sound));
  }

  Widget finishScreen() {
    return Scaffold(body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/finish_back.png", fit: BoxFit.cover,),
          Positioned(top: 50, left: 15, child: IconButton(icon: Icon(Icons.arrow_back),
              onPressed: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => widget.back_func),)
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
                    Text('Все задания выполнены. Вы огромный молодец!', textAlign: TextAlign.center, style:
                    TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color(0xff286419)),),
                    SizedBox(height: 40),
                    TextButton(
                      style: ButtonStyle(
                        // minimumSize: MaterialStateProperty.all(Size(90, 50)), //
                        backgroundColor: MaterialStateProperty.all(Colors.green),
                      ),
                      onPressed: () {
                        FirestoreService().TaskDeleteInfo(
                            getUserId(), widget.TaskType,
                            widget.TaskName, widget.TaskDifficulty);

                        if (widget.onGameUpdate != null) {
                          widget.onGameUpdate!();
                        }
                      },

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => HearTask(flag: 'no', back_func: widget.back_func,)),);
                      // },

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

  @override
  Widget build(BuildContext context) {
    double panelHeight = MediaQuery.of(context).size.height * 0.14;
    if (ready == false)
      return Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          ));

    else if (info != null && info.length > 0 && randomNumber != -1)
    {
      return Scaffold(
          body: Stack(
              fit: StackFit.expand,
              children: [

                Image.asset(
                  "assets/images/match_back.png",
                  fit: BoxFit.cover,
                ),

                Positioned(
                    top: 50,
                    left: 15,
                    child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () =>  widget.back_func != null ? Navigator.push(context,MaterialPageRoute(builder: (context) => widget.back_func),)
                            : Navigator.push(context,MaterialPageRoute(builder: (context) => HomeScreen()),)
                    )
                ),


                Padding(
                    padding: EdgeInsets.only(top: 90.0),
                    child:
                    Column(children: [
                      Expanded(child:
                      ListView(children: [


                        SizedBox(height: 20.0),

                        Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Container(color: Colors.white,
                                      width: 300, child: Text(name, softWrap: true, style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),))),

                                  SizedBox(height: 15),

                                  IconButton(
                                    icon: Icon(Icons.volume_up),
                                    iconSize: 48,
                                    onPressed: () {
                                      speak(answer.toLowerCase());
                                      },
                                  ),
                                  SizedBox(height: 15),
                                  Text(task, style: TextStyle(fontSize: 16.0,)),
                                  SizedBox(height: 35),

                                  Container(
                                      width: 300, // Желаемая ширина
                                      child:
                                  TextField(
                                    onChanged: (value) {
                                      writtenWord = value.trim();
                                      },
                                    decoration: InputDecoration(
                                      hintText: 'Введите слово целиком',
                                      border: OutlineInputBorder(),
                                      // contentPadding: EdgeInsets.symmetric(vertical: 20),
                                    ),
                                  )),

                                  SizedBox(height: 40),

                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        done = true;
                                        checkAnswer(writtenWord);
                                      });
                                    },
                                    child: Text('Проверить',
                                      style: TextStyle(
                                        color: Colors.white, // Цвет текста
                                        fontSize: 16, // Размер шрифта
                                      ),
                                    ),
                                  ),

                                ]))
                      ])
                      )])),

                if (writtenWord != null && done == true && writtenWord.toLowerCase() == answer)
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          height: panelHeight,
                          width: double.infinity,
                          color: Color(0xffCCFFA4),
                          child: Center(
                            child: ElevatedButton(
                                onPressed: () {
                                  // done = true;

                                  if (widget.flag == 'lesson') {
                                    print('sta ${widget.lessonInfo}');
                                    FirestoreService().LessonsStatUpdate(
                                        getUserId(), widget.lessonInfo,
                                        widget.TaskType, widget.TaskName, widget.TaskDifficulty,
                                        randomNumber).then((value) {
                                      if (widget.onGameUpdate != null) {
                                        widget.onGameUpdate!();
                                      }
                                    });
                                  }
                                  else {
                                    FirestoreService().GameUpdate2(
                                        UserInfo(), widget.TaskType,
                                        widget.flag == 'lesson'
                                            ? 'lesson'
                                            : 'no').then((value) {
                                      if (widget.onGameUpdate != null) {
                                        widget.onGameUpdate!();
                                      }
                                    });
                                  }
                                  // whenComplete(() => Navigator.pushReplacement(context,
                                  //       MaterialPageRoute(builder: (context) =>
                                  //         Detail(product: products[0])),
                                  //   ));
                                },
                                child: Text('Дальше',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(
                                        0xff36FF24), // Укажите цвет текста здесь
                                  ),
                                ),
                                style:
                                ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0),
                                      bottomLeft: Radius.circular(10.0),
                                      bottomRight: Radius.circular(10.0),
                                    ),
                                  ),
                                  backgroundColor: Colors.white,
                                )

                            ),))),
                  ]));
    }
    else if (randomNumber == -1 && widget.flag != 'lesson'){
      return finishScreen();
    }
    else {
      return Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          ));
    }
  }
}

class WriteTask extends StatefulWidget {
  final String? TaskType;
  final String TaskName;
  final String? TaskDifficulty;
  final String flag;
  final List? lessonInfo;
  Function? onGameUpdate;
  final back_func;
  final givenIndex;

  WriteTask({Key? key, this.TaskType, required this.TaskName, this.TaskDifficulty, required this.flag, this.lessonInfo, this.onGameUpdate, this.back_func, this.givenIndex}) : super(key: key);

  @override
  State<WriteTask> createState() => _WriteTask();
}

class _WriteTask extends State<WriteTask> {
  FlutterTts flutterTts = FlutterTts();

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("ru-RU");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  String writtenWord = '';
  var answer;
  String name = '';
  var words;
  bool isCorrect = false;
  Color font_color = Colors.black;
  var randomNumber;
  Map info = {};
  var done = false;
  bool ready = false;

  Random random = Random();
  var randomImageIndex = 0;
  List<String> levels = ['easy', 'middle', 'high'];
  var index = 0;
  String level = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      randomImageIndex = Random().nextInt(6) + 1;
      index = Random().nextInt(['easy', 'middle', 'high'].length);
      level = widget.TaskDifficulty == null ? levels[index] : widget.TaskDifficulty!;
    });

    FirestoreService().chooseRandomNumber4(
        UserInfo(), parsedJson, widget.TaskType,
        widget.flag == 'lesson' ? 'lesson' : 'no').then((value) {
      setState(() {
        randomNumber = value;
        print(level);
        if (randomNumber != -1) {
          info = parsedJson[widget.TaskType][widget.TaskName][widget
              .TaskDifficulty == null ? levels[index] : widget
              .TaskDifficulty][randomNumber.toString()];
          print(info);
          if (widget.TaskName  == '3_word_for_word') {
            name = info['name'];
            words = info['task'];
            answer = info['answer'];
          }
          else if (widget.TaskName  == '6_delete_letters') {
            name = info['name'];
            words = info['task'];
            answer = info['answer'];
          }
          else if (widget.TaskName  == '1_emoji') {
            name = info['name'];
            words = info['task'];
            answer = info['answer'];
            print(words);
          }
          else if (widget.TaskName  == '2_images') {
            name = info['name'];
            words = info['task'];
            answer = info['answer'];
          }
          else {
            name = info['name'];
            words = info['words'];
            answer = info['answer'];
          }
        };
      });
    }).then((value) {
      setState(() {
        ready = true;
      });
    });;

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

  UserInfo() {
    Map userInfo = getUserId();
    String userId = userInfo['userId']!;
    String email = userInfo['email']!;

    UserTask3 user_task = UserTask3(
      userId: userId,
      email: email,
      taskName: widget.TaskName,
      taskDifficulty: level,
      taskNumber: randomNumber,
      date: DateTime.now(),
      correct_answer: isCorrect,
      wrong_answer: !isCorrect,
    );
    return user_task;
  }

  String replaceEwithYo(String word) {
    return word.replaceAll('ё', 'е');
  }

  checkAnswer(String userWord) {
    setState(() {
      if (widget.TaskName == '2_images') {
        userWord = replaceEwithYo(userWord);
      }
      if (widget.TaskName == '3_word_for_word') {
        if (answer.length == 2) {
          if (writtenWord.split(',')[0].replaceAll(' ', '').toLowerCase() == answer[0]
              && writtenWord.split(',')[1].replaceAll(' ', '').toLowerCase() == answer[1]) {
            playSound('sounds/right.wav');
            isCorrect = true;
          }
          else {
            playSound('sounds/wrong.mp3');
            isCorrect = false;
            SnackBarService.showSnackBar(context,'Неверно, попробуйте ещё раз', true,);
          }
          writtenWord = userWord;
        }
        else if (answer.length == 3) {
          if (writtenWord.split(',')[0].replaceAll(' ', '').toLowerCase() == answer[0]
              && writtenWord.split(',')[1].replaceAll(' ', '').toLowerCase() == answer[1]
              && writtenWord.split(',')[2].replaceAll(' ', '').toLowerCase() == answer[2]) {
            playSound('sounds/right.wav');
            isCorrect = true;
          }
          else {
            playSound('sounds/wrong.mp3');
            isCorrect = false;
            SnackBarService.showSnackBar(context,'Неверно, попробуйте ещё раз', true,);
          }
        }
        writtenWord = userWord;
      }
      else {
        if (userWord.toLowerCase() == answer) {
          playSound('sounds/right.wav');
          isCorrect = true;
        } else {
          playSound('sounds/wrong.mp3');
          isCorrect = false;
          SnackBarService.showSnackBar(context,'Неверно, попробуйте ещё раз',
            true,
          );
        }
        writtenWord = userWord;
      }
    });
  }

  void playSound(sound) {
    final player = AudioPlayer();
    player!.play(AssetSource(sound));
  }

  Widget finishScreen() {
    return Scaffold(body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/finish_back.png", fit: BoxFit.cover,),
          Positioned(top: 50, left: 15, child: IconButton(icon: Icon(Icons.arrow_back),
              onPressed: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => widget.back_func),)
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
                    Text('Все задания выполнены. Вы огромный молодец!', textAlign: TextAlign.center, style:
                    TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color(0xff286419)),),
                    SizedBox(height: 40),
                    TextButton(
                      style: ButtonStyle(
                        // minimumSize: MaterialStateProperty.all(Size(90, 50)), //
                        backgroundColor: MaterialStateProperty.all(Colors.green),
                      ),
                      onPressed: () {
                        FirestoreService().TaskDeleteInfo(
                            getUserId(), widget.TaskType,
                            widget.TaskName, widget.TaskDifficulty);

                        if (widget.onGameUpdate != null) {
                          widget.onGameUpdate!();
                        }
                      },

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => HearTask(flag: 'no', back_func: widget.back_func,)),);
                      // },

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

  @override
  Widget build(BuildContext context) {
    double panelHeight = MediaQuery.of(context).size.height * 0.14;
    if (ready == false)
      return Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          ));

    else if (widget.TaskName == '3_word_for_word') {
      return Scaffold(
          body: Stack(
              fit: StackFit.expand,
              children: [

                Image.asset(
                  "assets/images/agrammatism_back.png",
                  fit: BoxFit.cover,
                ),

                Positioned(
                    top: 50,
                    left: 15,
                    child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () =>  widget.back_func != null ? Navigator.push(context,MaterialPageRoute(builder: (context) => widget.back_func),)
                            : Navigator.push(context,MaterialPageRoute(builder: (context) => HomeScreen()),)
                    )
                ),


                Padding(
                    padding: EdgeInsets.only(top: 90.0),
                    child:
                    Column(children: [
                      Expanded(child:
                      ListView(children: [

                        SizedBox(height: 20.0),

                        Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Container(color: Colors.white,
                                          width: 300, child: Text(name, softWrap: true,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                            ),))),

                                  Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Container(
                                        // color: Colors.white,
                                          width: 300, child: Text('Запишите найденные слова, разделяя их запятой',
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13.0,
                                          // fontWeight: FontWeight.bold,
                                        ),))),

                                  SizedBox(height: 40),

                                  Text(words, style: TextStyle(fontSize: 16.0,)),

                                  SizedBox(height: 35),

                                  Container(
                                      width: 300,
                                      child: TextField(
                                        onChanged: (value) {
                                          writtenWord = value.trim();
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Введите два получившихся слова, разделите их запятой (без пробела)',
                                          border: OutlineInputBorder(),
                                          // contentPadding: EdgeInsets.symmetric(vertical: 20),
                                        ),
                                      )),

                                  SizedBox(height: 40),

                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xffFF9C8E)),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        done = true;
                                        checkAnswer(writtenWord);
                                      });
                                    },
                                    child: Text('Проверить',
                                      style: TextStyle(
                                        color: Colors.white, // Цвет текста
                                        fontSize: 16, // Размер шрифта
                                      ),
                                    ),
                                  ),

                                ]))
                      ])
                      )])),

                if (answer.length == 2)
                  if (writtenWord != null && done == true && writtenWord.split(',')[0].replaceAll(' ', '').toLowerCase() == answer[0]
                      && writtenWord.split(',')[1].replaceAll(' ', '').toLowerCase() == answer[1])
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                            height: panelHeight,
                            width: double.infinity,
                            color: Color(0xffCCFFA4),
                            child: Center(
                              child: ElevatedButton(
                                  onPressed: () {
                                    // done = true;
                                    if (widget.flag == 'lesson') {
                                      FirestoreService().LessonsStatUpdate(
                                          getUserId(), widget.lessonInfo,
                                          widget.TaskType, widget.TaskName, widget.TaskDifficulty,
                                          randomNumber).then((value) {
                                        if (widget.onGameUpdate != null) {
                                          widget.onGameUpdate!();
                                        }
                                      });
                                    }
                                    else {
                                      FirestoreService().GameUpdate2(
                                          UserInfo(), widget.TaskType,
                                          widget.flag == 'lesson'
                                              ? 'lesson'
                                              : 'no').then((value) {
                                        if (widget.onGameUpdate != null) {
                                          widget.onGameUpdate!();
                                        }
                                      });
                                    }
                                    // whenComplete(() => Navigator.pushReplacement(context,
                                    //       MaterialPageRoute(builder: (context) =>
                                    //         Detail(product: products[0])),
                                    //   ));
                                  },
                                  child: Text('Дальше',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color(
                                          0xff36FF24), // Укажите цвет текста здесь
                                    ),
                                  ),
                                  style:
                                  ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10.0),
                                        topRight: Radius.circular(10.0),
                                        bottomLeft: Radius.circular(10.0),
                                        bottomRight: Radius.circular(10.0),
                                      ),
                                    ),
                                    backgroundColor: Colors.white,
                                  )

                              ),))),

                if (answer.length == 3)
                  if (writtenWord != null && done == true && writtenWord.split(',')[0].toLowerCase() == answer[0]
                      && writtenWord.split(',')[1].toLowerCase() == answer[1] && writtenWord.split(',')[2].toLowerCase() == answer[2])
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                            height: panelHeight,
                            width: double.infinity,
                            color: Color(0xffCCFFA4),
                            child: Center(
                              child: ElevatedButton(
                                  onPressed: () {
                                    // done = true;
                                    if (widget.flag == 'lesson') {
                                      FirestoreService().LessonsStatUpdate(
                                          getUserId(), widget.lessonInfo,
                                          widget.TaskType, widget.TaskName, widget.TaskDifficulty,
                                          randomNumber).then((value) {
                                        if (widget.onGameUpdate != null) {
                                          widget.onGameUpdate!();
                                        }
                                      });
                                    }
                                    else {
                                      FirestoreService().GameUpdate2(
                                          UserInfo(), widget.TaskType,
                                          widget.flag == 'lesson'
                                              ? 'lesson'
                                              : 'no').then((value) {
                                        if (widget.onGameUpdate != null) {
                                          widget.onGameUpdate!();
                                        }
                                      });
                                    }
                                    // whenComplete(() => Navigator.pushReplacement(context,
                                    //       MaterialPageRoute(builder: (context) =>
                                    //         Detail(product: products[0])),
                                    //   ));
                                  },
                                  child: Text('Дальше',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color(
                                          0xff36FF24), // Укажите цвет текста здесь
                                    ),
                                  ),
                                  style:
                                  ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10.0),
                                        topRight: Radius.circular(10.0),
                                        bottomLeft: Radius.circular(10.0),
                                        bottomRight: Radius.circular(10.0),
                                      ),
                                    ),
                                    backgroundColor: Colors.white,
                                  )

                              ),))),



              ]));
    }

    else if (info != null && info.length > 0 && randomNumber != -1)
    {
      return Scaffold(
          body: Stack(
              fit: StackFit.expand,
              children: [

                Image.asset(
                  "assets/images/${widget.TaskType}_back.png",
                  fit: BoxFit.cover,
                ),

                Positioned(
                    top: 50,
                    left: 15,
                    child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () =>  widget.back_func != null ? Navigator.push(context,MaterialPageRoute(builder: (context) => widget.back_func),)
                            : Navigator.push(context,MaterialPageRoute(builder: (context) => HomeScreen()),)
                    )
                ),


                Padding(
                    padding: EdgeInsets.only(top: 90.0),
                    child:
                    Column(children: [
                      Expanded(child:
                      ListView(children: [

                        SizedBox(height: 20.0),

                        Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Container(color: Colors.white,
                                          width: 300, child: Text(name, softWrap: true,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                            ),))),

                                  SizedBox(height: 35),

                                  if (widget.TaskName == '1_emoji')
                                    SizedBox(height: 10),

                                  if (widget.TaskName == '6_delete_letters')
                                    Text(words,  style: TextStyle(fontSize: 16.0,)),
                                  if (widget.TaskName == '1_emoji' || widget.TaskName == '2_images')
                                    Text(words,  style: TextStyle(fontSize: 24.0,)),
                                  if (words.length == 2  && words is List)
                                    Text('${words[0]} + ${words[1]}', style: TextStyle(fontSize: 16.0,)),
                                  if (words.length == 3 && words is List)
                                    Text('${words[0]} + ${words[1]} + ${words[2]}', style: TextStyle(fontSize: 16.0,)),
                                  if (words.length == 4 && words is List)
                                    Text('${words[0]} + ${words[1]} + ${words[2]} + ${words[3]}', style: TextStyle(fontSize: 16.0,)),

                                  if (widget.TaskName == '1_emoji')
                                    SizedBox(height: 45),


                                  SizedBox(height: 25),

                                  if (widget.TaskName == '2_images')
                                    Column(children:
                                    [
                                      // if (answer == 'чертёж')
                                      Image.asset("assets/for_task/$answer.png",
                                        width: 200,
                                        height: 200,
                                      ),
                                      SizedBox(height: 45),
                                    ]),

                                  Container(
                                      width: 300,
                                      child: TextField(
                                        onChanged: (value) {
                                          writtenWord = value.trim();
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Введите слово целиком',
                                          border: OutlineInputBorder(),
                                          // contentPadding: EdgeInsets.symmetric(vertical: 20),
                                        ),
                                      )),

                                  SizedBox(height: 30),

                                  if (widget.TaskName == '1_emoji')
                                    SizedBox(height: 20),

                                  ElevatedButton(
                                    style: ButtonStyle(
                                      fixedSize: MaterialStateProperty.all(Size(200, 50)),
                                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xffFF9C8E)),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        done = true;
                                        checkAnswer(writtenWord);
                                      });
                                    },
                                    child: Text('Проверить',
                                      style: TextStyle(
                                        color: Colors.white, fontSize: 20,),
                                    ),
                                  ),

                                ]))
                      ])
                      )])),

                if (writtenWord != null && done == true && writtenWord.toLowerCase() == answer)
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          height: panelHeight,
                          width: double.infinity,
                          color: Color(0xffCCFFA4),
                          child: Center(
                            child: ElevatedButton(
                                onPressed: () {
                                  // done = true;
                                  if (widget.flag == 'lesson') {
                                    FirestoreService().LessonsStatUpdate(
                                        getUserId(), widget.lessonInfo,
                                        widget.TaskType, widget.TaskName, widget.TaskDifficulty,
                                        randomNumber).then((value) {
                                      if (widget.onGameUpdate != null) {
                                        widget.onGameUpdate!();
                                      }
                                    });
                                  }
                                  else {
                                    FirestoreService().GameUpdate2(
                                        UserInfo(), widget.TaskType,
                                        widget.flag == 'lesson'
                                            ? 'lesson'
                                            : 'no').then((value) {
                                      if (widget.onGameUpdate != null) {
                                        widget.onGameUpdate!();
                                      }
                                    });
                                  }
                                  // whenComplete(() => Navigator.pushReplacement(context,
                                  //       MaterialPageRoute(builder: (context) =>
                                  //         Detail(product: products[0])),
                                  //   ));
                                },
                                child: Text('Дальше',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(
                                        0xff36FF24), // Укажите цвет текста здесь
                                  ),
                                ),
                                style:
                                ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0),
                                      bottomLeft: Radius.circular(10.0),
                                      bottomRight: Radius.circular(10.0),
                                    ),
                                  ),
                                  backgroundColor: Colors.white,
                                )

                            ),))),
              ]));
    }
    else if (randomNumber == -1 && widget.flag != 'lesson'){
      return finishScreen();
    }
    else {
      return Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          ));
    }
  }
}

class ChooseTask extends StatefulWidget {
  final String? TaskType;
  final String TaskName;
  final String? TaskDifficulty;
  final String flag;
  final List? lessonInfo;
  Function? onGameUpdate;
  final back_func;
  final givenIndex;

  ChooseTask({Key? key, this.TaskType, required this.TaskName, this.TaskDifficulty, required this.flag, this.lessonInfo, this.onGameUpdate, this.back_func, this.givenIndex}) : super(key: key);

  @override
  State<ChooseTask> createState() => _ChooseTask();
}

class _ChooseTask extends State<ChooseTask> {
  FlutterTts flutterTts = FlutterTts();

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("ru-RU");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  String question = '';
  List options = [];
  bool answered = false;
  String correctAnswer = '';
  String chosenWord = '';
  bool isCorrect = false;
  var randomNumber;
  Map info = {};

  // String writtenWord = '';
  var answer;
  String name = '';
  var words;
  Color font_color = Colors.black;
  var done = false;
  bool ready = false;

  Random random = Random();
  var randomImageIndex = 0;
  List<String> levels = ['easy', 'middle', 'high'];
  var index = 0;
  String level = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      randomImageIndex = Random().nextInt(6) + 1;
      index = Random().nextInt(['easy', 'middle', 'high'].length);
      level = widget.TaskDifficulty == null ? levels[index] : widget.TaskDifficulty!;
    });

    FirestoreService().chooseRandomNumber4(
        UserInfo(), parsedJson, widget.TaskType,
        widget.flag == 'lesson' ? 'lesson' : 'no').then((value) {
      setState(() {
        randomNumber = value;
        if (randomNumber != -1) {
          info = parsedJson[widget.TaskType][widget.TaskName][widget
              .TaskDifficulty == null ? levels[index] : widget
              .TaskDifficulty][randomNumber.toString()];
          print(info);
          if (widget.TaskName  == '3_word_for_word') {
            name = info['name'];
            options = info['options'];
            answer = info['answer'];
          }
          // else if (widget.TaskName  == '6_delete_letters') {
          //   name = info['name'];
          //   words = info['task'];
          //   answer = info['answer'];
          // }
          else {
            name = info['name'];
            options = info['options'];
            print(options.length);
            print('а');
            answer = info['answer'][0];
          }
        };
      });
    }).then((value) {
      setState(() {
        ready = true;
      });
    });;

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

  UserInfo() {
    Map userInfo = getUserId();
    String userId = userInfo['userId']!;
    String email = userInfo['email']!;

    UserTask3 user_task = UserTask3(
      userId: userId,
      email: email,
      taskName: widget.TaskName,
      taskDifficulty: level,
      taskNumber: randomNumber,
      date: DateTime.now(),
      correct_answer: isCorrect,
      wrong_answer: !isCorrect,
    );
    return user_task;
  }

  checkAnswer(String userWord) {
    setState(() {
      done = true;
      // if (widget.TaskName == '3_word_for_word') {
      //   if (answer.length == 2) {
      //     if (writtenWord.split(',')[0].toLowerCase() == answer[0]
      //         && writtenWord.split(',')[1].toLowerCase() == answer[1]) {
      //       playSound('sounds/right.wav');
      //       isCorrect = true;
      //     }
      //     else {
      //       playSound('sounds/wrong.mp3');
      //       isCorrect = false;
      //       SnackBarService.showSnackBar(context,'Неверно, попробуйте ещё раз', true,);
      //     }
      //     writtenWord = userWord;
      //   }
      //   else if (answer.length == 3) {
      //     if (writtenWord.split(',')[0].toLowerCase() == answer[0]
      //         && writtenWord.split(',')[1].toLowerCase() == answer[1]
      //         && writtenWord.split(',')[2].toLowerCase() == answer[2]) {
      //       playSound('sounds/right.wav');
      //       isCorrect = true;
      //     }
      //     else {
      //       playSound('sounds/wrong.mp3');
      //       isCorrect = false;
      //       SnackBarService.showSnackBar(context,'Неверно, попробуйте ещё раз', true,);
      //     }
      //   }
      //   chosenWord = userWord;
      // }

      print(answer);
      if (userWord == answer) {
        playSound('sounds/right.wav');
        isCorrect = true;
      } else {
        playSound('sounds/wrong.mp3');
        isCorrect = false;
        SnackBarService.showSnackBar(context,'Неверно, попробуйте ещё раз',
          true,
        );
      }
      chosenWord = userWord;

    });
  }

  void playSound(sound) {
    final player = AudioPlayer();
    player!.play(AssetSource(sound));
  }

  Widget finishScreen() {
    return Scaffold(body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/finish_back.png", fit: BoxFit.cover,),
          Positioned(top: 50, left: 15, child: IconButton(icon: Icon(Icons.arrow_back),
              onPressed: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => widget.back_func),)
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
                    Text('Все задания выполнены. Вы огромный молодец!', textAlign: TextAlign.center, style:
                    TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color(0xff286419)),),
                    SizedBox(height: 40),
                    TextButton(
                      style: ButtonStyle(
                        // minimumSize: MaterialStateProperty.all(Size(90, 50)), //
                        backgroundColor: MaterialStateProperty.all(Colors.green),
                      ),
                      onPressed: () {
                        FirestoreService().TaskDeleteInfo(
                            getUserId(), widget.TaskType,
                            widget.TaskName, widget.TaskDifficulty);

                        if (widget.onGameUpdate != null) {
                          widget.onGameUpdate!();
                        }
                      },

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => HearTask(flag: 'no', back_func: widget.back_func,)),);
                      // },

                      child: SizedBox(
                          width: 50,
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

  Widget buildOptionButton(String option) {
    Color buttonColor = chosenWord == option
        ? (isCorrect ? Colors.green : Colors.red)
        : Colors.white;
    return ElevatedButton(
      onPressed: !isCorrect ? () {
        checkAnswer(option);
        FirestoreService().GameUpdate2(
            UserInfo(), widget.TaskType, widget.flag == 'lesson' ? 'lesson' : 'no');
      } : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey),
        ),
        elevation: 5,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          option,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double panelHeight = MediaQuery.of(context).size.height * 0.14;
    if (ready == false)
      return Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          ));

    else if (info != null && info.length > 0 && randomNumber != -1)
    {
      return Scaffold(
          body: Stack(
              fit: StackFit.expand,
              children: [

                Image.asset(
                  "assets/images/agrammatism_back.png",
                  fit: BoxFit.cover,
                ),

                Positioned(
                    top: 50,
                    left: 15,
                    child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () =>  widget.back_func != null ? Navigator.push(context,MaterialPageRoute(builder: (context) => widget.back_func),)
                            : Navigator.push(context,MaterialPageRoute(builder: (context) => HomeScreen()),)
                    )
                ),

                Padding(
                    padding: EdgeInsets.only(top: 90.0),
                    child:
                    Column(children: [
                      Expanded(child:
                      ListView(children: [

                        SizedBox(height: 20.0),

                        Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Container(color: Colors.white,
                                          width: 300, child: Text(name, softWrap: true,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                            ),))),

                                  SizedBox(height: 15),

                                  // if (widget.TaskName == '6_delete_letters')
                                  //   Text(words,  style: TextStyle(fontSize: 16.0,)),
                                  // if (words.length == 2  && words is List)
                                  //   Text('${words[0]} + ${words[1]}', style: TextStyle(fontSize: 16.0,)),
                                  // if (words.length == 3 && words is List)
                                  //   Text('${words[0]} + ${words[1]} + ${words[2]}', style: TextStyle(fontSize: 16.0,)),
                                  // if (words.length == 4 && words is List)
                                  //   Text('${words[0]} + ${words[1]} + ${words[2]} + ${words[3]}', style: TextStyle(fontSize: 16.0,)),


                                  Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        for (int i = 0; i < options.length; i++)
                                          Column(children:[
                                            buildOptionButton(options[i]),
                                            SizedBox(height: 20),
                                          ]),

                                      ]),
                                ]))
                      ]))
                    ])),

                if (chosenWord != null && done == true && chosenWord == answer)
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          height: panelHeight,
                          width: double.infinity,
                          color: Color(0xffCCFFA4),
                          child: Center(
                            child: ElevatedButton(
                                onPressed: () {
                                  // done = true;
                                  if (widget.flag == 'lesson') {
                                    FirestoreService().LessonsStatUpdate(
                                        getUserId(), widget.lessonInfo,
                                        widget.TaskType, widget.TaskName, widget.TaskDifficulty,
                                        randomNumber).then((value) {
                                      if (widget.onGameUpdate != null) {
                                        widget.onGameUpdate!();
                                      }
                                    });
                                  }
                                  else {
                                    FirestoreService().GameUpdate2(
                                        UserInfo(), widget.TaskType,
                                        widget.flag == 'lesson'
                                            ? 'lesson'
                                            : 'no').then((value) {
                                      if (widget.onGameUpdate != null) {
                                        widget.onGameUpdate!();
                                      }
                                    });
                                  }
                                  // whenComplete(() => Navigator.pushReplacement(context,
                                  //       MaterialPageRoute(builder: (context) =>
                                  //         Detail(product: products[0])),
                                  //   ));
                                },
                                child: Text('Дальше',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(
                                        0xff36FF24), // Укажите цвет текста здесь
                                  ),
                                ),
                                style:
                                ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0),
                                      bottomLeft: Radius.circular(10.0),
                                      bottomRight: Radius.circular(10.0),
                                    ),
                                  ),
                                  backgroundColor: Colors.white,
                                )

                            ),))),
              ]));
    }
    else if (randomNumber == -1 && widget.flag != 'lesson'){
      return finishScreen();
    }
    else {
      return Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          ));
    }
  }
}

class MultipleChoiceTask extends StatefulWidget {
  final String? TaskType;
  final String TaskName;
  final String? TaskDifficulty;
  final String flag;
  final List? lessonInfo;
  Function? onGameUpdate;
  final back_func;
  final givenIndex;

  MultipleChoiceTask({Key? key, this.TaskType, required this.TaskName, this.TaskDifficulty, required this.flag, this.lessonInfo, this.onGameUpdate, this.back_func, this.givenIndex}) : super(key: key);

  @override
  State<MultipleChoiceTask> createState() => _MultipleChoiceTask();
}

class _MultipleChoiceTask extends State<MultipleChoiceTask> {
  FlutterTts flutterTts = FlutterTts();

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("ru-RU");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  var blue_grad = LinearGradient(colors: [Color(0xffFFBE8C), Color(0xffFFA967)]);
  var green_grad = LinearGradient(colors: [Color(0xffBDDE60), Color(0xffBAD177)]);
  var red_grad = LinearGradient(colors: [Color(0xffDE6F60), Color(0xffFFBFB0)]);
  String question = '';
  List options = [];
  bool answered = false;
  String correctAnswer = '';
  String chosenWord = '';
  bool isCorrect = false;
  var randomNumber;
  Map info = {};

  // String writtenWord = '';
  var answer;
  String name = '';
  var words;
  var done = false;
  bool ready = false;

  Random random = Random();
  var randomImageIndex = 0;
  List<String> levels = ['easy', 'middle', 'high'];
  var index = 0;
  String level = '';
  var results;
  var selected;
  var OurColors = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      randomImageIndex = Random().nextInt(6) + 1;
      index = Random().nextInt(['easy', 'middle', 'high'].length);
      level = widget.TaskDifficulty == null ? levels[index] : widget.TaskDifficulty!;
    });

    FirestoreService().chooseRandomNumber4(
        UserInfo(), parsedJson, widget.TaskType,
        widget.flag == 'lesson' ? 'lesson' : 'no').then((value) {
      setState(() {
        randomNumber = value;
        if (randomNumber != -1) {
          info = parsedJson[widget.TaskType][widget.TaskName][widget
              .TaskDifficulty == null ? levels[index] : widget
              .TaskDifficulty][randomNumber.toString()];
          print(info);
          name = info['name'];
          options = info['options'];
          print(options.length);
          print('а');
          answer = info['answer'];
          results  = List.generate
            (options.length, (index) => answer.contains(options[index]));
          selected  = List.generate(options.length, (index) => false);
          OurColors = List.generate(options.length, (index) => blue_grad);
        };
      });
    }).then((value) {
      setState(() {
        ready = true;
      });
    });;

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

  UserInfo() {
    Map userInfo = getUserId();
    String userId = userInfo['userId']!;
    String email = userInfo['email']!;

    UserTask3 user_task = UserTask3(
      userId: userId,
      email: email,
      taskName: widget.TaskName,
      taskDifficulty: level,
      taskNumber: randomNumber,
      date: DateTime.now(),
      correct_answer: isCorrect,
      wrong_answer: !isCorrect,
    );
    return user_task;
  }

  checkAnswer() {
    setState(() {
      done = true;
      if (selected.toString() == results.toString()) {
        playSound('sounds/right.wav');
        isCorrect = true;
      } else {
        playSound('sounds/wrong.mp3');
        isCorrect = false;
        SnackBarService.showSnackBar(context,'Неверно, попробуйте ещё раз',
          true,
        );
      }
    });
  }

  void playSound(sound) {
    final player = AudioPlayer();
    player!.play(AssetSource(sound));
  }

  Widget finishScreen() {
    return Scaffold(body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/finish_back.png", fit: BoxFit.cover,),
          Positioned(top: 50, left: 15, child: IconButton(icon: Icon(Icons.arrow_back),
              onPressed: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => widget.back_func),)
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
                    Text('Все задания выполнены. Вы огромный молодец!', textAlign: TextAlign.center, style:
                    TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color(0xff286419)),),
                    SizedBox(height: 40),
                    TextButton(
                      style: ButtonStyle(
                        // minimumSize: MaterialStateProperty.all(Size(90, 50)), //
                        backgroundColor: MaterialStateProperty.all(Colors.green),
                      ),
                      onPressed: () {
                        FirestoreService().TaskDeleteInfo(
                            getUserId(), widget.TaskType,
                            widget.TaskName, widget.TaskDifficulty);

                        if (widget.onGameUpdate != null) {
                          widget.onGameUpdate!();
                        }
                      },

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => HearTask(flag: 'no', back_func: widget.back_func,)),);
                      // },

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

  Widget buildOptionButton(i) {
    return GestureDetector(
        onTap:
        isCorrect == false ? () {
          setState(() {
            print(selected[i]);
            selected[i] = !selected[i];
            if (selected[i] == true) {
              print('да');
              OurColors[i] = green_grad;
            }
            else {
              OurColors[i] = blue_grad;
            }
          });
        } : null,

        child: Container(
            margin: const EdgeInsets.all(10.0),
            width: 260.0,
            height: 65.0,
            decoration: BoxDecoration(
                gradient: OurColors[i],
                borderRadius: BorderRadius.circular(14.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  )]),
            child: Center(
              child:
              Text(
                options[i],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 19.0,),
              ),
            )
        ));
  }

  @override
  Widget build(BuildContext context) {
    double panelHeight = MediaQuery.of(context).size.height * 0.14;
    if (ready == false)
      return Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          ));

    else if (info != null && info.length > 0 && randomNumber != -1)
    {
      return Scaffold(
          body: Stack(
              fit: StackFit.expand,
              children: [

                Image.asset(
                  "assets/images/agrammatism_back.png",
                  fit: BoxFit.cover,
                ),

                Positioned(
                    top: 50,
                    left: 15,
                    child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () =>  widget.back_func != null ? Navigator.push(context,MaterialPageRoute(builder: (context) => widget.back_func),)
                            : Navigator.push(context,MaterialPageRoute(builder: (context) => HomeScreen()),)
                    )
                ),

                Padding(
                    padding: EdgeInsets.only(top: 90.0),
                    child:
                    Column(children: [
                      Expanded(child:
                      ListView(children: [

                        SizedBox(height: 20.0),

                        Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Container(color: Colors.white,
                                          width: 300, child: Text(name, softWrap: true,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                            ),))),

                                  SizedBox(height: 15),

                                  Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        for (int i = 0; i < options.length; i++)
                                          Column(children:[
                                            buildOptionButton(i),
                                            SizedBox(height: 5),
                                          ]),
                                      ]),

                                  SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {

                                      checkAnswer();

                                      setState(() {

                                        if (selected.toString() == results.toString()) {
                                          done = true;
                                          isCorrect = true;
                                        }
                                        else {

                                          for (int i = 0; i < selected.length; i++) {
                                            if (selected[i] == true && results[i] == true) {
                                              print('Я тут');
                                              OurColors[i] = green_grad;
                                            }
                                            else if (selected[i] == true && results[i] == false) {
                                              OurColors[i] = red_grad;
                                            }
                                          }

                                          done = true;

                                          Future.delayed(Duration(seconds: 1), () {

                                            setState(() {done = false;
                                            selected  = List.generate(options.length, (index) => false);
                                            OurColors = List.generate(options.length, (index) => blue_grad);
                                            });}
                                          );

                                        }
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black, // цвет фона кнопки
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(2), // закругление углов на 10
                                      ),
                                    ),
                                    child: Text('Проверить', style: TextStyle(
                                      color: Colors.white, fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    ),
                                  ),

                                ]))
                      ]))
                    ])),

                if (isCorrect == true)
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          height: panelHeight,
                          width: double.infinity,
                          color: Color(0xffCCFFA4),
                          child: Center(
                            child: ElevatedButton(
                                onPressed: () {
                                  // done = true;
                                  if (widget.flag == 'lesson') {
                                    FirestoreService().LessonsStatUpdate(
                                        getUserId(), widget.lessonInfo,
                                        widget.TaskType, widget.TaskName, widget.TaskDifficulty,
                                        randomNumber).then((value) {
                                      if (widget.onGameUpdate != null) {
                                        widget.onGameUpdate!();
                                      }
                                    });
                                  }
                                  else {
                                    FirestoreService().GameUpdate2(
                                        UserInfo(), widget.TaskType,
                                        widget.flag == 'lesson'
                                            ? 'lesson'
                                            : 'no').then((value) {
                                      if (widget.onGameUpdate != null) {
                                        widget.onGameUpdate!();
                                      }
                                    });
                                  }
                                },
                                child: Text('Дальше',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(
                                        0xff36FF24), // Укажите цвет текста здесь
                                  ),
                                ),
                                style:
                                ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0),
                                      bottomLeft: Radius.circular(10.0),
                                      bottomRight: Radius.circular(10.0),
                                    ),
                                  ),
                                  backgroundColor: Colors.white,
                                )

                            ),))),
              ]));
    }
    else if (randomNumber == -1 && widget.flag != 'lesson'){
      return finishScreen();
    }
    else {
      return Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          ));
    }
  }
}

class MatchTask extends StatefulWidget {
  final String? TaskType;
  final String TaskName;
  final String? TaskDifficulty;
  final String flag;
  final List? lessonInfo;
  Function? onGameUpdate;
  final back_func;
  final givenIndex;

  MatchTask({Key? key, this.TaskType, required this.TaskName, this.TaskDifficulty, required this.flag, this.lessonInfo, this.onGameUpdate, this.back_func, this.givenIndex}) : super(key: key);

  @override
  State<MatchTask> createState() => _MatchTask();
}

class _MatchTask extends State<MatchTask> {
  FlutterTts flutterTts = FlutterTts();

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("ru-RU");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  String firstCard = '';
  String secondCard = '';
  int pairs = 0;
  List uniq_pairs = [];
  Map fieldColor = {};
  Map bordersColor = {};
  Map buttonEnabled = {};
  var blue_grad = LinearGradient(colors: [Color(0xffFFBE8C), Color(0xffFFA967)]);
  var green_grad = LinearGradient(colors: [Color(0xffBDDE60), Color(0xffBAD177)]);
  var red_grad = LinearGradient(colors: [Color(0xffDE6F60), Color(0xffFFBFB0)]);
  List<String> keys = [];
  Map cards = {};
  var randomNumber;

  String question = '';
  List options = [];
  bool answered = false;
  String correctAnswer = '';
  String chosenWord = '';
  bool isCorrect = false;
  Map info = {};
  var answer;
  String name = '';
  var words;
  Color font_color = Colors.black;
  var done = false;
  bool ready = false;

  Random random = Random();
  var randomImageIndex = 0;
  List<String> levels = ['easy', 'middle', 'high'];
  var index = 0;
  String level = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      randomImageIndex = Random().nextInt(6) + 1;
      index = Random().nextInt(['easy', 'middle', 'high'].length);
      level = widget.TaskDifficulty == null ? levels[index] : widget.TaskDifficulty!;
    });

    FirestoreService().chooseRandomNumber4(
        UserInfo(), parsedJson, widget.TaskType,
        widget.flag == 'lesson' ? 'lesson' : 'no').then((value) {
      setState(() {
        randomNumber = value;
        if (randomNumber != -1) {
          info = parsedJson[widget.TaskType][widget.TaskName][widget
              .TaskDifficulty == null ? levels[index] : widget
              .TaskDifficulty][randomNumber.toString()];
          print('info $info');
          if (widget.TaskName  == '1_synonyms') {
            name = parsedJson[widget.TaskType][widget.TaskName]['name'];
            cards = info;
            fieldColor = {for (var e in cards.keys) e: [blue_grad, blue_grad]};
            buttonEnabled = {for (var e in cards.keys) e: true};
            keys = [for (var e in cards.keys) e];
            keys.shuffle();
          }
          else {
            name = parsedJson[widget.TaskType][widget.TaskName]['name'];
            print('name $name');
            cards = info;
            fieldColor = {for (var e in cards.keys) e: [blue_grad, blue_grad]};
            buttonEnabled = {for (var e in cards.keys) e: true};
            keys = [for (var e in cards.keys) e];
            keys.shuffle();
          }
        };
      });
    }).then((value) {
      setState(() {
        ready = true;
      });
    });;

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

  UserInfo() {
    Map userInfo = getUserId();
    String userId = userInfo['userId']!;
    String email = userInfo['email']!;

    UserTask3 user_task = UserTask3(
      userId: userId,
      email: email,
      taskName: widget.TaskName,
      taskDifficulty: level,
      taskNumber: randomNumber,
      date: DateTime.now(),
      correct_answer: isCorrect,
      wrong_answer: !isCorrect,
    );
    return user_task;
  }

  checkAnswer() {
    setState(() {
      done = true;
      if (isCorrect == true) {
        playSound('sounds/right.wav');
        // isCorrect = true;
      } else {
        playSound('sounds/wrong.mp3');
        // isCorrect = false;
        SnackBarService.showSnackBar(context,'Неверно, попробуйте ещё раз',
          true,
        );
      }
      // chosenWord = userWord;

    });
  }

  void playSound(sound) {
    final player = AudioPlayer();
    player!.play(AssetSource(sound));
  }

  Widget finishScreen() {
    return Scaffold(body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/finish_back.png", fit: BoxFit.cover,),
          Positioned(top: 50, left: 15, child: IconButton(icon: Icon(Icons.arrow_back),
              onPressed: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => widget.back_func),)
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
                    Text('Все задания выполнены. Вы огромный молодец!', textAlign: TextAlign.center, style:
                    TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color(0xff286419)),),
                    SizedBox(height: 40),
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.green),
                      ),
                      onPressed: () {
                        FirestoreService().TaskDeleteInfo(
                            getUserId(), widget.TaskType,
                            widget.TaskName, widget.TaskDifficulty);

                        if (widget.onGameUpdate != null) {
                          widget.onGameUpdate!();
                        }
                      },

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => HearTask(flag: 'no', back_func: widget.back_func,)),);
                      // },

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

  @override
  Widget build(BuildContext context) {
    double panelHeight = MediaQuery.of(context).size.height * 0.14;
    print('flag $ready');
    if (ready == false)
      return Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          ));
    else if (info != null && info.length > 0 && randomNumber != -1)
    {
      return Scaffold(
          body: Stack(
              fit: StackFit.expand,
              children: [

                Image.asset(
                  "assets/images/${widget.TaskType == 'agreement' ? 'agreement' : 'agrammatism' }_back.png",
                  fit: BoxFit.cover,
                ),

                Positioned(
                    top: 50,
                    left: 15,
                    child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () =>  widget.back_func != null ? Navigator.push(context,MaterialPageRoute(builder: (context) => widget.back_func),)
                            : Navigator.push(context,MaterialPageRoute(builder: (context) => HomeScreen()),)
                    )
                ),

                Padding(
                    padding: EdgeInsets.only(top: 90.0),
                    child:
                    Column(children: [
                      Expanded(child:
                      ListView(children: [

                        SizedBox(height: 20.0),

                        Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Container(color: Colors.white,
                                          width: 300, child: Text(name, softWrap: true,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                            ),))),

                                  SizedBox(height: 15),


                                  for (var i = 0; i < cards.keys.toList().length; i++)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: fieldColor[keys[i]][0] == green_grad ? null : () {
                                            setState(() {
                                              if (buttonEnabled[keys[i]] == true && uniq_pairs.toSet().length != keys.length) {
                                                if (secondCard == '') {
                                                  if (firstCard != '') {
                                                    fieldColor[firstCard][0] = blue_grad;
                                                  }
                                                  firstCard = keys[i];
                                                  fieldColor[firstCard][0] = green_grad;
                                                }

                                                else if (secondCard != '' && firstCard == '') {
                                                  firstCard = keys[i];
                                                  // Проверяем, совпадают ли выбранные карточки
                                                  if (firstCard == secondCard) {
                                                    // Подсвечиваем зеленым цветом и увеличиваем счетчик пар
                                                    isCorrect = true;
                                                    checkAnswer();
                                                    fieldColor[keys[i]] =
                                                    [green_grad, green_grad];
                                                    pairs++;
                                                    uniq_pairs.add(firstCard);
                                                    firstCard = '';
                                                    secondCard = '';
                                                    buttonEnabled[keys[i]] = false;
                                                  }
                                                  else {
                                                    // Сбрасываем выбранные карточки через некоторое время
                                                    isCorrect = false;
                                                    FirestoreService().GameUpdate2(
                                                        UserInfo(), widget.TaskType,
                                                        widget.flag == 'lesson'
                                                            ? 'lesson'
                                                            : 'no');
                                                    checkAnswer();
                                                    fieldColor[firstCard][0] = red_grad;
                                                    fieldColor[secondCard][1] = red_grad;
                                                    Timer(const Duration(
                                                        seconds: 1), () {
                                                      setState(() {
                                                        fieldColor[firstCard][0] = blue_grad;
                                                        fieldColor[secondCard][1] = blue_grad;
                                                        firstCard = '';
                                                        secondCard = '';
                                                      });
                                                    });
                                                  }
                                                }
                                                else
                                                  return;
                                              }});},

                                          child:
                                          Container(
                                              margin: const EdgeInsets.all(10.0),
                                              width: 150.0,
                                              height: 100.0,
                                              decoration: BoxDecoration(
                                                  gradient:  fieldColor[keys[i]][0],
                                                  borderRadius: BorderRadius.circular(18.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.1),
                                                      spreadRadius: 5,
                                                      blurRadius: 7,
                                                      offset: Offset(0, 3), // changes position of shadow
                                                    )]),

                                              child: Center(
                                                child:
                                                Text(
                                                  keys[i],
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                    fontSize: 19.0,),
                                                ),
                                                // Text('${fieldColor}'),
                                              )
                                          ),

                                        ),

                                        // Карточка с определением
                                        GestureDetector(
                                          onTap:  fieldColor[cards.keys.firstWhere((key) => cards[key] == cards.values.toList()[i])][1] == green_grad ? null : () {
                                            setState(() {

                                              if (buttonEnabled[cards.keys.firstWhere((key) => cards[key] == cards.values.toList()[i])] == true &&
                                                  uniq_pairs.toSet().length != keys.length) {
                                                if (firstCard == '') {
                                                  if (secondCard != '') {
                                                    fieldColor[secondCard][1] =
                                                        blue_grad; // dark_blue_grad;
                                                  }
                                                  secondCard =
                                                      cards.keys.firstWhere((key) => cards[key] ==
                                                          cards.values.toList()[i]);
                                                  fieldColor[cards.keys.firstWhere((key) =>
                                                  cards[key] == cards.values.toList()[i])][1] =
                                                      green_grad;
                                                }
                                                else if (firstCard != '' &&
                                                    secondCard == '') {
                                                  secondCard =
                                                      cards.keys.firstWhere((key) => cards[key] ==
                                                          cards.values.toList()[i]);
                                                  if (firstCard == secondCard) {
                                                    isCorrect = true;
                                                    checkAnswer();
                                                    // Подсвечиваем зеленым цветом и увеличиваем счетчик пар
                                                    fieldColor[cards.keys.firstWhere((key) =>
                                                    cards[key] == cards.values.toList()[i])] = [
                                                      green_grad,
                                                      green_grad
                                                    ];
                                                    pairs++;
                                                    uniq_pairs.add(firstCard);
                                                    firstCard = '';
                                                    secondCard = '';
                                                    buttonEnabled[firstCard] = false;
                                                  }
                                                  else {
                                                    isCorrect = false;
                                                    FirestoreService().GameUpdate2(
                                                        UserInfo(), widget.TaskType,
                                                        widget.flag == 'lesson'
                                                            ? 'lesson'
                                                            : 'no');
                                                    checkAnswer();
                                                    fieldColor[firstCard][0] = red_grad;
                                                    fieldColor[secondCard][1] = red_grad;
                                                    // Сбрасываем выбранные карточки через некоторое время
                                                    Timer(const Duration(
                                                        seconds: 1), () {
                                                      setState(() {
                                                        // Text('${fieldColor[cards.keys.firstWhere((key) => cards[key] == cards.values.toList()[i])]}');
                                                        fieldColor[firstCard][0] = blue_grad;
                                                        fieldColor[secondCard][1] = blue_grad;
                                                        firstCard = '';
                                                        secondCard = '';
                                                      });
                                                    });
                                                  }
                                                }
                                              }});},
                                          child: Container(
                                            margin: const EdgeInsets.all(10.0),
                                            width: 150.0,
                                            height: 100.0,
                                            decoration: BoxDecoration(
                                                gradient: fieldColor[cards.keys.firstWhere((key) => cards[key] == cards.values.toList()[i])][1],
                                                borderRadius: BorderRadius.circular(18.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.withOpacity(0.1),
                                                    spreadRadius: 5,
                                                    blurRadius: 7,
                                                    offset: Offset(0, 3), // changes position of shadow
                                                  )]),

                                            child: Center(
                                              child: Text(
                                                cards.values.toList()[i],
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  fontSize: 19.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),])),


                      ]),
                      ),])),

                if (uniq_pairs.toSet().length == keys.length)
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: panelHeight,
                        width: double.infinity,
                        color: Color(0xffCCFFA4),
                        child: Center(
                          child: ElevatedButton(
                              onPressed: () {

                                if (widget.flag == 'lesson') {
                                  FirestoreService().LessonsStatUpdate(
                                      getUserId(), widget.lessonInfo,
                                      widget.TaskType, widget.TaskName, widget.TaskDifficulty,
                                      randomNumber).then((value) {
                                    if (widget.onGameUpdate != null) {
                                      widget.onGameUpdate!();
                                    }
                                  });
                                }
                                else {
                                  FirestoreService().GameUpdate2(
                                      UserInfo(), widget.TaskType,
                                      widget.flag == 'lesson'
                                          ? 'lesson'
                                          : 'no').then((value) {
                                    if (widget.onGameUpdate != null) {
                                      widget.onGameUpdate!();
                                    }
                                  });
                                }
                              },
                              child: Text('Дальше',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff36FF24), // Укажите цвет текста здесь
                                ),
                              ),
                              style:
                              ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10.0),
                                    topRight: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0),
                                  ),
                                ),
                                backgroundColor: Colors.white,
                              )

                          ),
                        ),))
              ])
      );
    }
    else if (randomNumber == -1 && widget.flag != 'lesson'){
      return finishScreen();
    }
    else {
      return Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          ));
    }
  }
}
