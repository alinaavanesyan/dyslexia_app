import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dyslexia_project/screens/home_screen.dart';
import 'package:dyslexia_project/screens/account_screen.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:dyslexia_project/screens/lessons.dart';
import 'package:dyslexia_project/recorder/2another.dart';
import 'package:dyslexia_project/recorder/recognizer.dart';
import 'dart:io';
import 'dart:async';
import 'package:dyslexia_project/recorder/audio_player.dart';
import 'package:dyslexia_project/recorder/new.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:just_audio/just_audio.dart' as ap;
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dyslexia_project/tasks/tasks_data.dart';

  class TextDetailScreen extends StatefulWidget {
    final TextItem textItem;
    TextDetailScreen(this.textItem);

  @override
  State<TextDetailScreen> createState() => _TextDetailScreenState();
  }

  class _TextDetailScreenState extends State<TextDetailScreen> {

    int _selectedIndex = 2;
    String? _recordPath;
    bool _isRecording = false;
    bool showPlayer = false;
    ap.AudioSource? audioSource;
    late bool _isUploading;
    String? audioFilePath;
    final tempDirPath = getTemporaryDirectory();
    List Levels = ['easy', 'middle', 'high'];
    var _text = '';

    _onFileUploadButtonPressed(_filePath) async {
      FirebaseStorage firebaseStorage = FirebaseStorage.instance;
      setState(() {
        _isUploading = true;
      });
      try {
        Uri uri = Uri.parse(_filePath);
        String pathWithoutPrefix = uri.path;
        await firebaseStorage
            .ref('upload-voice-firebase')
            .child(
            _filePath.substring(_filePath.lastIndexOf('/'), _filePath.length))
            .putFile(File(pathWithoutPrefix));
        // widget.onUploadComplete();
        // }
      } catch (error) {
        print('Error occured while uplaoding to Firebase ${error.toString()}');
        Uri uri = Uri.parse(_filePath);
        String pathWithoutPrefix = uri.path;

        print(pathWithoutPrefix);
        File file = File(pathWithoutPrefix);

        if (!file.existsSync()) {
          print('File does not exist: $_filePath');
          ;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error occured while uplaoding'),
          ),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }

    List<Reference> references = [];

    final User user = FirebaseAuth.instance.currentUser!;

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
    void initState() {
      _checkInfo(user);
      showPlayer = false;
      _isUploading = false;
      super.initState();
    }

  @override
  Widget build(BuildContext context) {
    // print(widget.textItem.difficulty);
    return Scaffold(
    body:
    Stack(
    fit: StackFit.expand,
    children: [
      Image.asset("assets/images/2back_light.png",
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
                        builder: (context) => TextListScreen()),)
          )
      ),

      Padding(
            padding: EdgeInsets.only(top: 110.0, right: 10, left: 10),
            child: Center(child:
            Column(children: [
              Text('${widget.textItem.title} №${widget.textItem.number}', style:
              TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),),

              SizedBox(height: 6,),

              Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                for (int i = 0; i < widget.textItem.difficulty + 1; i++)
                Icon(
                  Icons.star,
                  color: Color(0xffFAD657),
                  size: 20,
                )]),

              SizedBox(height: 8,),


              SizedBox(height: 10,),

              Center(child: Padding(padding: EdgeInsets.only(left: 25.0, right: 25.0), child:
              Align(
                alignment: Alignment.center,
                child: Text('Нажмите на микрофон и прочитайте ${widget.textItem.title.toLowerCase()} ниже',  style: TextStyle(color: Colors.black, fontSize: 16, letterSpacing: 0.85,
                fontWeight: FontWeight.bold, backgroundColor: Color(0xffDBFFCD))),
              ))),
              SizedBox(height: 15,),
              Center(
                child: Container(
                  width:  MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.white, // Белый цвет контейнера
                    borderRadius: BorderRadius.circular(20.0), // Закругленные углы
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2), // Цвет и прозрачность тени
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset: Offset(0, 2), // Смещение тени
                      ),
                    ],
                  ),
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        padding: const EdgeInsets.all(12),
                            child:
                            Align(
                      alignment: Alignment.center,
                      child: Text(widget.textItem.content,  style: TextStyle(color: Colors.black87, letterSpacing: 0.85, fontSize: 16)),
                            )
                )
              )),

                SizedBox(height: 15),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: RecordingScreen(widget.textItem.number,  Levels[widget.textItem.difficulty])
                        ),
                        ]),

                    ),
                  ),
              // RecordingScreen2(widget.textItem.number, Levels[widget.textItem.difficulty]).texts_done(),

            ]),)),

    // Container(
    //     child: RecordingScreen(widget.textItem.number, Levels[widget.textItem.difficulty])
    // )
    ]
    )

    );  }

    Future<void> _onUploadComplete() async {
      FirebaseStorage firebaseStorage = FirebaseStorage.instance;
      ListResult listResult =
      await firebaseStorage.ref().child('upload-voice-firebase').list();
      setState(() {
        references = listResult.items;
      });
    }

    @override
    void debugFillProperties(DiagnosticPropertiesBuilder properties) {
      super.debugFillProperties(properties);
      properties.add(DiagnosticsProperty<bool>('showPlayer', showPlayer));
      properties.add(DiagnosticsProperty<ap.AudioSource?>('audioSource', audioSource));
    }
}

class TextListScreen extends StatefulWidget {
  const TextListScreen({super.key});

  @override
  State<TextListScreen> createState() => _TextListScreenState();
}

class _TextListScreenState extends State<TextListScreen> {
  int selectedTileIndex = -1;
  int _selectedIndex = 2;

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
          ],),
        body: Stack(
            fit: StackFit.expand,
            children: [

              Image.asset(
                "assets/images/back_light.png",
                fit: BoxFit.cover,
              ),

              Positioned(
                  top: 70,
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
                  top: 120,
                  // left: 15,
                  left: MediaQuery
                      .of(context)
                      .size
                      .width * 0.08,
                  child: Center(child: Text(
                    'Тексты',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  )),


              Padding(
                  padding: EdgeInsets.only(top: 150.0, right: 10, left: 10),
                  child:
                  SingleChildScrollView(
                      scrollDirection: Axis.vertical, child:
                      ListView.builder(
                      // scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: TextsGroups!.keys.length,
                      itemBuilder: (BuildContext context, int index) {
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
                                    ),
                                  ],
                                ),
                                child: Center(
                                    child: ListTile(
                                      title: Text('${index == 0 ? '${index+1}. Простой' : (index == 1 ? '${index+1}. Средний' : '${index+1}. Сложный')} уровень заданий'),
                                      subtitle: Row(children: [
                                        for (int i = 0; i <= TextsGroups[TextsGroups!.keys.toList()[index]]![0].difficulty; i++)
                                          Icon(
                                            Icons.star, color: Color(0xffFAD657),
                                            size: 20,
                                          )]),

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

                                      child: Column(
                                          children: [
                                            ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: TextsGroups[TextsGroups!.keys.toList()[index]]!.length,
                                      itemBuilder: (BuildContext context, int task_index) {

                                        return
                                              Container(
                                                  height: MediaQuery.of(context).size.height * 0.10,
                                                  // width: MediaQuery.of(context).size.width * 0.64,
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
                                                          title: Text('${TextsGroups[TextsGroups!.keys.toList()[index]]![task_index].title} №${task_index+1}'),
                                                          leading: Container(
                                                            child: Image.asset('assets/icons/read.png'),),
                                                          onTap: () {
                                                            // print( LessonGroups['semantics']![LessonGroups['semantics']!
                                                            //     .keys.toList()[index]]!['tasks']);
                                                            // print(LessonGroups['semantics']![LessonGroups['semantics']!.keys.toList()[index]]!['tasks']!.keys.length);
                                                            setState(() {
                                                              Navigator.push(context,
                                                                  MaterialPageRoute(
                                                                      builder: ((context) => TextDetailScreen(
                                                                          TextsGroups[TextsGroups!.keys.toList()[index]]![task_index])
                                                                      ))
                                                                  );
                                                            });
                                                          }))
                                        );
                                      })
                              ])),
                              ],);
                      })
              ))]
        )
    );}
}

