import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:dyslexia_project/recorder/task.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dyslexia_project/firebase_options.dart';
import 'package:dyslexia_project/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dyslexia_project/tasks/tasks_data.dart';
import 'package:dyslexia_project/tasks/tasks.dart';
import 'package:dyslexia_project/screens/home_screen.dart';
import 'package:dyslexia_project/screens/account_screen.dart';
import 'package:dyslexia_project/screens/lessons.dart';
import 'package:dyslexia_project/screens/reading_section.dart';
import 'package:dyslexia_project/tasks/product_model.dart';
import 'package:dyslexia_project/services/database.dart';
import 'package:dyslexia_project/screens/agrammatism.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'package:json_annotation/json_annotation.dart';
// part 'tasks.g.dart';

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
final List<String> Levels = ['easy', 'middle', 'high'];

Map LessonGroups = {
  'optical_dyslexia': {
    '1. Определить букву по её звуку': {
      'task_type': '1_hear_letter',
      'tasks': {
        0: HearTask(TaskType: 'optical_dyslexia',
            TaskName: '1_hear_letter',
            TaskDifficulty: 'easy',
            flag: 'no',
            back_func: HearListScreen()),
        1: HearTask(TaskType: 'optical_dyslexia',
            TaskName: '1_hear_letter',
            TaskDifficulty: 'middle',
            flag: 'no',
            back_func: HearListScreen()),
        2: HearTask(TaskType: 'optical_dyslexia',
            TaskName: '1_hear_letter',
            TaskDifficulty: 'high',
            flag: 'no',
            back_func: HearListScreen()),
      }},
    '2. Послушать слово и вставить буквы': {
      'task_type': '2_insert_letter',
      'tasks': {
        0: HearWriteTask(TaskType: 'optical_dyslexia',
            TaskName: '2_insert_letter',
            TaskDifficulty: 'easy',
            flag: 'no',
            back_func: HearListScreen()),
        1: HearWriteTask(TaskType: 'optical_dyslexia',
            TaskName: '2_insert_letter',
            TaskDifficulty: 'middle',
            flag: 'no',
            back_func: HearListScreen()),
        2: HearWriteTask(TaskType: 'optical_dyslexia',
            TaskName: '2_insert_letter',
            TaskDifficulty: 'high',
            flag: 'no',
            back_func: HearListScreen()),
      },
    }},
  'agrammatism': {
    '1. Образовать новое слово из первых слогов': {
      'task_type': '1_the_first_sylls',
      'tasks': {
        0: WriteTask(TaskType: 'agrammatism',
            TaskName: '1_the_first_sylls',
            TaskDifficulty: 'easy',
            flag: 'no',
            back_func: AgrammListScreen()),
        1: WriteTask(TaskType: 'agrammatism',
            TaskName: '1_the_first_sylls',
            TaskDifficulty: 'middle',
            flag: 'no',
            back_func: AgrammListScreen()),
        2: WriteTask(TaskType: 'agrammatism',
            TaskName: '1_the_first_sylls',
            TaskDifficulty: 'high',
            flag: 'no',
            back_func: AgrammListScreen()),
      }},
    '2. Образовать новое слово из последних слогов': {
      'task_type': '2_the_last_sylls',
      'tasks': {
        0: WriteTask(TaskType: 'agrammatism',
            TaskName: '2_the_last_sylls',
            TaskDifficulty: 'easy',
            flag: 'no',
            back_func: AgrammListScreen()),
        1: WriteTask(TaskType: 'agrammatism',
            TaskName: '2_the_last_sylls',
            TaskDifficulty: 'middle',
            flag: 'no',
            back_func: AgrammListScreen()),
        2: WriteTask(TaskType: 'agrammatism',
            TaskName: '2_the_last_sylls',
            TaskDifficulty: 'high',
            flag: 'no',
            back_func: AgrammListScreen()),
      }},
    '3. Найти маленькие слова в большом слове': {
      'task_type': '3_word_for_word',
      'tasks': {
        0: WriteTask(TaskType: 'agrammatism',
            TaskName: '3_word_for_word',
            TaskDifficulty: 'easy',
            flag: 'no',
            back_func: AgrammListScreen()),
        1: WriteTask(TaskType: 'agrammatism',
            TaskName: '3_word_for_word',
            TaskDifficulty: 'middle',
            flag: 'no',
            back_func: AgrammListScreen()),
        2: WriteTask(TaskType: 'agrammatism',
            TaskName: '3_word_for_word',
            TaskDifficulty: 'high',
            flag: 'no',
            back_func: AgrammListScreen()),
      }},
    '4. Выбрать слово с нужной морфемой': {
      'task_type': '4_find_morphemes',
      'tasks': {
        0: ChooseTask(TaskType: 'agrammatism',
            TaskName: '4_find_morphemes',
            TaskDifficulty: 'easy',
            flag: 'no',
            back_func: AgrammListScreen()),
        1: ChooseTask(TaskType: 'agrammatism',
            TaskName: '4_find_morphemes',
            TaskDifficulty: 'middle',
            flag: 'no',
            back_func: AgrammListScreen()),
        2: ChooseTask(TaskType: 'agrammatism',
            TaskName: '4_find_morphemes',
            TaskDifficulty: 'high',
            flag: 'no',
            back_func: AgrammListScreen()),
      }},
    '5. Соединить части слова': {
      'task_type': '5_connect_parts',
      'tasks': {
        0: MatchTask(TaskType: 'agrammatism',
            TaskName: '5_connect_parts',
            TaskDifficulty: 'easy',
            flag: 'no',
            back_func: AgrammListScreen()),
        1: MatchTask(TaskType: 'agrammatism',
            TaskName: '5_connect_parts',
            TaskDifficulty: 'middle',
            flag: 'no',
            back_func: AgrammListScreen()),
        2: MatchTask(TaskType: 'agrammatism',
            TaskName: '5_connect_parts',
            TaskDifficulty: 'high',
            flag: 'no',
            back_func: AgrammListScreen()),
      }},
    '6. Удалите лишние буквы, чтобы получилось корректное слово': {
      'task_type': '6_delete_letters',
      'tasks': {
        0: WriteTask(TaskType: 'agrammatism',
            TaskName: '6_delete_letters',
            TaskDifficulty: 'easy',
            flag: 'no',
            back_func: AgrammListScreen()),
        1: WriteTask(TaskType: 'agrammatism',
            TaskName: '6_delete_letters',
            TaskDifficulty: 'middle',
            flag: 'no',
            back_func: AgrammListScreen()),
        2: WriteTask(TaskType: 'agrammatism',
            TaskName: '6_delete_letters',
            TaskDifficulty: 'high',
            flag: 'no',
            back_func: AgrammListScreen()),
      }},
  },
  'semantics': {
    '1. Соединить синонимичные фразеологизмы': {
    'task_type': '1_synonyms',
    'tasks': {
      0: MatchTask(TaskType: 'semantics',
          TaskName: '1_synonyms',
          TaskDifficulty: 'easy',
          flag: 'no',
          back_func: SemanticsListScreen()),
      1: MatchTask(TaskType: 'semantics',
          TaskName: '1_synonyms',
          TaskDifficulty: 'middle',
          flag: 'no',
          back_func: SemanticsListScreen()),
      2: MatchTask(TaskType: 'semantics',
          TaskName: '1_synonyms',
          TaskDifficulty: 'high',
          flag: 'no',
          back_func: SemanticsListScreen()),
    }},
    '2. Соединить антонимичные фразеологизмы': {
      'task_type': '2_antonyms',
      'tasks': {
        0: MatchTask(TaskType: 'semantics',
            TaskName: '2_antonyms',
            TaskDifficulty: 'easy',
            flag: 'no',
            back_func: SemanticsListScreen()),
        1: MatchTask(TaskType: 'semantics',
            TaskName: '2_antonyms',
            TaskDifficulty: 'middle',
            flag: 'no',
            back_func: SemanticsListScreen()),
        2: MatchTask(TaskType: 'semantics',
            TaskName: '2_antonyms',
            TaskDifficulty: 'high',
            flag: 'no',
            back_func: SemanticsListScreen()),
      }},
    '3. Выберете слова, относящиеся к теме': {
      'task_type': '3_theme_words',
      'tasks': {
        0: MultipleChoiceTask(TaskType: 'semantics',
            TaskName: '3_theme_words',
            TaskDifficulty: 'easy',
            flag: 'no',
            back_func: SemanticsListScreen()),
        1: MultipleChoiceTask(TaskType: 'semantics',
            TaskName: '3_theme_words',
            TaskDifficulty: 'middle',
            flag: 'no',
            back_func: SemanticsListScreen()),
        2: MultipleChoiceTask(TaskType: 'semantics',
            TaskName: '3_theme_words',
            TaskDifficulty: 'high',
            flag: 'no',
            back_func: SemanticsListScreen()),
      }},
  },
  'with_images': {
    '1. Добавить к слову эмодзи': {
      'task_type': '1_emoji',
      'tasks': {
        0: WriteTask(TaskType: 'with_images',
            TaskName: '1_emoji',
            TaskDifficulty: 'easy',
            flag: 'no',
            back_func: ImageWithListScreen()),
        1: WriteTask(TaskType: 'with_images',
            TaskName: '1_emoji',
            TaskDifficulty: 'middle',
            flag: 'no',
            back_func: ImageWithListScreen()),
        2: WriteTask(TaskType: 'with_images',
            TaskName: '1_emoji',
            TaskDifficulty: 'high',
            flag: 'no',
            back_func: ImageWithListScreen()),
      }},
    '2. Вставить буквы, чтобы получилось слово': {
      'task_type': '2_images',
      'tasks': {
        0: WriteTask(TaskType: 'with_images',
            TaskName: '2_images',
            TaskDifficulty: 'easy',
            flag: 'no',
            back_func: ImageWithListScreen()),
        1: WriteTask(TaskType: 'with_images',
            TaskName: '2_images',
            TaskDifficulty: 'middle',
            flag: 'no',
            back_func: ImageWithListScreen()),
        2: WriteTask(TaskType: 'with_images',
            TaskName: '2_images',
            TaskDifficulty: 'high',
            flag: 'no',
            back_func: ImageWithListScreen()),
      }},

  },
  'agreement': {
    '1. Соединить части фраз': {
      'task_type': '1_phrases',
      'tasks': {
        0: MatchTask(TaskType: 'agreement',
            TaskName: '1_phrases',
            TaskDifficulty: 'easy',
            flag: 'no',
            back_func: AgreementListScreen()),
        1: MatchTask(TaskType: 'agreement',
            TaskName: '1_phrases',
            TaskDifficulty: 'middle',
            flag: 'no',
            back_func: AgreementListScreen()),
        2: MatchTask(TaskType: 'agreement',
            TaskName: '1_phrases',
            TaskDifficulty: 'high',
            flag: 'no',
            back_func: AgreementListScreen()),
      }},
  }
};


class TaskItem {
  String TaskType;
  String TaskName;
  String TaskDifficulty;

  TaskItem(this.TaskType, this.TaskName, this.TaskDifficulty);
}

// List<TaskItem> lessonItems = [
//   TaskItem(1, 'Урок 1. Учимся различать звуки', 'easy',
//       { 1: ['optical_dyslexia', '1_hear_letter', 'easy',
//         HearTask(TaskType: 'optical_dyslexia', TaskName: '1_hear_letter', TaskDifficulty: 'easy', flag: 'lesson',
//             lessonInfo: ['1', '1', DateTime.now()])],
//         2: ['optical_dyslexia', '1_hear_letter', 'easy',
//           HearTask(TaskType: 'optical_dyslexia', TaskName: '1_hear_letter', TaskDifficulty: 'easy', flag: 'lesson',
//               lessonInfo: ['1', '2', DateTime.now()])],
//         3: ['optical_dyslexia', '1_hear_letter', 'easy',
//           HearTask(TaskType: 'optical_dyslexia', TaskName: '1_hear_letter', TaskDifficulty: 'easy', flag: 'lesson',
//               lessonInfo: ['1', '3', DateTime.now()])],
//         // 4: ['optical_dyslexia', '2_insert_letter', 'easy',
//         //   HearTask(TaskType: 'optical_dyslexia', TaskName: '2_insert_letter', TaskDifficulty: 'easy', flag: 'lesson',
//         //       lessonInfo: ['1', '4', DateTime.now()])],
//         // 3: ['optical_dyslexia', '2_insert_letter', 'easy'],
//         // 4: ['optical_dyslexia', '2_insert_letter', 'easy']
//       }),
// ];

class HearListScreen extends StatefulWidget {
  const HearListScreen({super.key});


  @override
  State<HearListScreen> createState() => HearListScreenState();
}

class HearListScreenState extends State<HearListScreen> {
  int selectedTileIndex = -1;

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
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            fit: StackFit.expand,
            children: [

              Image.asset(
                "assets/images/audio_back.png",
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
                    'Темы',
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
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                    itemCount: LessonGroups['optical_dyslexia']!.keys.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.10,
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Color(0xffB8B5FF), // Colors.blue,
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
                                child: Image.asset('assets/icons/${LessonGroups['optical_dyslexia'][LessonGroups['optical_dyslexia']!.keys.toList()[index]]['task_type']}.png'),
                              ),

                              title: Text(LessonGroups['optical_dyslexia']!.keys.toList()[index]),
                              onTap: () {
                                setState(() {
                                  if (selectedTileIndex == index) {
                                    selectedTileIndex = -1; // закрыть открытый элемент
                                  } else {
                                    selectedTileIndex = index; // открыть выбранный элемент
                                  }
                                });
                                },
                      ))),
                      if (selectedTileIndex == index)
                        Padding(padding: const EdgeInsets.all(16.0),
                            child:
                            ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                  itemCount: LessonGroups['optical_dyslexia']![LessonGroups['optical_dyslexia']!.keys.toList()[index]]!['tasks']!.keys.length,
                                  itemBuilder: (BuildContext context, int task_index) {

                                    return Column(
                                        children: [
                                          Container(
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
                                                  ),],
                                              ),
                                              child: Center(
                                                  child: ListTile(
                                                      title: Text('${task_index == 0 ? 'Простой' : (task_index == 1 ? 'Средний' : 'Сложный')} уровень заданий'),
                                                      subtitle: Row(children: [
                                                        for (int i = 0; i < task_index + 1; i++)
                                                          Icon(
                                                            Icons.star,
                                                            color: Color(0xffFAD657),
                                                            size: 20,
                                                          )]),

                                                      trailing: FutureBuilder<double>(
                                                        future: FirestoreService().TasksDonePercent(getUserId(), 'optical_dyslexia',
                                                            LessonGroups['optical_dyslexia']![LessonGroups['optical_dyslexia']!.keys.toList()[index]]!['task_type'],
                                                            Levels[task_index]),
                                                            // LessonGroups['optical_dyslexia']![LessonGroups['optical_dyslexia']!.keys.toList()[index]]![task_index].TaskType),
                                                        builder: (context, snapshot) {
                                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                                            return CircularProgressIndicator();
                                                          }
                                                          else {
                                                            print(snapshot.data);
                                                            return Container(
                                                                width: 100, child:LinearProgressIndicator(value: snapshot.data ?? 0.0,
                                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                                    snapshot.data == 1
                                                                        ? Colors.green : snapshot.data == 0 ? Colors.grey : Colors.orange // Оранжевый цвет для остальных значений
                                                                )));
                                                          }
                                                          },
                                                      ),
                                                      onTap: () {
                                                        print( LessonGroups['optical_dyslexia']![LessonGroups['optical_dyslexia']!
                                                            .keys.toList()[index]]!['tasks']);
                                                        print(LessonGroups['optical_dyslexia']![LessonGroups['optical_dyslexia']!.keys.toList()[index]]!['tasks']!.keys.length);
                                                        setState(() {
                                                          Navigator.push(context,
                                                              MaterialPageRoute(
                                                                  builder: ((context) => TaskDetailScreen(TaskItem('optical_dyslexia',
                                                                  LessonGroups['optical_dyslexia'][LessonGroups['optical_dyslexia']!.keys.toList()[index]]['task_type'],
                                                                      Levels[task_index]),
                                                                      LessonGroups['optical_dyslexia']![LessonGroups['optical_dyslexia']!
                                                                      .keys.toList()[index]]!['tasks'][task_index]!
                                                                  ))
                                                          ));
                                                        });
                                                      })))]
                                    );
                                  })
                        ),
                      ]);
                    })
              )]
        )
    );}
}



class TaskDetailScreen extends StatefulWidget {
  final TaskItem taskItem;
  final your_widget;

  TaskDetailScreen(this.taskItem, this.your_widget); // this.hearTask

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  int currentLessonIndex = 0;
  bool change = false;
  bool isCorrect = false;
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

  @override
  void initState() {
    super.initState();
    _handleGameUpdate();
  }

  void _handleGameUpdate() {
    setState(() {
      change = false;
      currentLessonIndex = -1;
    });
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        change = true;
        currentLessonIndex = 0;
      });
    });
  }

  UserInfo() {
    Map userInfo = getUserId();
    String userId = userInfo['userId']!;
    String email = userInfo['email']!;

    UserTask3 user_task = UserTask3(
      userId: userId,
      email: email,
      taskName: widget.taskItem.TaskName,
      taskDifficulty: widget.taskItem.TaskDifficulty,
      date: DateTime.now(),
    );
    return user_task;
  }

  Widget YourWidget() {
    return widget.your_widget..onGameUpdate = _handleGameUpdate;
    //(onGameUpdate: _handleGameUpdate);
  }

  @override
  Widget build(BuildContext context) {
    print('Наш индекс');
    print(currentLessonIndex);
    // print(widget.lessonItem.tasks[currentLessonIndex]);
    if (change == false)
      return Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          ));

    else return
      YourWidget();
  }
}

class AgrammListScreen extends StatefulWidget {
  const AgrammListScreen({super.key});

  @override
  State<AgrammListScreen> createState() => _AgrammListScreenState();
}

class _AgrammListScreenState extends State<AgrammListScreen> {
  int selectedTileIndex = -1;

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
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            fit: StackFit.expand,
            children: [

              Image.asset(
                "assets/images/agrammatism_back.png",
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
                    'Темы',
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
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: LessonGroups['agrammatism']!.keys.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            Container(
                                height: MediaQuery.of(context).size.height * 0.10,
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: Color(0xffFFB59D), // Colors.blue,
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
                                        child: Image.asset('assets/icons/${LessonGroups['agrammatism'][LessonGroups['agrammatism']!.keys.toList()[index]]['task_type']}.png'),
                                      ),

                                      title: Text(LessonGroups['agrammatism']!.keys.toList()[index]),
                                      onTap: () {
                                        setState(() {
                                          if (selectedTileIndex == index) {
                                            selectedTileIndex = -1; // закрыть открытый элемент
                                          } else {
                                            selectedTileIndex = index; // открыть выбранный элемент
                                          }
                                        });
                                      },
                                    ))),
                            if (selectedTileIndex == index)
                              Padding(padding: const EdgeInsets.all(16.0),
                                  child:
                                  ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: LessonGroups['agrammatism']![LessonGroups['agrammatism']!.keys.toList()[index]]!['tasks']!.keys.length,
                                      itemBuilder: (BuildContext context, int task_index) {

                                        return Column(
                                            children: [
                                              Container(
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
                                                      ),],
                                                  ),
                                                  child: Center(
                                                      child: ListTile(
                                                          title: Text('${task_index == 0 ? 'Простой' : (task_index == 1 ? 'Средний' : 'Сложный')} уровень заданий'),
                                                          subtitle: Row(children: [
                                                            for (int i = 0; i < task_index + 1; i++)
                                                              Icon(
                                                                Icons.star,
                                                                color: Color(0xffFAD657),
                                                                size: 20,
                                                              )]),

                                                          trailing: FutureBuilder<double>(
                                                            future: FirestoreService().TasksDonePercent(getUserId(), 'agrammatism',
                                                                LessonGroups['agrammatism']![LessonGroups['agrammatism']!.keys.toList()[index]]!['task_type'],
                                                                Levels[task_index]),
                                                            // LessonGroups['optical_dyslexia']![LessonGroups['optical_dyslexia']!.keys.toList()[index]]![task_index].TaskType),
                                                            builder: (context, snapshot) {
                                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                                return CircularProgressIndicator();
                                                              }
                                                              else {
                                                                print(snapshot.data);
                                                                return Container(
                                                                    width: 100, child:LinearProgressIndicator(value: snapshot.data ?? 0.0,
                                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                                        snapshot.data == 1
                                                                            ? Colors.green : snapshot.data == 0 ? Colors.grey : Colors.orange // Оранжевый цвет для остальных значений
                                                                    )));
                                                              }
                                                            },
                                                          ),
                                                          onTap: () {
                                                            print( LessonGroups['agrammatism']![LessonGroups['agrammatism']!
                                                                .keys.toList()[index]]!['tasks']);
                                                            print(LessonGroups['agrammatism']![LessonGroups['agrammatism']!.keys.toList()[index]]!['tasks']!.keys.length);
                                                            setState(() {
                                                              Navigator.push(context,
                                                                  MaterialPageRoute(
                                                                      builder: ((context) => TaskDetailScreen(TaskItem('agrammatism',
                                                                          LessonGroups['agrammatism'][LessonGroups['agrammatism']!.keys.toList()[index]]['task_type'],
                                                                          Levels[task_index]),
                                                                          LessonGroups['agrammatism']![LessonGroups['agrammatism']!
                                                                              .keys.toList()[index]]!['tasks'][task_index]!
                                                                      ))
                                                                  ));
                                                            });
                                                          })))]
                                        );
                                      })
                              ),
                          ],);
                      })
              )]
        )
    );}
}

class SemanticsListScreen extends StatefulWidget {
  const SemanticsListScreen({super.key});

  @override
  State<SemanticsListScreen> createState() => _SemanticsListScreenState();
}

class _SemanticsListScreenState extends State<SemanticsListScreen> {
  int selectedTileIndex = -1;

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
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            fit: StackFit.expand,
            children: [

              Image.asset(
                "assets/images/semantics_back.png",
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
                    'Темы',
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
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: LessonGroups['semantics']!.keys.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            Container(
                                height: MediaQuery.of(context).size.height * 0.10,
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: Color(0xffFFA945),
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
                                        child: Image.asset('assets/icons/${LessonGroups['semantics'][LessonGroups['semantics']!.keys.toList()[index]]['task_type']}.png'),
                                      ),

                                      title: Text(LessonGroups['semantics']!.keys.toList()[index]),
                                      onTap: () {
                                        setState(() {
                                          if (selectedTileIndex == index) {
                                            selectedTileIndex = -1; // закрыть открытый элемент
                                          } else {
                                            selectedTileIndex = index; // открыть выбранный элемент
                                          }
                                        });
                                      },
                                    ))),
                            if (selectedTileIndex == index)
                              Padding(padding: const EdgeInsets.all(16.0),
                                  child:
                                  ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: LessonGroups['semantics']![LessonGroups['semantics']!.keys.toList()[index]]!['tasks']!.keys.length,
                                      itemBuilder: (BuildContext context, int task_index) {

                                        return Column(
                                            children: [
                                              Container(
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
                                                      ),],
                                                  ),
                                                  child: Center(
                                                      child: ListTile(
                                                          title: Text('${task_index == 0 ? 'Простой' : (task_index == 1 ? 'Средний' : 'Сложный')} уровень заданий'),
                                                          subtitle: Row(children: [
                                                            for (int i = 0; i < task_index + 1; i++)
                                                              Icon(
                                                                Icons.star,
                                                                color: Color(0xffFAD657),
                                                                size: 20,
                                                              )]),

                                                          trailing: FutureBuilder<double>(
                                                            future: FirestoreService().TasksDonePercent(getUserId(), 'semantics',
                                                                LessonGroups['semantics']![LessonGroups['semantics']!.keys.toList()[index]]!['task_type'],
                                                                Levels[task_index]),
                                                            // LessonGroups['optical_dyslexia']![LessonGroups['optical_dyslexia']!.keys.toList()[index]]![task_index].TaskType),
                                                            builder: (context, snapshot) {
                                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                                return CircularProgressIndicator();
                                                              }
                                                              else {
                                                                print(snapshot.data);
                                                                return Container(
                                                                    width: 100, child:LinearProgressIndicator(value: snapshot.data ?? 0.0,
                                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                                        snapshot.data == 1
                                                                            ? Colors.green : snapshot.data == 0 ? Colors.grey : Colors.orange // Оранжевый цвет для остальных значений
                                                                    )));
                                                              }
                                                            },
                                                          ),
                                                          onTap: () {
                                                            // print( LessonGroups['semantics']![LessonGroups['semantics']!
                                                            //     .keys.toList()[index]]!['tasks']);
                                                            // print(LessonGroups['semantics']![LessonGroups['semantics']!.keys.toList()[index]]!['tasks']!.keys.length);
                                                            setState(() {
                                                              Navigator.push(context,
                                                                  MaterialPageRoute(
                                                                      builder: ((context) => TaskDetailScreen(TaskItem('semantics',
                                                                          LessonGroups['semantics'][LessonGroups['semantics']!.keys.toList()[index]]['task_type'],
                                                                          Levels[task_index]),
                                                                          LessonGroups['semantics']![LessonGroups['semantics']!
                                                                              .keys.toList()[index]]!['tasks'][task_index]!
                                                                      ))
                                                                  ));
                                                            });
                                                          })))]
                                        );
                                      })
                              ),
                          ],);
                      })
              )]
        )
    );}
}

class ImageWithListScreen extends StatefulWidget {
  const ImageWithListScreen({super.key});

  @override
  State<ImageWithListScreen> createState() => _ImageWithListScreen();
}

class _ImageWithListScreen extends State<ImageWithListScreen> {
  int selectedTileIndex = -1;

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
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            fit: StackFit.expand,
            children: [

              Image.asset(
                "assets/images/images_back.png",
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
                    'Темы',
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
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: LessonGroups['with_images']!.keys.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            Container(
                                height: MediaQuery.of(context).size.height * 0.10,
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: Color(0xffEAFF67),
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
                                        child: Image.asset('assets/icons/${LessonGroups['with_images'][LessonGroups['with_images']!.keys.toList()[index]]['task_type']}.png'),
                                      ),

                                      title: Text(LessonGroups['with_images']!.keys.toList()[index]),
                                      onTap: () {
                                        setState(() {
                                          if (selectedTileIndex == index) {
                                            selectedTileIndex = -1; // закрыть открытый элемент
                                          } else {
                                            selectedTileIndex = index; // открыть выбранный элемент
                                          }
                                        });
                                      },
                                    ))),
                            if (selectedTileIndex == index)
                              Padding(padding: const EdgeInsets.all(16.0),
                                  child:
                                  ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: LessonGroups['with_images']![LessonGroups['with_images']!.keys.toList()[index]]!['tasks']!.keys.length,
                                      itemBuilder: (BuildContext context, int task_index) {

                                        return Column(
                                            children: [
                                              Container(
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
                                                      ),],
                                                  ),
                                                  child: Center(
                                                      child: ListTile(
                                                          title: Text('${task_index == 0 ? 'Простой' : (task_index == 1 ? 'Средний' : 'Сложный')} уровень заданий'),
                                                          subtitle: Row(children: [
                                                            for (int i = 0; i < task_index + 1; i++)
                                                              Icon(
                                                                Icons.star,
                                                                color: Color(0xffFAD657),
                                                                size: 20,
                                                              )]),

                                                          trailing: FutureBuilder<double>(
                                                            future: FirestoreService().TasksDonePercent(getUserId(), 'with_images',
                                                                LessonGroups['with_images']![LessonGroups['with_images']!.keys.toList()[index]]!['task_type'],
                                                                Levels[task_index]),
                                                            // LessonGroups['optical_dyslexia']![LessonGroups['optical_dyslexia']!.keys.toList()[index]]![task_index].TaskType),
                                                            builder: (context, snapshot) {
                                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                                return CircularProgressIndicator();
                                                              }
                                                              else {
                                                                print(snapshot.data);
                                                                return Container(
                                                                    width: 100, child:LinearProgressIndicator(value: snapshot.data ?? 0.0,
                                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                                        snapshot.data == 1
                                                                            ? Colors.green : snapshot.data == 0 ? Colors.grey : Colors.orange // Оранжевый цвет для остальных значений
                                                                    )));
                                                              }
                                                            },
                                                          ),
                                                          onTap: () {
                                                            print( LessonGroups['with_images']![LessonGroups['with_images']!
                                                                .keys.toList()[index]]!['tasks']);
                                                            print(LessonGroups['with_images']![LessonGroups['with_images']!.keys.toList()[index]]!['tasks']!.keys.length);
                                                            setState(() {
                                                              Navigator.push(context,
                                                                  MaterialPageRoute(
                                                                      builder: ((context) => TaskDetailScreen(TaskItem('with_images',
                                                                          LessonGroups['with_images'][LessonGroups['with_images']!.keys.toList()[index]]['task_type'],
                                                                          Levels[task_index]),
                                                                          LessonGroups['with_images']![LessonGroups['with_images']!
                                                                              .keys.toList()[index]]!['tasks'][task_index]!
                                                                      ))
                                                                  ));
                                                            });
                                                          })))]
                                        );
                                      })
                              ),
                          ],);
                      })
              )]
        )
    );}
}

class AgreementListScreen extends StatefulWidget {
  const AgreementListScreen({super.key});

  @override
  State<AgreementListScreen> createState() => _AgreementListScreen();
}

class _AgreementListScreen extends State<AgreementListScreen> {
  int selectedTileIndex = -1;

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
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            fit: StackFit.expand,
            children: [

              Image.asset(
                "assets/images/agreement_back.png",
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
                    'Темы',
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
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: LessonGroups['agreement']!.keys.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            Container(
                                height: MediaQuery.of(context).size.height * 0.10,
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: Color(0xffFFF067),
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
                                        child: Image.asset('assets/icons/${LessonGroups['agreement'][LessonGroups['agreement']!.keys.toList()[index]]['task_type']}.png'),
                                      ),

                                      title: Text(LessonGroups['agreement']!.keys.toList()[index]),
                                      onTap: () {
                                        setState(() {
                                          if (selectedTileIndex == index) {
                                            selectedTileIndex = -1; // закрыть открытый элемент
                                          } else {
                                            selectedTileIndex = index; // открыть выбранный элемент
                                          }
                                        });
                                      },
                                    ))),
                            if (selectedTileIndex == index)
                              Padding(padding: const EdgeInsets.all(16.0),
                                  child:
                                  ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: LessonGroups['agreement']![LessonGroups['agreement']!.keys.toList()[index]]!['tasks']!.keys.length,
                                      itemBuilder: (BuildContext context, int task_index) {

                                        return Column(
                                            children: [
                                              Container(
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
                                                      ),],
                                                  ),
                                                  child: Center(
                                                      child: ListTile(
                                                          title: Text('${task_index == 0 ? 'Простой' : (task_index == 1 ? 'Средний' : 'Сложный')} уровень заданий'),
                                                          subtitle: Row(children: [
                                                            for (int i = 0; i < task_index + 1; i++)
                                                              Icon(
                                                                Icons.star,
                                                                color: Color(0xffFAD657),
                                                                size: 20,
                                                              )]),

                                                          trailing: FutureBuilder<double>(
                                                            future: FirestoreService().TasksDonePercent(getUserId(), 'agreement',
                                                                LessonGroups['agreement']![LessonGroups['agreement']!.keys.toList()[index]]!['task_type'],
                                                                Levels[task_index]),
                                                            // LessonGroups['optical_dyslexia']![LessonGroups['optical_dyslexia']!.keys.toList()[index]]![task_index].TaskType),
                                                            builder: (context, snapshot) {
                                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                                return CircularProgressIndicator();
                                                              }
                                                              else {
                                                                print(snapshot.data);
                                                                return Container(
                                                                    width: 100, child:LinearProgressIndicator(value: snapshot.data ?? 0.0,
                                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                                        snapshot.data == 1
                                                                            ? Colors.green : snapshot.data == 0 ? Colors.grey : Colors.orange // Оранжевый цвет для остальных значений
                                                                    )));
                                                              }
                                                            },
                                                          ),
                                                          onTap: () {
                                                            print( LessonGroups['agreement']![LessonGroups['agreement']!
                                                                .keys.toList()[index]]!['tasks']);
                                                            print(LessonGroups['agreement']![LessonGroups['agreement']!.keys.toList()[index]]!['tasks']!.keys.length);
                                                            setState(() {
                                                              Navigator.push(context,
                                                                  MaterialPageRoute(
                                                                      builder: ((context) => TaskDetailScreen(TaskItem('agreement',
                                                                          LessonGroups['agreement'][LessonGroups['agreement']!.keys.toList()[index]]['task_type'],
                                                                          Levels[task_index]),
                                                                          LessonGroups['agreement']![LessonGroups['agreement']!
                                                                              .keys.toList()[index]]!['tasks'][task_index]!
                                                                      ))
                                                                  ));
                                                            });
                                                          })))]
                                        );
                                      })
                              ),
                          ],);
                      })
              )]
        )
    );}
}
