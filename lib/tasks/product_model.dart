import 'package:flutter/material.dart';
import 'package:dyslexia_project/screens/home_screen.dart';
import 'package:dyslexia_project/screens/themes.dart';
import 'package:dyslexia_project/services/database.dart';

get_quantity() {
  FutureBuilder<int>(
    future: FirestoreService().TasksDoneAll(HomeScreen().getUserId(), 'optical_dyslexia'),
    builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasData) {
          int? tasksDone = snapshot.data;
          return Text('Tasks Done: $tasksDone');
        } else {
          return Text('Данные не найдены');
        }
      } else {
        return  Text('');
      }
    },
  );
  return FirestoreService().TasksDoneAll(HomeScreen().getUserId(), 'optical_dyslexia');
}

class Product {
  final String title, icon;
  final int id;
  final Color color;
  final classname;

  Product({
    required this.title,
    required this.icon,
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
    classname: HearListScreen(),
  ),
  Product(
    id: 2,
    title: "Слоги и морфемы",
    icon: "assets/icons/extra.png",
    color: const Color(0xFFff6374),
    classname: const AgrammListScreen(),
  ),

  Product(
    id: 3,
    title: "Значения фраз",
    icon: "assets/icons/question.png",
    color: const Color(0xFFffaa5b),
    classname: const SemanticsListScreen(),
  ),
  Product(
    id: 4,
    title: "Слова и изображения",
    icon: "assets/icons/alphabetical.png",
    color: const Color(0xFF8BC5FF),
    classname: const ImageWithListScreen(),// const Task4(),
  ),
  Product(
    id: 5,
    title: "Согласование",
    icon: "assets/icons/puzzle.png",
    color: const Color(0xFFFFD66B),
    classname: const AgreementListScreen(), // const Task1(),
  ),
];
