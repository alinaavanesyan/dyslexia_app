import 'package:flutter/material.dart';
import 'package:dyslexia_project/tasks/tasks.dart';
import 'package:dyslexia_project/screens/home_screen.dart';
import 'package:dyslexia_project/screens/themes.dart';
import 'package:dyslexia_project/screens/agrammatism.dart';
import 'package:dyslexia_project/services/database.dart';

get_quantity() {
  FutureBuilder<int>(
    future: FirestoreService().TasksDoneAll(HomeScreen().getUserId(), 'optical_dyslexia'),
    builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasData) {
          int? tasksDone = snapshot.data;
          // Используйте переменную tasksDone для дальнейших действий
          return Text('Tasks Done: $tasksDone');
        } else {
          return Text('Данные не найдены');
        }
      } else {
        return  Text(''); // Или любой другой виджет загрузки
      }
    },
  );


  return FirestoreService().TasksDoneAll(HomeScreen().getUserId(), 'optical_dyslexia');
}
// int optical_res = FirestoreService().TasksDoneAll(HomeScreen().getUserId(), 'optical_dyslexia');

class Product {
  // final String image, title;
  final String title, icon;
  final int id; // courses;
  final Color color;
  final classname;

  Product({
    required this.title,
    required this.icon,
    // required this.courses,
    required this.color,
    required this.id,
    required this.classname,
  });
}

List<Product> products = [
  Product(
    id: 1,
    title: "Буквы и звуки",
    icon: "assets/icons/audio-book.png",
    color: const Color(0xFF9ba0fc),
    // courses: FirestoreService().TasksDoneAll(HomeScreen().getUserId(), 'optical_dyslexia'),
    // classname: HearWriteTask(TaskType: 'optical_dyslexia', TaskName: '2_insert_letter', flag: 'no')
    classname: HearListScreen(),
  ),
  Product(
    id: 2,
    title: "Слоги и морфемы",
    icon: "assets/icons/extra.png",
    color: const Color(0xFFff6374),
    // courses: 22,
    classname: const AgrammListScreen(),
  ),
  // Product(
  //   id: 3,
  //   title: "Paste",
  //   icon: "assets/icons/extra.png",
  //   color: const Color(0xFFff6374),
  //   // courses: 22,
  //   classname: const Task2(),
  // ),

  Product(
    id: 3,
    title: "Значения фраз",
    icon: "assets/icons/question.png",
    color: const Color(0xFFffaa5b),
    // courses: 18,
    classname: const SemanticsListScreen(),
  ),
  Product(
    id: 4,
    title: "Слова и изображения",
    icon: "assets/icons/alphabetical.png",
    color: const Color(0xFF8BC5FF),
    // courses: 15,
    classname: const ImageWithListScreen(),// const Task4(),
  ),
  Product(
    id: 5,
    title: "Согласование",
    icon: "assets/icons/puzzle.png",
    color: const Color(0xFFFFD66B),
    // courses: 16,
    classname: const AgreementListScreen(), // const Task1(),
  ),
];
