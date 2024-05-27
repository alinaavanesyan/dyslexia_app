import 'package:dyslexia_project/tasks/tasks_data.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:io';
import 'dart:async';
import 'package:dyslexia_project/screens/reading_section.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dyslexia_project/services/snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:whisper_dart/whisper_dart.dart";
import 'package:universal_io/io.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';


class SpeechToTextScreen extends StatefulWidget {
  @override
  _SpeechToTextScreenState createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  stt.SpeechToText _speech = stt.SpeechToText();
  String _text = 'Press the microphone button and start speaking';
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech to Text Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_text),
            SizedBox(height: 20),
            FloatingActionButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Icon(_isListening ? Icons.stop : Icons.mic),
            ),
          ],
        ),
      ),
    );
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('onStatus: $status');
      },
      onError: (error) {
        print('onError: $error');
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
      });
      _speech.listen(
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
          });
        },
        localeId: 'ru_RU', // Устанавливаем локаль на русский
      );
    } else {
      print('The user has denied the use of speech recognition.');
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      print(_text);
    });
  }
}


class RecordingScreen extends StatefulWidget {
  final int TextNumber;
  final String TextDifficulty;

  RecordingScreen(this.TextNumber, this.TextDifficulty); // this.hearTask
  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  late Record audioRecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  String audioPath = "";
  final FlutterSoundRecord audioRecorder = FlutterSoundRecord();
  List audioFiles = [];
  List<bool> _selected = [];
  String userId = FirebaseAuth.instance.currentUser!.uid;
  bool playing = false;
  bool isLoading = false;
  final User user = FirebaseAuth.instance.currentUser!;
  var time_info = {};

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    isLoading = true;
    fetchAudioFiles();
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
  }

  Future<void> fetchAudioFiles() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    final CollectionReference TextsUsersCollection = FirebaseFirestore.instance
        .collection('texts');
    DocumentSnapshot userDocument;
    userDocument = await TextsUsersCollection.doc(user.uid).get();
    var delete = [];
    if (userDocument.exists) {
      dynamic data = userDocument.data();
      if (data != null ) {
        if (data.containsKey('Delete')) {
          delete = data['Delete'];
        }
      }
    }
    ListResult result = await storage.ref('upload-voice-firebase/$userId').listAll();
    List filesStartingWithText = [];
    var index = 0;
    result.items.forEach((Reference ref) {
      if (ref.name.startsWith('Text_${widget.TextNumber}_${widget.TextDifficulty}')) {
        filesStartingWithText.add(index);
      }
      index++;
    });

    var selectedItems = [];
    filesStartingWithText.forEach((index) {
      if (index < result.items.length && !delete.contains(result.items[index].name)) {
        selectedItems.add(result.items[index]);
      }
    });

    var time_info1 = {};
    dynamic data = userDocument.data();
    for (int i=0; i < selectedItems.length; i++){
      if (data != null) {
      if (data.containsKey('Texts')) {
        var texts_id = data['Texts'];
        if (texts_id.containsKey(selectedItems[i].name)) {
          String day = texts_id[selectedItems[i].name].toDate().day.toString();
          String month = texts_id[selectedItems[i].name].toDate().month.toString();
          String year = texts_id[selectedItems[i].name].toDate().year.toString();
          String hour = texts_id[selectedItems[i].name].toDate().hour.toString();
          String minute =  texts_id[selectedItems[i].name].toDate().minute.toString();
          String dateTimeString = '$day/$month/$year $hour:$minute';

          time_info1[selectedItems[i].name] = dateTimeString;

        }
        else {
          time_info1[selectedItems[i].name] = '';
        }
      }
        else {
          time_info1[selectedItems[i].name] = '';
        }
      }
      else {
        time_info1[selectedItems[i].name] = '';
      }
    }

    setState(() {
        audioFiles = selectedItems;
        _selected = List.generate(audioFiles.length, (i) => false);
        time_info = time_info1;
        isLoading = false;
    });
  }

  Future<void> startRecording() async {
    try {
      print("START RECODING+++++++++++++++++++++++++++++++++++++++++++++++++");
      if (await audioRecorder.hasPermission()) {

        await audioRecorder.start();
        setState(() {
          isRecording = true;
        });
      }
    } catch (e, stackTrace) {
      print("START RECODING+++++++++++++++++++++${e}++++++++++${stackTrace}+++++++++++++++++");
    }
  }

  Future<void> stopRecording() async {
    try {
      print("STOP RECODING+++++++++++++++++++++++++++++++++++++++++++++++++");
      String? path = await audioRecorder.stop();
      setState(() {
        recoding_now=false;
        isRecording = false;
        audioPath = path!;
      });
    } catch (e) {
      print("STOP RECODING+++++++++++++++++++++${e}+++++++++++++++++++++++++++");
    }
  }

  Future<void> playRecording() async {
    try {
      playing = true;
      setState(() {});

      print("AUDIO PLAYING+++++++++++++++++++++++++++++++++++++++++++++++++");
      var urlSource = UrlSource(audioPath);
      await audioPlayer.play(urlSource);
      audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
        if (state == PlayerState.completed) {
          playing = false;


          print("AUDIO PLAYING ENDED+++++++++++++++++++++++++++++++++++++++++++++++++");
          setState(() {});
        }
      });

    } catch (e) {
      print("AUDIO PLAYING++++++++++++++++++++++++${e}+++++++++++++++++++++++++");
    }
  }

  Future<void> pauseRecording() async {
    try {
      playing=false;

      print("AUDIO PAUSED+++++++++++++++++++++++++++++++++++++++++++++++++");

      await audioPlayer.pause();
      setState(() {

      });
    } catch (e) {
      print("AUDIO PAUSED++++++++++++++++++++++++${e}+++++++++++++++++++++++++");
    }
  }

  Future<void> uploadAndDeleteRecording() async {
    try {
      setState(() {
        isLoading = true;
      });

      FirebaseStorage firebaseStorage = FirebaseStorage.instance;

      try {
        Uri uri = Uri.parse(audioPath);
        String pathWithoutPrefix = uri.path;
        int fileCount = 1;
        String fileBaseName = 'Text_${widget.TextNumber}_${widget.TextDifficulty}';
        String extension = pathWithoutPrefix.split('.').last;

        var filePath = '$userId/$fileBaseName$fileCount.$extension';

        while (true) {
          filePath = '$userId/$fileBaseName$fileCount.$extension';
          try {
            await firebaseStorage.ref('upload-voice-firebase/${filePath}').getDownloadURL();
            fileCount++;
          } catch (e) {
            break;
          }
        }
        await firebaseStorage
            .ref('upload-voice-firebase')
            .child(filePath)
            .putFile(File(pathWithoutPrefix));

        DateTime uploadTime = DateTime.now();
        final CollectionReference TextsUsersCollection = FirebaseFirestore.instance
            .collection('texts');

        DocumentSnapshot userDocument;
        userDocument = await TextsUsersCollection.doc(user.uid).get();

        if (!userDocument.exists) {
          TextsUsersCollection.doc(user.uid).set({
            'Texts': {filePath.split('/')[1]: uploadTime},
          }).catchError((error) {
            print('Ошибка при сохранении метаданных файла: $error');
          });
        }
        else {
          String path = filePath.split('/')[1].toString();
          print('path $path');
          final DocumentReference docRef = await TextsUsersCollection.doc(user.uid);

          dynamic data = userDocument.data();
          data['Texts'][path] = uploadTime;
          TextsUsersCollection.doc(user.uid).set(data);
        }

          SnackBarService.showSnackBar(context,'Запись сохранена', false,);

      } catch (error) {
        SnackBarService.showSnackBar(context,'Во время сохранения произошла ошибка', false,);
        print('Error occured while uplaoding to Firebase ${error.toString()}');
        Uri uri = Uri.parse(audioPath);

        String pathWithoutPrefix = uri.path;

        File file = File(pathWithoutPrefix);

        if (!file.existsSync()) {
          print('File does not exist: $audioPath');
          ;
        }

        SnackBarService.showSnackBar(context,'Во время загрузки произошла ошибка', true,);
      } finally {
      }
    }
    catch (e) {
      print(e);
    }
    setState(() {
      fetchAudioFiles();
      isLoading = false;
    });

  }

  Future<void> deleteRecording() async {

    if (audioPath.isNotEmpty) {
      print(audioPath);
      try {
        recoding_now=true;
        File file = File(audioPath);
        if (file.existsSync()) {
          file.deleteSync();
          const snackBar = SnackBar(
            content: Text('Recoding deleted'),);
          print("FILE DELETED+++++++++++++++++++++++++++++++++++++++++++++++++");
        }
      } catch (e) {
        print("FILE NOT DELETED++++++++++++++++${e}+++++++++++++++++++++++++++++++++");
      }

      setState(() {
        audioPath = "";
      });
    }
  }

  bool recoding_now=true;
  int selectedIndex = -1;
  @override
  Widget build(BuildContext context) {
    if (isLoading == false) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              recoding_now
                  ? IconButton(
                icon: !isRecording
                    ? const Icon(Icons.mic_none, color: Colors.red, size: 50)
                    : const Icon(Icons.fiber_manual_record, color: Colors.red, size: 50),
                onPressed: isRecording ? stopRecording : startRecording,
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: !playing
                        ? Icon(Icons.play_circle, color: Colors.green, size: 50)
                        : Icon(Icons.pause_circle, color: Colors.green, size: 50),
                    onPressed: !playing ? playRecording : pauseRecording,
                  ),
                  IconButton(
                    icon: const Icon(Icons.repeat, color: Colors.red, size: 50),
                    onPressed: deleteRecording,
                  ),
                  IconButton(
                    icon: const Icon(Icons.save, color: Colors.green, size: 50),
                    onPressed: uploadAndDeleteRecording,
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 30),
              Text('ПРЕДЫДУЩИЕ ЗАПИСИ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 0.85)),

          Container(
              child:
              Expanded(
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: audioFiles.length,
                  itemBuilder: (context, index) {
                    String fileName = audioFiles[index].name;
                    return Container(
                        color: _selected[index] ? Colors.white : Color(0xffDFFFBE),
                        child: ListTile(
                      tileColor: _selected[index] ? Colors.white : Color(0xffDFFFBE),
                      title: Text(fileName),
                      subtitle: Text(time_info[fileName]),
                      onTap: () {
                        setState(() {
                          _selected[index] = true;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CompareTextScreen(audioFiles[index].name, widget.TextDifficulty,
                          widget.TextNumber)));
                        },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon:!playing
                                ? Icon(Icons.play_circle, color: Colors.green)
                                : Icon(Icons.pause_circle, color: Colors.green),
                            onPressed: () async {
                              String url = await audioFiles[index].getDownloadURL();
                              setState(() {
                                audioPath = url;
                              });
                              playRecording();
                              },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              String url = await audioFiles[index].getDownloadURL();
                              setState(() {
                                final CollectionReference TextsUsersCollection = FirebaseFirestore.instance.collection('texts');
                                DocumentReference docRef = TextsUsersCollection.doc(user.uid);
                                try {
                                  docRef.update({
                                    'Delete': FieldValue.arrayUnion(
                                    [audioFiles[index].name]),
                                  });
                                  if (index >= 0 && index < audioFiles.length) {
                                    audioFiles.removeAt(index);
                                  }
                                  audioPath = url;
                                }
                                catch (e) {
                                  print('Нет файла');
                                };
                              });
                              },
                          ),
                        ],
                      ),
                    ));
                    },
                ),

    ))],
      );
    }
    else {
      return Stack(children: [
        Container(
            color: Color(0xffF4FFEA),
            child: Center(
              child: CircularProgressIndicator(),
            )),
      ]);
      bool recoding_now = true;
    }
  }
}


class CompareTextScreen extends StatefulWidget {
  final String audioName;
  final String TextDifficulty;
  final int TextIndex;
  CompareTextScreen(this.audioName, this.TextDifficulty,
      this.TextIndex);

  @override
  _CompareTextScreenState createState() => _CompareTextScreenState();
}

class _CompareTextScreenState extends State<CompareTextScreen> {
  var model;
  String audio = "";
  String result = "";
  String user_text = '';
  String task_text = '';
  bool is_procces = false;
  bool isLoading = false;

  double _similarity = 0.0;
  String _errorReport = '';

  @override
  void initState() {
    isLoading = true;
    loadModel();
    task_text = TextsGroups[widget.TextDifficulty]![widget.TextIndex-1].content;
    super.initState();
  }

  loadModel() async {
    final User user = FirebaseAuth.instance.currentUser!;

    // FirebaseStorage.instance.ref().child('models/ggml-tiny2.bin');
    Directory tempDir = await getTemporaryDirectory();
    File downloadToFile = File('${tempDir.path}/model.bin');
    final bytes = await rootBundle.load('./assets/models/ggml-tiny2.bin');
    await downloadToFile.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));

    try {
      Reference storageRef = FirebaseStorage.instance.ref().child('upload-voice-firebase/${user.uid}/${widget.audioName}');
      File downloadToFile2 = File('${tempDir.path}/${widget.TextDifficulty}_${widget.audioName}.m4a');
      await storageRef.writeToFile(downloadToFile2);

      String outputFilePath = '${tempDir.path}/${downloadToFile2.path.split('/').last.split('.').first}_16k.wav';

      String command = '-i ${downloadToFile2.path} -ar 16000 -t 60 $outputFilePath';

      await FFmpegKit.execute(command).then((session) async {
        try {
          var _outputFile = File(outputFilePath);

          if (_outputFile.existsSync()) {
            print('Conversion successful: $outputFilePath');
            var filePath = '${user.uid}';

            try {
              await FirebaseStorage.instance
                  .ref('upload-voice-firebase/$filePath/${_outputFile.path.split('/').last}')
                  .putFile(_outputFile);

              setState(() {
                audio = outputFilePath;
              });
            } catch (e) {
              print('Error uploading file: $e');
            }
          } else {
            print('Output file does not exist: $outputFilePath');
          }
        } catch (e) {
          print('Error converting file: $e');
        }
      });


    }
    catch (e) {
      print('Не удалось скачать файл ${user.uid}/${widget.audioName}');
      print(e);
    }

    setState(() {
      model = downloadToFile.path;
      isLoading = false;
    });

  }

  void _compareTexts() {
    final String originalText = task_text;
    final String spokenText = user_text;

    String originalTextWithoutPunctuation = originalText.replaceAll(RegExp(r'[^\w\s]'), '');
    String spokenTextWithoutPunctuation = spokenText.replaceAll(RegExp(r'[^\w\s]'), '');

    setState(() {
      _similarity = originalTextWithoutPunctuation.similarityTo(spokenTextWithoutPunctuation);
      _errorReport = _generateErrorReport(originalTextWithoutPunctuation, spokenTextWithoutPunctuation);
    });
  }

  String _generateErrorReport(String originalText, String spokenText) {
    final List<String> originalWords = originalText.split(' ');
    final List<String> spokenWords = spokenText.split(' ');
    final List<String> errors = [];

    for (int i = 0; i < originalWords.length; i++) {
      if (i >= spokenWords.length || originalWords[i] != spokenWords[i]) {
        errors.add('Expected: "${originalWords[i]}", but got: "${spokenWords.length > i ? spokenWords[i] : 'nothing'}"');
      }
    }

    if (spokenWords.length > originalWords.length) {
      for (int i = originalWords.length; i < spokenWords.length; i++) {
        errors.add('Extra word: "${spokenWords[i]}"');
      }
    }

    return errors.join('\n');
  }

  @override

  Widget build(BuildContext context) {
    if (isLoading == false) {
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

              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery
                  .of(context)
                  .size
                  .height,
              minWidth: MediaQuery
                  .of(context)
                  .size
                  .width,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text('В этом разделе автоматически оценивается ваше произношение', style: TextStyle(fontSize: 18),),
                )),

                SizedBox(height: 10,),

                Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text('В случае плохого результата не расстраивайтесь и помните, что машины могут ошибаться', style: TextStyle(fontSize: 18),),
                    )),

                SizedBox(height: 50,),
                Visibility(
                  visible: !is_procces,
                  replacement: const CircularProgressIndicator(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          onPressed: () async {
                            if (!model.isEmpty) {
                              Future(() async {
                                print("Started transcribe");

                                Whisper whisper = Whisper(
                                  whisperLib: "libwhisper.so",
                                );
                                var res = await whisper.request(
                                  whisperLib: "libwhisper.so",
                                  whisperRequest: WhisperRequest.fromWavFile(
                                    audio: File(audio),
                                    model: File(model),
                                    language: "ru",
                                  ),
                                );
                                setState(() {
                                  result = res.toString();
                                  user_text = res['text'];
                                  is_procces = false;
                                });
                              }).then((_) => _compareTexts());
                              setState(() {
                                is_procces = true;
                              });
                            }
                            else {
                              print('файла нет');
                            }
                          },
                          child: const Text("Оценить", style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40.0),


                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 20.0),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Результат: ',
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold,),
                      ),
                      TextSpan(text: '${(_similarity * 100).toStringAsFixed(2)}%',
                        style: TextStyle(fontSize: 20.0,),),
                    ],
                  ),
                ),

                SizedBox(height: 16.0),
                // Text(
                //   'Ошибки:',
                //   style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                // ),

                SizedBox(height: 8.0),
                // Text(
                //   _errorReport,
                //   style: TextStyle(fontSize: 16.0, color: Colors.red),
                // ),
              ],
            ),
          ),
        ),
      ]));
    }
    else {
      return Stack(children: [
        Container(
            color: Color(0xffF4FFEA),
            child: Center(
              child: CircularProgressIndicator(),
            )),
      ]);
    }
  }
}
