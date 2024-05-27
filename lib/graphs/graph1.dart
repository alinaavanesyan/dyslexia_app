import 'dart:async';
import 'dart:math';
// import 'package:fl_chart_app/presentation/resources/app_resources.dart';
// import 'package:fl_chart_app/util/extensions/color_extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dyslexia_project/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:dyslexia_project/screens/lessons.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dyslexia_project/tasks/tasks_data.dart';
import 'dart:convert';

final parsedJson = jsonDecode(jsonData);

class BarChartSample1 extends StatefulWidget {
  BarChartSample1({super.key});

  List<Color> get availableColors => const <Color>[
    Color(0xffF6C0FB),
    // Color(0xff4A98BB),
    // Color(0xff4A98BB),
    // Color(0xff4A98BB)
    //     AppColors.contentColorPurple,
    //     AppColors.contentColorYellow,
    //     AppColors.contentColorBlue,
    //     AppColors.contentColorOrange,
    //     AppColors.contentColorPink,
    //     AppColors.contentColorRed,
      ];

  final Color barBackgroundColor =
  Color(0xffF6C0FB);
      // AppColors.contentColorWhite.darken().withOpacity(0.3);
  final Color barColor = Color(0xff4301FF);
      // AppColors.contentColorWhite;
  final Color touchedBarColor = Color(0xffEB01FF);

  @override
  State<StatefulWidget> createState() => BarChartSample1State();
}

class BarChartSample1State extends State<BarChartSample1> {
  // int touchedIndex = -1;
  Map<String, int> tasksByDayOfWeek = {
    'Monday': 0,
    'Tuesday': 0,
    'Wednesday': 0,
    'Thursday': 0,
    'Friday': 0,
    'Saturday': 0,
    'Sunday': 0,
  };

  final User user = FirebaseAuth.instance.currentUser!;
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    countFunc(user);
  }

  countFunc(User user) async {
    setState(() {
      isLoading = true;
    });
    Map<String, int> tasksByDayOfWeek2 = {
      'Monday': 0,
      'Tuesday': 0,
      'Wednesday': 0,
      'Thursday': 0,
      'Friday': 0,
      'Saturday': 0,
      'Sunday': 0,
    };

    final tasks_list = ['optical_dyslexia', 'optical_dyslexia_lesson',
      'agrammatism', 'agrammatism_lesson', 'semantics', 'semantics_lesson',
      'with_images', 'with_images_lesson', 'agreement', 'agreement_lesson'
    ];

    DateTime now = DateTime.now();
    int dayOfWeek = now.weekday;
    int difference = dayOfWeek - DateTime.monday;

    // Определяем начало недели (понедельник)
    DateTime startOfWeek = now.subtract(Duration(days: difference));
    print(startOfWeek);

    // Определяем конец недели (воскресенье)
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
    DateTime oneWeekAgo = now.subtract(Duration(days: 7));

    for (int i = 0; i < tasks_list.length; i++) {
      DocumentSnapshot userDocument;
      var collection =  FirebaseFirestore.instance.collection(tasks_list[i]);
      userDocument = await collection.doc(user!.uid).get();

      if (userDocument.exists) {
        dynamic data = userDocument.data();
        final DocumentReference docRef = collection.doc(user.uid);
        var task_names = data['TaskName'].keys.toList();
        for (int k = 0; k < task_names.length; k++) {
          var task_levels = data['TaskName'][task_names[k]].keys.toList();
          for (int l = 0; l < task_levels.length; l++) {
            print('task_levels');
            var task_numbers = data['TaskName'][task_names[k]][task_levels[l]].keys.toList();
            for (int n = 0; n < task_numbers.length; n++) {
              if (data['TaskName'][task_names[k]][task_levels[l]][task_numbers[n]]['done'] == true) {
                var done_date = data['TaskName'][task_names[k]][task_levels[l]][task_numbers[n]]['done_date'];
                DateTime taskDate = (done_date as Timestamp).toDate();
                if (taskDate.isAfter(startOfWeek) && taskDate.isBefore(endOfWeek)) {
                  String dayOfWeek = getDayOfWeek(taskDate.weekday);
                  tasksByDayOfWeek2[dayOfWeek] =
                      tasksByDayOfWeek2[dayOfWeek]! + 1;
                }
                  else if (taskDate.day == now.day) {
                  String dayOfWeek = getDayOfWeek(taskDate.weekday);
                  tasksByDayOfWeek2[dayOfWeek] = tasksByDayOfWeek2[dayOfWeek]! + 1;
                }

              }
            }
          }
        }
      }
    }
    setState(() {
      tasksByDayOfWeek = tasksByDayOfWeek2;
      isLoading = false;
    });
    return tasksByDayOfWeek2;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading == false)
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'СТАТИСТИКА ЗА НЕДЕЛЮ',
                  style: TextStyle(
                    color: Color(0xff564D4D),
                    // AppColors.contentColorGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),

                // Text(
                //   'Описание графика',
                //   style: TextStyle(
                //     color: Color(0xff4A98BB),
                //     // AppColors.contentColorGreen.darken(),
                //     fontSize: 18,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),

                const SizedBox(
                  height: 38,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: BarChart(mainBarData()),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
              ],
            ),
          ),

        ],
      ),
    );

    else return Container(
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator(),
        ));
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    // bool isTouched = false,
    Color? barColor,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    barColor ??= widget.barColor;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: barColor,
          width: width,
          borderSide: BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: widget.barBackgroundColor,
          ),
        ),

      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, tasksByDayOfWeek['Monday']!.toDouble()); // isTouched: i == touchedIndex
          case 1:
            return makeGroupData(1, tasksByDayOfWeek['Tuesday']!.toDouble());
          case 2:
            return makeGroupData(2, tasksByDayOfWeek['Wednesday']!.toDouble());
          case 3:
            return makeGroupData(3, tasksByDayOfWeek['Thursday']!.toDouble());
          case 4:
            return makeGroupData(4, tasksByDayOfWeek['Friday']!.toDouble());
          case 5:
            return makeGroupData(5, tasksByDayOfWeek['Saturday']!.toDouble());
          case 6:
            return makeGroupData(6, tasksByDayOfWeek['Sunday']!.toDouble());
          default:
            return throw Error();
        }
      });

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => Colors.blueGrey,
          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
          tooltipMargin: -10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String weekDay;
            switch (group.x) {
              case 0:
                weekDay = 'Понедельник';
                break;
              case 1:
                weekDay = 'Вторник';
                break;
              case 2:
                weekDay = 'Среда';
                break;
              case 3:
                weekDay = 'Четверг';
                break;
              case 4:
                weekDay = 'Пятница';
                break;
              case 5:
                weekDay = 'Суббота';
                break;
              case 6:
                weekDay = 'Воскресенье';
                break;
              default:
                throw Error();
            }
            return BarTooltipItem(
              '$weekDay\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: (rod.toY - 1).toString(),
                  style: const TextStyle(
                    color: Colors.white, //widget.touchedBarColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
      gridData: const FlGridData(show: false),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff0500FF),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('ПН', style: style);
        break;
      case 1:
        text = const Text('ВТ', style: style);
        break;
      case 2:
        text = const Text('СР', style: style);
        break;
      case 3:
        text = const Text('ЧТ', style: style);
        break;
      case 4:
        text = const Text('ПТ', style: style);
        break;
      case 5:
        text = const Text('СБ', style: style);
        break;
      case 6:
        text = const Text('ВС', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

}

String getDayOfWeek(int day) {
  switch (day) {
    case 1:
      return 'Monday';
    case 2:
      return 'Tuesday';
    case 3:
      return 'Wednesday';
    case 4:
      return 'Thursday';
    case 5:
      return 'Friday';
    case 6:
      return 'Saturday';
    case 7:
      return 'Sunday';
    default:
      return '';
  }
}



class CircularChartScreen extends StatelessWidget {
  final double percentCompleted = 75.0; // Процент выполненных задач

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 0,
        // Установите этот параметр в 0
        startDegreeOffset: -90,
        sections: showingSections(),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return [
      PieChartSectionData(
        color: Colors.blue,
        value: percentCompleted,
        title: '${percentCompleted.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }
}


class ChartData {
  ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}

class PieChart1 extends StatefulWidget {
  PieChart1({super.key});

  @override
  State<StatefulWidget> createState() => PieChart1State();
}

class PieChart1State extends State<PieChart1> {
  final User user = FirebaseAuth.instance.currentUser!;
  var done_lessons = 0;
  bool isLoading = true;
  List<ChartData> chartData = [];

  Widget _buildChart() {
    return Container(
        child: SfCircularChart(
            margin: const EdgeInsets.all(0),
            annotations: [
              CircularChartAnnotation(
                  widget: Text('$done_lessons / ${lessonItems.length}', style:
                  TextStyle(fontSize: 19, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic))
              )
            ],
            series: <CircularSeries>[
              RadialBarSeries<ChartData, String>(
                dataSource: chartData,
                xValueMapper: (ChartData data,_) => data.x,
                yValueMapper: (ChartData data,_) => data.y,
                maximumValue: lessonItems.length.toDouble(),
                enableTooltip: true,
                dataLabelMapper: (ChartData data, _) => "${data.color}%",
                cornerStyle: CornerStyle.bothCurve,
                radius: '100%',
                gap: '3%',
              )
            ]),
    );
  }

  @override
  void initState() {
    super.initState();
    LessonsDoneQuantity(user);
  }


    LessonsDoneQuantity(User user) async {
      setState(() {
        isLoading = true;
      });
      DocumentSnapshot userDocument;
      userDocument = await FirebaseFirestore.instance
          .collection('lessons_stat').doc(user.uid).get();
      var lesson_count = 0;
      if (userDocument.exists) {
        dynamic data = userDocument.data();
        for (int i = 0; i < lessonItems.length; i++){
          if (data['Lessons'].containsKey((i+1).toString())) {
            if (data['Lessons'][(i+1).toString()].keys.length ==
                lessonItems[i].tasks.length) {
              lesson_count++;
            }
          }
        }
      }
      else {
      }
      setState(() {
        done_lessons = lesson_count;
        chartData = [
          ChartData('Выполнено', done_lessons.toDouble(), Color.fromRGBO(9,0,136,1)),
        ];
        isLoading = false;
      });
      print(lesson_count);
      return lesson_count;
    }

  @override
  Widget build(BuildContext context) {
    if (isLoading == false)
    return Padding(
            padding: EdgeInsets.only(top: 40, left: 20, right: 5, bottom: 5), // EdgeInsets.zero,
            child: Column(children:
            [
              Container(
                color: Color(0xffC5FF64),
                child: Padding(padding: EdgeInsets.all(7.0),
                    child:
                    Text('ПРОЙДЕННЫЕ УРОКИ',  style: TextStyle(
                  fontSize: 20,
                  height: 0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.85)))),
    // color: Color(0xffFF9E0D),

              Row(children: [

              Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.35, // 50% ширины экрана
                    child: _buildChart(),
              )),

              SizedBox(width: 35),

              Align(
                  alignment: Alignment.topRight,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.4, // 50% ширины экрана
                      child: Image.asset("assets/finish_gifs/stat2.png"),
                // width: MediaQuery.of(context).size.width * 0.2,
                // height: MediaQuery.of(context).size.width * 0.2,
              )
          ),
    ]),
              Divider(),
    ]));
    else return Container(
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator(),
        ));
  }
}



class Chart3 extends StatefulWidget {
  Chart3({super.key});

  final User user = FirebaseAuth.instance.currentUser!;
  var done_lessons = 0;
  bool isLoading = true;

  @override
  State<StatefulWidget> createState() => Chart3State();
}

class Chart3State extends State<Chart3> {

  Map<String, List<ChartData2>> chartData = {
    'Буквы и звуки': [],
    'Слоги и морфемы': [],
    'Значения фраз': [],
    'Слова и изображения': [],
    'Согласование': [],
};

  String selectedOption = 'Буквы и звуки';
  final User user = FirebaseAuth.instance.currentUser!;
  var isLoading = false;

  countTasksFunc(User user) async {
    setState(() {
      isLoading = true;
    });

    final tasks_list = ['optical_dyslexia', 'agrammatism',  'semantics',
      'with_images', 'agreement',
    ];

    var TaskData = {
      'optical_dyslexia': {'easy': 0, 'middle': 0, 'high': 0},
      'agrammatism': {'easy': 0, 'middle': 0, 'high': 0},
      'semantics': {'easy': 0, 'middle': 0, 'high': 0},
      'with_images': {'easy': 0, 'middle': 0, 'high': 0},
      'agreement': {'easy': 0, 'middle': 0, 'high': 0},
    };

    var AllData = {
      'optical_dyslexia': {'easy': 0, 'middle': 0, 'high': 0},
      'semantics': {'easy': 0, 'middle': 0, 'high': 0},
      'agrammatism': {'easy': 0, 'middle': 0, 'high': 0},
      'with_images': {'easy': 0, 'middle': 0, 'high': 0},
      'agreement': {'easy': 0, 'middle': 0, 'high': 0},
    };

    for (int i = 0; i < tasks_list.length; i++) {
      DocumentSnapshot userDocument;
      var collection =  FirebaseFirestore.instance.collection(tasks_list[i]);
      userDocument = await collection.doc(user!.uid).get();

      if (userDocument.exists) {
        dynamic data = userDocument.data();
        var task_names = data['TaskName'].keys.toList();
        for (int k = 0; k < task_names.length; k++) {
          print('fdf');
          var task_levels = data['TaskName'][task_names[k]].keys.toList();
          for (int l = 0; l < task_levels.length; l++) {
            var task_numbers = data['TaskName'][task_names[k]][task_levels[l]].keys.toList();
            for (int n = 0; n < task_numbers.length; n++) {
              if (data['TaskName'][task_names[k]][task_levels[l]][task_numbers[n]]['done'] == true) {
                if (['easy', 'middle', 'high'].contains(task_levels[l])){
                  print([TaskData[tasks_list[i]]![task_levels[l]] ]);
                  TaskData[tasks_list[i]]![task_levels[l]] = TaskData[tasks_list[i]]![task_levels[l]]! + 1;
                }
              }
            }
          }
        }
      }
  }

    for (int i = 0; i < tasks_list.length; i++) {

      var task_names = parsedJson[tasks_list[i]].keys.toList();

      for (int k = 0; k < task_names.length; k++) {
          var easy = parsedJson[tasks_list[i]][task_names[k]]['easy'].keys.length;
          int a = (easy != null ? easy : 0);
          AllData[tasks_list[i]]!['easy'] = AllData[tasks_list[i]]!['easy']! +a;

          var middle = parsedJson[tasks_list[i]][task_names[k]]['middle'].keys.length;
          int b = (middle != null ? middle : 0);
          AllData[tasks_list[i]]!['middle'] = AllData[tasks_list[i]]!['middle']! +b;

          var high = parsedJson[tasks_list[i]][task_names[k]]['high'].keys.length;
          int c = (middle != null ? high : 0);
          AllData[tasks_list[i]]!['high'] = AllData[tasks_list[i]]!['high']! +c;

      }
    }

    var result = {
      'Буквы и звуки': [
        ChartData2('Легкий', (TaskData['optical_dyslexia']!['easy']! / AllData['optical_dyslexia']!['easy']!) * 100,
            AllData['optical_dyslexia']!['easy']!, '${TaskData['optical_dyslexia']!['easy']!} / ${AllData['optical_dyslexia']!['easy']!}', Color(0xffBBFF64)),
        ChartData2('Средний', (TaskData['optical_dyslexia']!['middle']! / AllData['optical_dyslexia']!['middle']!) * 100,
            AllData['optical_dyslexia']!['middle']!, '${TaskData['optical_dyslexia']!['middle']!} / ${AllData['optical_dyslexia']!['middle']!}', Color(0xffFFC773)),
        ChartData2('Сложный', (TaskData['optical_dyslexia']!['high']! / AllData['optical_dyslexia']!['high']!) * 100,
            AllData['optical_dyslexia']!['high']!,
            '${TaskData['optical_dyslexia']!['high']!} / ${AllData['optical_dyslexia']!['high']!}',
            Color(0xffFF8058)),
      ],

      'Слоги и морфемы': [
        ChartData2('Легкий', (TaskData['agrammatism']!['easy']! / AllData['agrammatism']!['easy']!) * 100,
            AllData['agrammatism']!['easy']!,
            '${TaskData['agrammatism']!['easy']!} / ${AllData['agrammatism']!['easy']!}',
            Color(0xffBBFF64)),
        ChartData2('Средний', (TaskData['agrammatism']!['middle']! / AllData['agrammatism']!['middle']!) * 100,
            AllData['agrammatism']!['middle']!,
            '${TaskData['agrammatism']!['middle']!} / ${AllData['agrammatism']!['middle']!}',
            Color(0xffFFC773)),
        ChartData2('Сложный', (TaskData['agrammatism']!['high']! / AllData['agrammatism']!['high']!) * 100,
            AllData['agrammatism']!['high']!,
            '${TaskData['agrammatism']!['high']!} / ${AllData['agrammatism']!['high']!}',
            Color(0xffFF8058)),
      ],

      'Значения фраз': [
        ChartData2('Легкий', (TaskData['semantics']!['easy']! / AllData['semantics']!['easy']!) * 100,
            AllData['semantics']!['easy']!,
            '${TaskData['semantics']!['easy']!} / ${AllData['semantics']!['easy']!}',
            Color(0xffBBFF64)),
        ChartData2('Средний', (TaskData['semantics']!['middle']! / AllData['semantics']!['middle']!) * 100,
            AllData['semantics']!['middle']!,
            '${TaskData['semantics']!['middle']!} / ${AllData['semantics']!['middle']!}',
            Color(0xffFFC773)),
        ChartData2('Сложный', (TaskData['semantics']!['high']! / AllData['semantics']!['high']!) * 100,
            AllData['semantics']!['high']!,
            '${TaskData['semantics']!['high']!} / ${AllData['semantics']!['high']!}',
            Color(0xffFF8058)),
      ],

      'Слова и изображения': [
        ChartData2('Легкий', (TaskData['with_images']!['easy']! / AllData['with_images']!['easy']!) * 100,
            AllData['with_images']!['easy']!,
            '${TaskData['with_images']!['easy']!} / ${AllData['with_images']!['easy']!}',
            Color(0xffBBFF64)),
        ChartData2('Средний', (TaskData['with_images']!['middle']! / AllData['with_images']!['middle']!) * 100,
            AllData['with_images']!['middle']!,
            '${TaskData['with_images']!['middle']!} / ${AllData['with_images']!['middle']!}',
            Color(0xffFFC773)),
        ChartData2('Сложный', (TaskData['with_images']!['high']! / AllData['with_images']!['high']!) * 100,
            AllData['with_images']!['high']!,
            '${TaskData['with_images']!['high']!} / ${AllData['with_images']!['high']!}',
            Color(0xffFF8058)),
      ],

      'Согласование': [
        ChartData2('Легкий', (TaskData['agreement']!['easy']! / AllData['agreement']!['easy']!) * 100,
            AllData['agreement']!['easy']!,
            '${TaskData['agreement']!['easy']!} / ${AllData['agreement']!['easy']!}', Color(0xffBBFF64)),
        ChartData2('Средний', (TaskData['agreement']!['middle']! / AllData['agreement']!['middle']!) * 100,
            AllData['agreement']!['middle']!,
            '${TaskData['agreement']!['middle']!} / ${AllData['agreement']!['middle']!}',
            Color(0xffFFC773)),
        ChartData2('Сложный', (TaskData['agreement']!['high']! / AllData['agreement']!['high']!) * 100,
            AllData['agreement']!['high']!,
            '${TaskData['agreement']!['high']!} / ${AllData['agreement']!['high']!}',
            Color(0xffFF8058)),
      ],
    };

    setState(() {
      chartData = result;
      isLoading = false;
    });
    return result;
  }

  @override
  void initState() {
    super.initState();
    countTasksFunc(user);
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
            height: 360,
        // height: MediaQuery.of(context).size.height * .9,
    width: MediaQuery.of(context).size.width * .9,
    child: Column(children: [

      SizedBox(height: 12),

        Align(
            alignment: Alignment.centerLeft,
            child:
            DropdownButton<String>(
        value: selectedOption,
        items: chartData.keys.map((String key) {
          return DropdownMenuItem<String>(
            value: key,
            child: Text(key),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedOption = newValue!;
          });
        },
      ),
        ),

        SizedBox(height: 12),

        Container(
            height: 270, child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(rangePadding: ChartRangePadding.none),
                    series: <CartesianSeries>[
                      StackedBar100Series<ChartData2, String>(
                          dataSource: chartData[selectedOption],
                          // color: Colors.red,
                          xValueMapper: (ChartData2 data, _) => data.x,
                          yValueMapper: (ChartData2 data, _) => data.y,
                          pointColorMapper: (ChartData2 data, _) =>  data.color,
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                          dataLabelMapper: (ChartData2 data, _) => '${data.label}',
                          width: 0.5,
                          spacing: 0.1
                      ),
                      StackedBar100Series<ChartData2, String>(
                          dataSource: chartData[selectedOption],
                          color: Color(0xffD9D9D9),
                          xValueMapper: (ChartData2 data, _) => data.x,
                          yValueMapper: (ChartData2 data, _) => data.y2,
                          width: 0.5,
                          spacing: 0.1
                      )
                    ]
      )),
    ]));
  }
}
class ChartData2 {
  final String x;
  final num y;
  final num y2;
  final label;
  final Color color;
  ChartData2(this.x, this.y, this.y2, this.label, this.color);
}




// class Chart4 extends StatefulWidget {
//   Chart4({super.key});
//
//   @override
//   State<StatefulWidget> createState() => Chart4State();
// }
//
// class Chart4State extends State<Chart4> {
//   List<ChartData2> chartData = [
//     ChartData2('Jan', 45, 47),
//     ChartData2('Feb', 45, 47),
//     ChartData2('Mar', 50, 42),
//     ChartData2('Apr', 44, 48),
//     ChartData2('May', 43, 49),
//     ChartData2('June', 44, 48),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return SfCartesianChart(
//         primaryXAxis: CategoryAxis(),
//         series: <CartesianSeries>[
//           StackedBar100Series<ChartData2, String>(
//               dataSource: chartData,
//               xValueMapper: (ChartData2 data, _) => data.x,
//               yValueMapper: (ChartData2 data, _) => data.y,
//               width: 0.8,
//               spacing: 0.2
//           ),
//           StackedBar100Series<ChartData2, String>(
//               dataSource: chartData,
//               xValueMapper: (ChartData2 data, _) => data.x,
//               yValueMapper: (ChartData2 data, _) => data.y2,
//               width: 0.8,
//               spacing: 0.2
//           )
//         ]
//     );
//   }
// }


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Bar Chart with Dropdown')),
        body: ChartWithDropdown(),
      ),
    );
  }
}

class ChartWithDropdown extends StatefulWidget {
  @override
  _ChartWithDropdownState createState() => _ChartWithDropdownState();
}

class _ChartWithDropdownState extends State<ChartWithDropdown> {
  String selectedOption = 'Option 1';

  final Map<String, List<double>> chartData = {
    'Option 1': [5, 7, 6],
    'Option 2': [3, 8, 5],
    'Option 3': [6, 4, 7],
  };


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
          value: selectedOption,
          items: chartData.keys.map((String key) {
            return DropdownMenuItem<String>(
              value: key,
              child: Text(key),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedOption = newValue!;
            });
          },
        ),

        Container(
            height: MediaQuery.of(context).size.height * .4,
            width: MediaQuery.of(context).size.width * .3,
            child:
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 10,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,),
                  borderData: FlBorderData(show: false),
                  barGroups: chartData[selectedOption]!.asMap().entries.map((entry) {
                    int index = entry.key;
                    double value = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: value,
                          color: Colors.blue,
                          width: 15,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),

    // Container(
    // height: MediaQuery
    //     .of(context)
    //     .size
    //     .height * .4,
    // width: MediaQuery
    //     .of(context)
    //     .size
    //     .width * .3,
    //     child:
    //     Padding(
    //       padding: const EdgeInsets.all(16.0),
    //       child: BarChart(
    //         BarChartData(
    //           alignment: BarChartAlignment.spaceAround,
    //           maxY: 10,
    //           barTouchData: BarTouchData(enabled: false),
    //           titlesData: FlTitlesData(
    //             show: true,
    //           ),
    //           borderData: FlBorderData(show: false),
    //           barGroups: chartData[selectedOption]!.map((data) {
    //             int index = chartData[selectedOption]!.indexOf(data);
    //             return BarChartGroupData(
    //               x: index,
    //               barRods: [
    //                 BarChartRodData(
    //                   toY: data,
    //                   width: 15,
    //                   backDrawRodData: BackgroundBarChartRodData(
    //                     show: true,
    //                     toY: 10,
    //                   ),
    //                 ),
    //               ],
    //             );
    //           }).toList(),
    //         ),
    //       ),
    //     ),
    // )],
    ))
      ]);


  }
}




class TableWithDropdown extends StatefulWidget {
  @override
  _TableWithDropdownState createState() => _TableWithDropdownState();
}

class _TableWithDropdownState extends State<TableWithDropdown> {
  String selectedOption = 'Option 1';

  final Map<String, List<List<int>>> tableData = {
    'Option 1': [
      [1, 2, 3],
    ],
    'Option 2': [
      [10, 11, 12],
    ],
    'Option 3': [
      [19, 20, 21],
    ],
  };

  @override
  Widget build(BuildContext context) {
    return  Container(
        height: MediaQuery.of(context).size.height * .9,
        width: MediaQuery.of(context).size.width * .9,
        child:
        Padding(
        padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        DropdownButton<String>(
          value: selectedOption,
          items: tableData.keys.map((String key) {
            return DropdownMenuItem<String>(
              value: key,
              child: Text(key),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedOption = newValue!;
            });
          },
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Table(
              border: TableBorder.all(),
              children: [
                TableRow(
                  children: [
                    TableCell(child: Center(child: Text('Easy'))),
                    TableCell(child: Center(child: Text('Middle'))),
                    TableCell(child: Center(child: Text('High'))),
                  ],
                ),
                ...tableData[selectedOption]!.map((row) {
                  return TableRow(
                    children: row.map((cell) {
                      return TableCell(
                        child: Center(
                          child: Text(cell.toString()),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    )));
  }}