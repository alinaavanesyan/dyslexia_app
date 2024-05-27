import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:dyslexia_project/snack_bar.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dyslexia_project/firebase_options.dart';
import 'package:dyslexia_project/main.dart';
import 'package:dyslexia_project/screens/reading_section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dyslexia_project/tasks/tasks_data.dart';
import 'package:dyslexia_project/screens/home_screen.dart';
import 'package:dyslexia_project/screens/account_screen.dart';
import 'package:dyslexia_project/tasks/product_model.dart';
import 'package:dyslexia_project/services/database.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dyslexia_project/screens/lessons.dart';
part 'tasks.g.dart';

@JsonSerializable()
class JsonDat {
  JsonDat({required this.tasks, required this.match, required this.id, required this.word, required this.description});
  final String tasks;
  final String match;
  final int id;
  final String word;
  final String description;
}

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
          showElevation: true, // use this to remove appBar's elevation
          // onItemSelected: (index) => setState(() {
          //   _selectedIndex = index;
          // }),
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

class Task1 extends StatelessWidget {
  const Task1 ({super.key});

  @override
  Widget build(BuildContext context) {
    return MemoryGame();
  }
}

class Task2 extends StatelessWidget {
  const Task2({super.key});

  @override
  Widget build(BuildContext context) {
    return PasteGame();
    return Container(
      child:
      const Column(
          children: [
            Text('Hello 2'),
            PasteGame(),
          ]),);
  }
}

class Task3 extends StatefulWidget{
  const Task3({super.key});

  @override
  _Task3State createState() => _Task3State();
}

class _Task3State extends State<Task3> {
  String word = 'FLUTTER';
  String selectedLetters = '';

  List<String> uniqueLetters = [];

  @override
  void initState() {
    super.initState();
    uniqueLetters = word.split('').toSet().toList();
  }

  void selectLetter(String letter) {
    setState(() {
      selectedLetters += letter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              word,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            Wrap(
              spacing: 10.0,
              children: uniqueLetters.map((letter) {
                return ElevatedButton(
                  onPressed: () {
                    selectLetter(letter);
                  },
                  child: Text(letter),
                );
              }).toList(),
            ),
            SizedBox(height: 20.0),
            Text(
              selectedLetters,
              style: TextStyle(fontSize: 20.0),
            ),
          ],
        ),
      ),
    );
    // return FindGame();
  }
}

class Task4 extends StatefulWidget {

  const Task4({super.key});

  @override
  _Task4State createState() => _Task4State();
}

class _Task4State extends State<Task4> {
  String question = '';
  List options = [];
  bool answered = false;
  String correctAnswer = '';
  String chosenAnswer = '';
  bool isCorrect = false;
  var randomNumber;
  Map info = {};

  @override
  void initState() {
    super.initState();
    FirestoreService().chooseRandomNumber2(
        FirebaseAuth.instance.currentUser!, parsedJson, 'choose_option').then((value) {
      setState(() {
        randomNumber = value;
        if (randomNumber != -1) {
          info = parsedJson['tasks']['choose_option'][randomNumber.toString()];
          correctAnswer = info['answer'];
          question = info['question'];
          options = info['options'];
        };
      });
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

  UserInfo() {
    Map userInfo = getUserId();
    String userId = userInfo['userId']!;
    String email = userInfo['email']!;

    UserTask2 user_task = UserTask2(
      userId: userId,
      email: email,
      taskNumber: randomNumber,
      date: DateTime.now(),
      correct_answer: isCorrect,
      wrong_answer: !isCorrect,
    );
    return user_task;
  }

  checkAnswer(String selectedAnswer) {
    setState(() {
      if (selectedAnswer == correctAnswer) {
        playSound('sounds/right.wav');
        isCorrect = true;
      } else {
        playSound('sounds/wrong.mp3');
        isCorrect = false;
      }
      chosenAnswer = selectedAnswer;
    });
  }

  void playSound(sound) {
    final player = AudioPlayer();
    player!.play(AssetSource(sound));
  }

  @override
  Widget build(BuildContext context) {
    double panelHeight = MediaQuery.of(context).size.height * 0.14;
    if (info != null && info.length > 0 && randomNumber != -1)
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

                        Center(
                          child:


                          Text(
                            question,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                                color: Colors.grey// размер шрифта
                            ),
                          ),
                        ),

                        SizedBox(height: 20.0),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildOptionButton(options[0]),
                            SizedBox(height: 20),
                            buildOptionButton(options[1]),
                            SizedBox(height: 20),
                            buildOptionButton(options[2]),
                            SizedBox(height: 20),
                            buildOptionButton(options[3]),
                          ],
                        ),

                        SizedBox(height: 20),

                      ]))
                    ])),

                if (chosenAnswer != null && chosenAnswer == correctAnswer)
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          height: panelHeight,
                          width: double.infinity,
                          color: Color(0xffCCFFA4),
                          child: Center(
                            child: ElevatedButton(
                                onPressed: () {
                                  FirestoreService().GameUpdate(
                                      UserInfo(), 'hear_letter').whenComplete(() =>
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) =>
                                            Detail(product: products[0])),
                                      )
                                  );
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
                            ),
                          ))),
              ]));
    }
    else {
      return Scaffold(
          body: Stack(
              fit: StackFit.expand,
              children: [

                Image.asset("assets/images/match_back.png", fit: BoxFit.cover,),

                Positioned(
                    top: 50,
                    left: 15,
                    child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () =>  Navigator.push(context,MaterialPageRoute(builder: (context) => HomeScreen()),)
                    )
                ),

                Center(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text('Карточки закончились',
                      style: TextStyle(fontSize: 24.0),
                    ),
                  ),
                ),

              ])

      );}
  }

  Widget buildOptionButton(String option) {
    Color buttonColor = chosenAnswer == option
        ? (isCorrect ? Colors.green : Colors.red)
        : Colors.white;
    return ElevatedButton(
      onPressed: () {
        checkAnswer(option);
        FirestoreService().HearGameUpdate(
            UserInfo());
      },
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

}

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  String firstCard = '';
  String secondCard = '';
  int pairs = 0;
  List uniq_pairs = [];
  Map fieldColor = {};
  Map bordersColor = {};
  Map buttonEnabled = {};
  var blue_grad = LinearGradient(colors: [Color(0xff2CBEFE), Color(0xff4DA6FC)]);
  var dark_blue_grad = LinearGradient(colors: [Color(0xff4A98BB), Color(0xff4678A8)]);
  var green_grad = LinearGradient(colors: [Color(0xff75FF09), Color(0xff9DEF5C)]);
  var red_grad = LinearGradient(colors: [Color(0xffFF5959), Color(0xffFF6C7D)]);
  List<String> keys = [];
  Map cards = {};
  var randomNumber;

  @override
  void initState() {
    super.initState();
    FirestoreService().chooseRandomNumber(
        FirebaseAuth.instance.currentUser!, parsedJson, 'match').then((value) {
      setState(() {
        randomNumber = value;
        print(randomNumber);
        if (randomNumber != -1) {
          cards = parsedJson['tasks']['match'][randomNumber.toString()];
          fieldColor = {for (var e in cards.keys) e: [blue_grad, blue_grad]};
          buttonEnabled = {for (var e in cards.keys) e: true};
          keys = [for (var e in cards.keys) e];
          keys.shuffle();
        }
      });
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

  UserInfo() {
      Map userInfo = getUserId();
      String userId = userInfo['userId']!;
      String email = userInfo['email']!;

    UserTask user_task = UserTask(
      userId: userId,
      email: email,
      // taskType: 'Match',
      taskNumber: [randomNumber, FieldValue.serverTimestamp()],
    );
    return user_task;
  }

  @override
  Widget build(BuildContext context) {
    double panelHeight = MediaQuery.of(context).size.height * 0.14;
    if (randomNumber != -1)
      {
        print(randomNumber);
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
                              onPressed: () =>  Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => HomeScreen()),)
                          )),

                      Padding(
                        padding: EdgeInsets.only(top: 90.0),
                          child:
                        Column(children: [
                              // padding: EdgeInsets.all(0),
                              // margin: EdgeInsets.only(top: 80.0),
                          Expanded(child:
                              ListView(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    // Выводим карточки со словами и определениями
                                    for (var i = 0; i < cards.keys.toList().length; i++)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () {
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
                                                width: 100.0,
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
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white,
                                                      fontSize: 20.0,),
                                                  ),
                                                  // Text('${fieldColor}'),
                                                )
                                            ),

                                          ),

                                          // Карточка с определением
                                          GestureDetector(
                                            onTap: () {
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
                                              width: 200.0,
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
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                    fontSize: 20.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),]))
                        ,

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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Detail(product: products[0])),
                          );
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

    ]))
      ]));
      }
    else {
      return Scaffold(
          body: Stack(
          fit: StackFit.expand,
          children: [

            Image.asset(
          "assets/images/match_back.png",
          fit: BoxFit.cover,),

          Positioned(
            top: 50,
            left: 15,
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () =>  Navigator.push(context,MaterialPageRoute(builder: (context) => HomeScreen()),)
            )
          ),

            Center(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  'Карточки закончились',
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
            ),

            // Text('Карточки закончились')
            ])
      );}
  }
  }


class PasteGame extends StatefulWidget {
  const PasteGame({super.key});


  @override
  State<PasteGame> createState() => _PasteGame();
}

class _PasteGame extends State<PasteGame> {
  String sentence = '';
  String chosenWord = '';
  int pairs = 0;
  int done = 0;
  Color font_color = Colors.black;
  var randomNumber;
  Map info = {};
  List parts = [];

  @override
  void initState() {
    super.initState();
    FirestoreService().chooseRandomNumber2(
        FirebaseAuth.instance.currentUser!, parsedJson, 'paste').then((value) {
      setState(() {
        print('da');
        randomNumber = value;
        print(randomNumber);
        print('d');
        if (randomNumber != -1) {
          info = parsedJson['tasks']['paste'][randomNumber.toString()];
          print(info['options'][0]);
          parts = info['sent1'].split("___");
        }
      });
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

  UserInfo() {
    Map userInfo = getUserId();
    String userId = userInfo['userId']!;
    String email = userInfo['email']!;

    UserTask user_task = UserTask(
      userId: userId,
      email: email,
      taskNumber: [randomNumber, FieldValue.serverTimestamp()],
    );
    return user_task;
  }

  @override
  Widget build(BuildContext context) {
    double panelHeight = MediaQuery
        .of(context)
        .size
        .height * 0.14;
    if (info != null && info.length > 0){
      print(done);
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
                    padding: EdgeInsets.fromLTRB(30.0, 150.0, 30.0, 10.0),
                    // EdgeInsets.only(top: 90.0),
                    child:
                    ListView(children: <Widget>[
                      Row(children: [
                        Text(parts[0] + '  ',
                          style: TextStyle(color: Colors.grey, fontSize: 22,),),

                        Container(
                          height: 50,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.25,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ), child:
                        DragTarget<String>(
                            builder: (context, candidateData, rejectedData) {
                              return Center(
                                  child: Text(chosenWord,
                                      style: TextStyle(color: font_color,
                                        fontSize: 22,)
                                  )
                              );
                            },

                            onAccept: (data) {
                              setState(() {
                                chosenWord = data;
                                if (chosenWord == info['answer']) {
                                  font_color = Colors.green;
                                  done += 1;
                                } else {
                                  font_color = Colors.red;
                                } // сохраняем выбранное слово
                              });
                            }
                        ),),

                        Text('  ' + parts[1],
                          style: TextStyle(
                            color: Colors.grey, fontSize: 22,),),
                      ])
                    ])),

                const SizedBox(height: 10),

                Padding(
                    padding: EdgeInsets.all(20.0),
                    // EdgeInsets.only(top: 90.0),
                    child:
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Draggable<String>(
                          data: info['options'][0],
                          feedback: _buildCard(info['options'][0]),
                          // отображается при перетаскивании
                          childWhenDragging: Container(),
                          child: _buildCard(
                              info['options'][0]), // исчезает при перетаскивании
                        ),
                        Draggable<String>(
                          data: info['options'][1],
                          feedback: _buildCard(info['options'][1]),
                          // отображается при перетаскивании
                          childWhenDragging: Container(),
                          child: _buildCard(
                              info['options'][1]), // исчезает при перетаскивании
                        ),
                        Draggable<String>(
                          data: info['options'][2],
                          feedback: _buildCard(info['options'][2]),
                          // отображается при перетаскивании
                          childWhenDragging: Container(),
                          child: _buildCard(
                              info['options'][2]), // исчезает при перетаскивании
                        ),
                      ],
                    )),

                if (chosenWord == info['answer'])
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          height: panelHeight,
                          width: double.infinity,
                          color: Color(0xffCCFFA4),
                          child: Center(
                            child: ElevatedButton(

                                onPressed: () {
                                  FirestoreService().PasteGameUpdate(
                                      UserInfo()).whenComplete(() =>
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) =>
                                            Detail(product: products[0])),
                                      )
                                  );
                                  done += 1;
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
    else {
      // if (done == parsedJson['tasks']['paste'].length)
      return Scaffold(
          body: Stack(
              fit: StackFit.expand,
              children: [

                Image.asset(
                  "assets/images/match_back.png",
                  fit: BoxFit.cover,),

                Positioned(
                    top: 50,
                    left: 15,
                    child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () =>
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => HomeScreen()),)
                    )),

                Center(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text('Карточки закончились',
                      style: TextStyle(fontSize: 24.0),
                    ),),
                ),
              ]
          )
      );
    }
  }

  Widget _buildCard(String word) {
    return Container(
      height: 50,
      width: 90,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
      ),
      child: Center(
        child: Text(
          word,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}


class FindGame extends StatefulWidget {
  const FindGame({super.key});

  @override
  State<FindGame> createState() => _FindGameState();
}

class _FindGameState extends State<FindGame> {
  var randomNumber;

  @override
  void initState() {
    super.initState();
    FirestoreService().chooseRandomNumber(
        FirebaseAuth.instance.currentUser!, parsedJson, 'match').then((value) {
      setState(() {
        randomNumber = value;
        print(randomNumber);
        if (randomNumber != -1) {
          // cards = parsedJson['tasks']['match'][randomNumber.toString()];
          // fieldColor = {for (var e in cards.keys) e: [blue_grad, blue_grad]};
          // buttonEnabled = {for (var e in cards.keys) e: true};
          // keys = [for (var e in cards.keys) e];
          // keys.shuffle();
        }
      });
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

  UserInfo() {
    Map userInfo = getUserId();
    String userId = userInfo['userId']!;
    String email = userInfo['email']!;

    UserTask user_task = UserTask(
      userId: userId,
      email: email,
      // taskType: 'Match',
      taskNumber: [randomNumber, FieldValue.serverTimestamp()],
    );
    return user_task;
  }

  @override
  Widget build(BuildContext context) {
    double panelHeight = MediaQuery.of(context).size.height * 0.14;
    // if (randomNumber != -1)
    // {
      print(randomNumber);
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
                  onPressed: () =>  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),)
              )),

          Padding(
              padding: EdgeInsets.only(top: 90.0),
              child:
              Column(children: [
                Expanded(child:
                ListView(
                    children: <Widget>[
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[

                          ])
                    ]))
              ])
          ),
          ])

      );}
  }

class Task5 extends StatefulWidget {
  const Task5({super.key});

  @override
  State<Task5> createState() => _Task5();
}

class _Task5 extends State<Task5> {
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
  List options = [];
  bool isCorrect = false;
  int pairs = 0;
  int done = 0;
  Color font_color = Colors.black;
  var randomNumber;
  Map info = {};

  @override
  void initState() {
    super.initState();
    FirestoreService().chooseRandomNumber2(
        FirebaseAuth.instance.currentUser!, parsedJson, 'hear_letter').then((value) {
      setState(() {
        randomNumber = value;
        if (randomNumber != -1) {
          info = parsedJson['tasks']['hear_letter'][randomNumber.toString()];
          rightWord = info['letter'];
          options = info['options'];
        };
      });
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

  UserInfo() {
    Map userInfo = getUserId();
    String userId = userInfo['userId']!;
    String email = userInfo['email']!;

    UserTask2 user_task = UserTask2(
      userId: userId,
      email: email,
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

  @override
  Widget build(BuildContext context) {
    double panelHeight = MediaQuery.of(context).size.height * 0.14;
    if (info != null && info.length > 0 && randomNumber != -1)
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

                      IconButton(
                        icon: Icon(Icons.volume_up),
                        iconSize: 48,
                        onPressed: () {
                          speak(rightWord);
                        },
                      ),

                      SizedBox(height: 20.0),

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
                      ),
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
                  FirestoreService().GameUpdate(
                      UserInfo(), 'hear_letter').whenComplete(() =>
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            Detail(product: products[0])),
                      )
                  );
                  done += 1;
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
  else {
    return Scaffold(
        body: Stack(
            fit: StackFit.expand,
            children: [

              Image.asset("assets/images/match_back.png", fit: BoxFit.cover,),

              Positioned(
                  top: 50,
                  left: 15,
                  child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () =>  Navigator.push(context,MaterialPageRoute(builder: (context) => HomeScreen()),)
                  )
              ),

              Center(
                child: Container(
                  alignment: Alignment.center,
                  child: Text('Карточки закончились',
                    style: TextStyle(fontSize: 24.0),
                  ),
                ),
              ),

            ])

    );}
  }

  Widget buildOptionButton(String option) {
    Color buttonColor = chosenWord == option
        ? (isCorrect ? Colors.green : Colors.red)
        : Colors.white;
    return ElevatedButton(
        onPressed: () {
          checkAnswer(option);
          FirestoreService().HearGameUpdate(
              UserInfo());
        },
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
}


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

