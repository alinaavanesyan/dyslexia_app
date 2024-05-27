import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dyslexia_project/screens/themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:dyslexia_project/screens/lessons.dart';
import 'package:json_annotation/json_annotation.dart';
// import 'package:dyslexia_project/screens/agrammatism.dart';
import 'package:dyslexia_project/tasks/tasks_data.dart';
// part 'dyslexia_project/tasks/tasks.g.dart';

class UserTask {
  String userId;
  String email;
  List taskNumber;

  UserTask({
    required this.userId,
    required this.email,
    required this.taskNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'UserId': userId,
      'Email': email,
      'TaskNumber': {taskNumber[0].toString(): taskNumber[1]},
      'UsedNumber': 0,
    };
  }
}

class UserTask2 {
  String userId;
  String email;
  int taskNumber;
  DateTime date;
  bool wrong_answer;
  bool correct_answer;

  UserTask2({
    required this.userId,
    required this.email,
    required this.taskNumber,
    required this.date,
    required this.wrong_answer,
    required this.correct_answer,
  });

  Map<String, dynamic> toMap() {
    if (wrong_answer == true) {
      return {
        'UserId': userId,
        'Email': email,
        'TaskNumber': { taskNumber.toString(): {'done': false, 'done_date': null, 'errors': [date], 'complexity': null} }
    };
    }
    else {
      return {
        'UserId': userId,
        'Email': email,
        'TaskNumber': { taskNumber.toString(): {'done': true, 'done_date': date, 'errors': [] , 'complexity': null} }
    };
  }
}}

class UserTask3 {
  String userId;
  String email;
  String taskName;
  String taskDifficulty;
  int? taskNumber;
  DateTime date;
  bool? wrong_answer;
  bool? correct_answer;

  UserTask3({
    required this.userId,
    required this.email,
    required this.taskName,
    required this.taskDifficulty,
    this.taskNumber,
    required this.date,
    this.wrong_answer,
    this.correct_answer,
  });

  Map<String, dynamic> toMap() {
    if (wrong_answer == true) {
      return {
        'UserId': userId,
        'Email': email,
        'TaskName': { taskName: { taskDifficulty: {
          taskNumber.toString(): {
            'done': false,
            'done_date': null,
            'errors': [date]
          }
        }}}
      };
    }
    else {
      return {
        'UserId': userId,
        'Email': email,
        'TaskName': { taskName: { taskDifficulty: {
          taskNumber.toString(): {'done': true, 'done_date': date, 'errors': []}
        }}}
      };
    }
  }

  Map<String, dynamic> toMapUpdate() {
    if (wrong_answer == true) {
      return {
        taskNumber.toString(): {
          'done': false,
          'done_date': null,
          'errors': [date]
        }
      };
    }
    else {
      return {
      taskNumber.toString(): {
        'done': true, 'done_date': date, 'errors': []
      }};
    }
  }
}

class FirestoreService {
  final CollectionReference MatchUsersCollection = FirebaseFirestore.instance
      .collection('match_users');

  final CollectionReference PasteUsersCollection = FirebaseFirestore.instance
      .collection('paste_users');

  final CollectionReference HearUsersCollection = FirebaseFirestore.instance
      .collection('hear_letter_users');

  final CollectionReference ChooseUsersCollection = FirebaseFirestore.instance
      .collection('choose_option_users');

  final CollectionReference usersPasswordsCollection = FirebaseFirestore.instance
      .collection('passwords_storage');

  final CollectionReference OpticalUsersCollection = FirebaseFirestore.instance
      .collection('optical_dyslexia');

  final CollectionReference OpticalUsersCollectionLesson = FirebaseFirestore.instance
      .collection('optical_dyslexia_lesson');

  final CollectionReference AgrammatismUsersCollection = FirebaseFirestore.instance
      .collection('agrammatism');

  final CollectionReference AgrammatismUsersCollectionLesson = FirebaseFirestore.instance
      .collection('agrammatism_lesson');

  final CollectionReference SemanticsUsersCollection = FirebaseFirestore.instance
      .collection('semantics');

  final CollectionReference SemanticsUsersCollectionLesson = FirebaseFirestore.instance
      .collection('semantics_lesson');

  final CollectionReference ImagesWithUsersCollection = FirebaseFirestore.instance
      .collection('with_images');

  final CollectionReference ImagesWithUsersCollectionLesson = FirebaseFirestore.instance
      .collection('with_images_lesson');

  final CollectionReference AgreementUsersCollection = FirebaseFirestore.instance
      .collection('agreement');

  final CollectionReference AgreementUsersCollectionLesson = FirebaseFirestore.instance
      .collection('agreement_lesson');

  final CollectionReference LessonsStatCollection = FirebaseFirestore.instance
      .collection('lessons_stat');

  final CollectionReference TextsUsersCollection = FirebaseFirestore.instance
      .collection('texts');


  MatchGameUpdate(UserTask user) async {
    final userDocument = await MatchUsersCollection.doc(user.userId).get();

    if (userDocument.exists) {
      Map existingTaskNumber;
      dynamic data = userDocument.data();
      if (data != null && data is Map<String, dynamic>) {
        existingTaskNumber = data['TaskNumber'];
        if (!existingTaskNumber.containsKey(user.taskNumber[0].toString())) {
          existingTaskNumber[user.taskNumber[0].toString()] = user.taskNumber[1];
          MatchUsersCollection.doc(user.userId).update(
              {'TaskNumber': existingTaskNumber}).then((value) =>
              print("User Added"));
        }
      } else {
        return MatchUsersCollection.doc(user.userId).set(user.toMap())
            .then((value) => print("User Added"));
      }
    }
    else {
      print('no');
      print({user.taskNumber[0]: user.taskNumber[1]});
      return MatchUsersCollection.doc(user.userId).set(user.toMap())
          .then((value) => print("User Added"));
    }
  }

  PasteGameUpdate(UserTask user) async {
    final userDocument = await PasteUsersCollection.doc(user.userId).get();

    if (userDocument.exists) {
      Map existingTaskNumber;
      dynamic data = userDocument.data();
      if (data != null && data is Map<String, dynamic>) {
        existingTaskNumber = data['TaskNumber'];
        if (!existingTaskNumber.containsKey(user.taskNumber[0].toString())) {
          existingTaskNumber[user.taskNumber[0].toString()] = user.taskNumber[1];
          PasteUsersCollection.doc(user.userId).update(
              {'TaskNumber': existingTaskNumber}).then((value) =>
              print("User Added"));
        }
      } else {
        return PasteUsersCollection.doc(user.userId).set(user.toMap())
            .then((value) => print("User Added"));
      }
    }
    else {
      print('no');
      print({user.taskNumber[0]: user.taskNumber[1]});
      return PasteUsersCollection.doc(user.userId).set(user.toMap())
          .then((value) => print("User Added"));
    }
  }

  HearGameUpdate(UserTask2 user) async {
    final userDocument = await HearUsersCollection.doc(user.userId).get();
    if (userDocument.exists) {
      Map existingTaskNumber;
      dynamic data = userDocument.data();
        existingTaskNumber = data['TaskNumber'];
        if (!existingTaskNumber.containsKey(user.taskNumber.toString())) {
          return HearUsersCollection.doc(user.userId).set(user.toMap())
              .then((value) => print("User Added"));
        }
        else {
              if (user.wrong_answer == true) {
                existingTaskNumber[user.taskNumber.toString()]['errors'].add(user.date);
                HearUsersCollection.doc(user.userId).update(
                    {'TaskNumber': existingTaskNumber}).then((value) =>
                    print("User Added"));
              }
              else {
                existingTaskNumber[user.taskNumber.toString()]['done'] = true;
                existingTaskNumber[user.taskNumber.toString()]['done_date'] = user.date;
                HearUsersCollection.doc(user.userId).update(
                    {'TaskNumber': existingTaskNumber}).then((value) =>
                    print("User Added"));
              }
            }
    }
        else {
          return HearUsersCollection.doc(user.userId).set(user.toMap())
              .then((value) => print("User Added"));
        }
  }

  HearGameUpdate2(UserTask3 user) async {
    final userDocument = await OpticalUsersCollection.doc(user.userId).get();
    if (userDocument.exists) {
      Map existingTaskNumber;
      dynamic data = userDocument.data();
      existingTaskNumber = data['TaskNumber'];
      if (!existingTaskNumber.containsKey(user.taskNumber.toString())) {
        return HearUsersCollection.doc(user.userId).set(user.toMap())
            .then((value) => print("User Added"));
      }
      else {
        if (user.wrong_answer == true) {
          existingTaskNumber[user.taskNumber.toString()]['errors'].add(user.date);
          HearUsersCollection.doc(user.userId).update(
              {'TaskNumber': existingTaskNumber}).then((value) =>
              print("User Added"));
        }
        else {
          existingTaskNumber[user.taskNumber.toString()]['done'] = true;
          existingTaskNumber[user.taskNumber.toString()]['done_date'] = user.date;
          HearUsersCollection.doc(user.userId).update(
              {'TaskNumber': existingTaskNumber}).then((value) =>
              print("User Added"));
        }
      }
    }
    else {
      return HearUsersCollection.doc(user.userId).set(user.toMap())
          .then((value) => print("User Added"));
    }
  }

  GameUpdate(UserTask2 user, task_type) async {
    DocumentSnapshot userDocument;

    if (task_type == 'hear_letter') {
      userDocument = await HearUsersCollection.doc(user.userId).get();
    }
    else if (task_type == 'choose_option') {
      userDocument = await ChooseUsersCollection.doc(user.userId).get();
    }
    else {
      userDocument = await HearUsersCollection.doc(user.userId).get();
    }

    if (userDocument.exists) {
      Map existingTaskNumber;
      dynamic data = userDocument.data();
      existingTaskNumber = data['TaskNumber'];
      if (!existingTaskNumber.containsKey(user.taskNumber.toString())) {
        return HearUsersCollection.doc(user.userId).set(user.toMap())
            .then((value) => print("User Added"));
      }
      else {
        if (user.wrong_answer == true) {
          existingTaskNumber[user.taskNumber.toString()]['errors'].add(user.date);
          HearUsersCollection.doc(user.userId).update(
              {'TaskNumber': existingTaskNumber}).then((value) =>
              print("User Added"));
        }
        else {
          existingTaskNumber[user.taskNumber.toString()]['done'] = true;
          existingTaskNumber[user.taskNumber.toString()]['done_date'] = user.date;
          HearUsersCollection.doc(user.userId).update(
              {'TaskNumber': existingTaskNumber}).then((value) =>
              print("User Added"));
        }
      }
    }
    else {
      return HearUsersCollection.doc(user.userId).set(user.toMap())
          .then((value) => print("User Added"));
    }
  }

  List<String> levels = ['easy', 'middle', 'high'];

  GameUpdate2(UserTask3 user, task_type, flag) async {
    Random random = Random();
    int index = random.nextInt(levels.length);
    final level = user.taskDifficulty == 'any' ? levels[index] : user.taskDifficulty;

    DocumentSnapshot userDocument;

    var collection =  FirebaseFirestore.instance.collection(flag == 'lesson' ? '${task_type}_lesson' : task_type);
    userDocument = await collection.doc(user.userId).get();

    if (userDocument.exists) {
      Map existingTaskNumber;
      dynamic data = userDocument.data();
      final DocumentReference docRef = collection.doc(user.userId);
      if (data['TaskName'].containsKey(user.taskName)) {
        if (data['TaskName'][user.taskName].containsKey(level)) {
          existingTaskNumber =
          data['TaskName'][user.taskName][level];
          if (!existingTaskNumber.containsKey(user.taskNumber.toString())) {
            docRef.update({
              'TaskName.${user.taskName}.${level}.${user
                  .taskNumber.toString()}': user.toMapUpdate()[user.taskNumber
                  .toString()],
            });
          }
          else {
            if (user.wrong_answer == true) {
              existingTaskNumber[user.taskNumber.toString()]['errors'].add(
                  user.date);
              var existing_map = data['TaskName'][user.taskName][level];
              docRef.update({
                'TaskName.${user.taskName}.${level}': existingTaskNumber,
              });
            }
            else {
              existingTaskNumber[user.taskNumber.toString()]['done'] = true;
              existingTaskNumber[user.taskNumber.toString()]['done_date'] =
                  user.date;
              var existing_map = data['TaskName'][user.taskName][level];
              final DocumentReference docRef = collection.doc(
                  user.userId);
              docRef.update({
                'TaskName.${user.taskName}.${level}': existingTaskNumber,
              });
            }
          }
        }
        else {
          docRef.update({
            'TaskName.${user.taskName}.${level}.${user.taskNumber
                .toString()}': user.toMapUpdate()[user.taskNumber.toString()],
          });
        }
      }
      else {
        docRef.update({
          'TaskName.${user.taskName}.${level}.${user.taskNumber.toString()}': user.toMapUpdate()[user.taskNumber.toString()],
        });
      }

    }
    else {
      return collection.doc(user.userId).set(user.toMap())
          .then((value) => print("User Added"));
    }
  }

  LessonsStatUpdate(UserInfo, LessonInfo, TaskType, TaskName, TaskDifficulty, uniqueId) async {
    var LessonIndex = LessonInfo[0];
    var TaskIndex = LessonInfo[1];
    var Date = LessonInfo[2];
    DocumentSnapshot userDocument;
    userDocument = await LessonsStatCollection.doc(UserInfo['userId']).get();
    if (userDocument.exists) {
      print('Файл есть');
      dynamic data = userDocument.data();
      final DocumentReference docRef = LessonsStatCollection.doc(UserInfo['userId']);
      docRef.update({
        'Lessons.${LessonIndex}.${TaskIndex}':
        {'id': uniqueId, 'date': Date, 'taskType': TaskType, 'taskName': TaskName, 'taskDifficulty': TaskDifficulty},
      });
    }
    else {
      var data = {'UserId': UserInfo['userId'], 'Email': UserInfo['email'], 'Lessons': {LessonIndex: {TaskIndex:
      {'id': uniqueId, 'date': Date, 'taskType': TaskType, 'taskName': TaskName, 'taskDifficulty': TaskDifficulty},
      }}};
      return LessonsStatCollection.doc(UserInfo['userId']).set(data)
          .then((value) => print("User Added"));
    }
  }

  LessonCheck(UserInfo, LessonIndex, TaskIndex) async {
    DocumentSnapshot userDocument;
    userDocument = await LessonsStatCollection.doc(UserInfo['userId']).get();
    if (userDocument.exists) {
      dynamic data = userDocument.data();
      if (data['Lessons'].containsKey(LessonIndex.toString())) {
        print('LessonCheck ключ урока $TaskIndex есть');
        if (data['Lessons'][LessonIndex.toString()].containsKey(TaskIndex.toString())) {
          return 'yes';
        }
        else {
          print('LessonCheck ключа задания нет');
          return 'no';
        }
      }
      else {
        return 'no';
      }
    }
    else {
      return 'no';
    }
  }

  LessonCheck2(UserInfo, LessonIndex) async {
    DocumentSnapshot userDocument;

    userDocument = await LessonsStatCollection.doc(UserInfo['userId']).get();
    if (userDocument.exists) {
      dynamic data = userDocument.data();
      print('LessonCheck файл есть');
      if (data['Lessons'].length != 0) {
      if (data['Lessons'].containsKey(LessonIndex.toString())) {
        print('LessonCheck ключ урока $LessonIndex есть');
        var existing_tasks = data['Lessons'][LessonIndex.toString()].keys;
        return existing_tasks;
      }
      else {
        return [];
      }}
      else {
        return [];
      }
    }
    else {
      return [];
    }
  }

  LessonDeleteInfo(UserInfo, LessonIndex) async {
    DocumentSnapshot userDocument;
    userDocument = await LessonsStatCollection.doc(UserInfo['userId']).get();
    final DocumentReference docRef = LessonsStatCollection.doc(UserInfo['userId']);

    if (userDocument.exists) {
      dynamic data = userDocument.data();
      if (data['Lessons'].containsKey(LessonIndex.toString())) {
        var info = data['Lessons'][LessonIndex.toString()];
        print('Ключи ${info.keys}');
        for (String key in info.keys) {
          var userDocument2 = await FirebaseFirestore.instance.collection('${info[key]['taskType']}_lesson').doc(UserInfo['userId']).get();
          final DocumentReference docRef2 = await FirebaseFirestore.instance.collection('${info[key]['taskType']}_lesson').doc(UserInfo['userId']);
          dynamic info2 = userDocument2.data();
          docRef2.update({
            'TaskName.${info[key]['taskName']}.${info[key]['taskDifficulty']}.${info[key]['id']}': FieldValue.delete(),
          });
        }

        docRef.update({
          'Lessons.${LessonIndex}': FieldValue.delete(),
        });
      }
    }
    else {
    }
  }

  TaskDeleteInfo(UserInfo, TaskType, TaskName, TaskDifficulty) async {
    DocumentSnapshot userDocument;
    var collection =  FirebaseFirestore.instance.collection(TaskType);
    userDocument = await collection.doc(UserInfo['userId']).get();
    final DocumentReference docRef = collection.doc(UserInfo['userId']);
    if (userDocument.exists) {
      dynamic data = userDocument.data();
      if (data['TaskName'].containsKey(TaskName)) {
        if (data['TaskName'][TaskName].containsKey(TaskDifficulty)) {
          docRef.update({
            'TaskName.${TaskName}': FieldValue.delete(),
          });
          print('удалено');
        }
      }
    }
    else {
    }
  }

  Future<double> LessonsDonePercent(UserInfo, LessonIndex, LessonAll) async {
    print('LessonsDonePercent $LessonIndex');
    DocumentSnapshot userDocument;
    userDocument = await LessonsStatCollection.doc(UserInfo['userId']).get();
    if (userDocument.exists) {
      print('Файл есть');
      dynamic data = userDocument.data();
      if (data['Lessons'].containsKey(LessonIndex.toString())) {
        var done = data['Lessons'][LessonIndex.toString()].length;
        return done / LessonAll;
      }
      else {
        return 0.0;
      }
    }
    else {
      return 0.0;
    }
  }

  Future<int> LessonsDoneQuantity(UserInfo, LessonAll) async {
    DocumentSnapshot userDocument;
    userDocument = await LessonsStatCollection.doc(UserInfo['userId']).get();
    var lesson_count = 0;
    if (userDocument.exists) {
      print('Файл есть');
      dynamic data = userDocument.data();
      for (int i = 0; i < lessonItems.length; i++){
          if (data['Lessons'].containsKey(i.toString())) {
            if (data['Lessons'][i.toString()].keys.length ==
                lessonItems[i].tasks.length) {
              lesson_count++;
            }
        }
      }
      return lesson_count;
    }
    else {
      return 0;
    }
  }

  Future<double> TasksDonePercent(UserInfo, TaskType, TaskName, Level) async {
    print('TasksDonePercent $TaskType $TaskName $Level');
    DocumentSnapshot userDocument;
    var collection =  FirebaseFirestore.instance.collection(TaskType);
    userDocument = await collection.doc(UserInfo['userId']).get();

    if (userDocument.exists) {
      dynamic data = userDocument.data();
      final DocumentReference docRef = collection.doc(UserInfo['userId']);
      if (data['TaskName'].containsKey(TaskName)) {
        if (data['TaskName'][TaskName].containsKey(Level)) {
          final existing_dict = data['TaskName'][TaskName][Level];
          var done_tasks = 0;
          for (int i = 0; i < existing_dict.keys.length; i++){
            if (existing_dict[existing_dict.keys.toList()[i]]['done'] == true){
              done_tasks++;
            }
          }
          var all_count = parsedJson[TaskType][TaskName][Level].keys.length;
          return done_tasks / all_count;
        }
      else {
        return 0.0;
      }
    }
    else {
      return 0.0;
    }
    }
    else {
      return 0.0;
    }
  }

  TasksDoneAll(UserInfo, TaskType) async {
    print('TasksDonePercent $TaskType');
    DocumentSnapshot userDocument;
    var collection = FirebaseFirestore.instance.collection(TaskType);
    userDocument = await collection.doc(UserInfo['userId']).get();

    if (userDocument.exists) {
      dynamic data = userDocument.data();
      final DocumentReference docRef = collection.doc(UserInfo['userId']);
      var done_tasks = 0;
      for (String TaskName in data['TaskName'].keys) {
        for (String Level in data['TaskName'][TaskName]) {
          for (String Task in data['TaskName'][TaskName][Level]) {
            if (data['TaskName'][TaskName][Level][Task]['done'] == true) {
              done_tasks++;
            }
          }
        }
      }
      return done_tasks;
    }
    else {
        return 0;
    }
  }

  chooseRandomNumber(User user, parsedJson, task_type) async {
    Random random = Random();
    int? randomNumber;
    final userDocument = await FirebaseFirestore.instance.collection(task_type + '_users').doc(user!.uid).get();
    if (userDocument.exists) {
      dynamic data = userDocument.data();
      var existingTaskNumber = data['TaskNumber'];
      if (existingTaskNumber.length == parsedJson['tasks'][task_type].length) {
        return -1;
      }
      else {
        do {
          randomNumber = random.nextInt(parsedJson['tasks'][task_type].length) + 1;
        } while (existingTaskNumber.containsKey(randomNumber));
        return randomNumber;
      }
    }
    else {
      randomNumber = random.nextInt(parsedJson['tasks'][task_type].length) + 1;
      return randomNumber;
    }
  }

  chooseRandomNumber2(User user, parsedJson, task_type) async {
    Random random = Random();
    int? randomNumber;
    final userDocument = await FirebaseFirestore.instance.collection(task_type + '_users').doc(user!.uid).get();
    if (userDocument.exists) {
      dynamic data = userDocument.data();
      var existingTaskNumber = data['TaskNumber'];
      if (existingTaskNumber.length == parsedJson['tasks'][task_type].length) {
        var flag = true;
        for (String i in existingTaskNumber.keys){
          if (existingTaskNumber[i]['done'] == false){
            flag = false;
            return int.tryParse(i);
          }
        }
        if (flag == true) {
          return -1;
        }
      }
      else {
        do {
          randomNumber = random.nextInt(parsedJson['tasks'][task_type].length) + 1;
        } while (existingTaskNumber.containsKey(randomNumber.toString()));
        return randomNumber;
      }
    }
    else {
      randomNumber = random.nextInt(parsedJson['tasks'][task_type].length) + 1;
      return randomNumber;
    }
  }


  chooseRandomNumber3(User user, parsedJson, task_type, task_name, task_difficulty) async {
    Random random = Random();
    int? randomNumber;
    final userDocument = await FirebaseFirestore.instance.collection(task_type + '_users').doc(user!.uid).get();
    if (userDocument.exists) {
      dynamic data = userDocument.data();
      var existingTaskNumber = data['TaskNumber'];
      print(data['TaskNumber'].keys);
      if (existingTaskNumber.length == parsedJson['tasks'][task_type].length) {
        var flag = true;
        for (String i in existingTaskNumber.keys){
          if (existingTaskNumber[i]['done'] == false){
            flag = false;
            return int.tryParse(i);
          }
        }
        if (flag == true) {
          return -1;
        }
      }
      else {
        do {
          randomNumber = random.nextInt(parsedJson['tasks'][task_type].length) + 1;
        } while (existingTaskNumber.containsKey(randomNumber.toString()));
        return randomNumber;
      }
    }
    else {
      randomNumber = random.nextInt(parsedJson['tasks'][task_type].length) + 1;
      return randomNumber;
    }
  }

  chooseRandomNumber4(UserTask3 user, parsedJson, task_type, flag) async {
    Random random = Random();
    int? randomNumber;

    int index = random.nextInt(levels.length);
    final level = user.taskDifficulty == 'any' ? levels[index] : user.taskDifficulty;

    final userDocument = await FirebaseFirestore.instance.collection(flag == 'lesson' ? '${task_type}_lesson' : task_type).doc(user!.userId).get();
    if (userDocument.exists) {
      dynamic data = userDocument.data();
      if (data['TaskName'].containsKey(user.taskName)) {
        if (data['TaskName'][user.taskName].containsKey(level)) {
        var existingTaskNumber = data['TaskName'][user.taskName][level];
        if (existingTaskNumber.length == parsedJson[task_type][user.taskName][level].length) {
          var flag = true;
          for (String i in existingTaskNumber.keys){
            if (existingTaskNumber[i]['done'] == false){
              flag = false;
              return int.tryParse(i);
            }
          }
          if (flag == true) {
            return -1;
          }
        }
        else {
          do {
            randomNumber = random.nextInt(parsedJson[task_type][user.taskName][level].length) + 1;
          } while (existingTaskNumber.containsKey(randomNumber.toString()));
          return randomNumber;
        }
      }
        else {
          randomNumber = random.nextInt(parsedJson[task_type][user.taskName][level].length) + 1;
          return randomNumber;
        }
      }
      else {
        randomNumber = random.nextInt(parsedJson[task_type][user.taskName][level].length) + 1;
        return randomNumber;
      }
    }
    else {
      randomNumber = random.nextInt(parsedJson[task_type][user.taskName][level].length) + 1;
      return randomNumber;
    }
  }

  getPassword(User user) async {
    final userDocument = await usersPasswordsCollection.doc(user!.uid).get();
    if (userDocument.exists) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(
          'passwords_storage').doc(user!.uid).get();
      String password = userDoc.get('Password');
      return password;
    }
  }

  updatePassword(User user, new_pass) async {
    final userDocument = await usersPasswordsCollection.doc(user!.uid).get();

    if (userDocument.exists) {
      usersPasswordsCollection.doc(user!.uid).update(
          {'Password': new_pass,
            'Email': user!.email}).then((value) => print("Password Updated"));
    } else {
      return
        usersPasswordsCollection.doc(user!.uid).set({
          'Password': new_pass,
          'Email': user!.email
        })
            .then((value) => print("Password Added"));
    }
  }


  updateGoogleEmail(user) async {
    final userDocument = await usersPasswordsCollection.doc(user!.uid).get();

    if (userDocument.exists) {
      usersPasswordsCollection.doc(user!.uid).update(
          {'Email': user!.email}).then((value) => print("Email Updated"));
    } else {
      return
        usersPasswordsCollection.doc(user!.uid).set({
          'Email': user!.email
        })
            .then((value) => print("Password Added"));
    }
  }
}
