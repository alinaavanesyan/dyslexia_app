import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
// import 'package:dyslexia_project/recorder/audio_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:just_audio/just_audio.dart' as ap;
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
// import 'package:speech_to_text/speech_to_text.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:voice_to_text/voice_to_text.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whisper_dart/whisper_dart.dart';
// import 'package:whisper_dart/whisper_dart.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AudioRecorderIsolate {
  static void recordAudio(SendPort sendPort) async {
    final FlutterSoundRecord _audioRecorder = FlutterSoundRecord();
    String path = '';
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start();
        // final String? path = await _audioRecorder.stop();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    sendPort.send(await _audioRecorder.stop());
  }
}

class SpeechRecognitionIsolate {
  static void recognizeSpeech(SendPort sendPort) async {
    final stt.SpeechToText _speech = stt.SpeechToText();
    String text = '';
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('onStatus: $status');
      },
      onError: (error) {
        print('onError: $error');
      },
    );

    if (available) {
      await _speech.listen(
        onResult: (result) {
          text = result.recognizedWords;
          sendPort.send(text);
        },
        localeId: 'ru_RU',
      );
    } else {
      print('The user has denied the use of speech recognition.');
    }
  }
}

class MyApp2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech to Text Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SpeechToTextScreen2(),
    );
  }
}

class SpeechToTextScreen2 extends StatefulWidget {
  @override
  _SpeechToTextScreen2State createState() => _SpeechToTextScreen2State();
}

class _SpeechToTextScreen2State extends State<SpeechToTextScreen2> {
  bool _isRecording = false;
  bool _isPaused = false;
  int _recordDuration = 0;
  Timer? _timer;
  Timer? _ampTimer;
  final FlutterSoundRecord _audioRecorder = FlutterSoundRecord();
  stt.SpeechToText _speech = stt.SpeechToText();
  String _text = '';

  @override
  void initState() {
    super.initState();
    _isRecording = false;
    _startRecordingAndListening();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ampTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _startRecordingAndListening() {
    ReceivePort receivePort = ReceivePort();
    receivePort.listen((message) {
      if (message is String) {
        setState(() {
          _text = message;
        });
      }
    });

    Isolate.spawn(AudioRecorderIsolate.recordAudio, receivePort.sendPort);
    Isolate.spawn(SpeechRecognitionIsolate.recognizeSpeech, receivePort.sendPort);
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
          ],
        ),
      ),
    );
  }
}



// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key? key}) : super(key: key);
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
// class _MyHomePageState extends State<MyHomePage> {
//   SpeechToText _speechToText = SpeechToText();
//   bool _speechEnabled = false;
//   String _lastWords = '';
//   var path = '';
//   late Record audioRecord;
//   late AudioPlayer audioPlayer;
//   bool isRecording = false;
//   String audioPath = "";
//   final soundRecorderAndPlayer = SoundRecorderAndPlayer();
//   List audioFiles = [];
//   bool playing = false;
//   bool isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     audioPlayer = AudioPlayer();
//     _initSpeech();
//   }
//
//   void _saveAudioToFile() async {
//     // Получаем путь к директории документов на устройстве
//     Directory appDocDir = await getApplicationDocumentsDirectory();
//     String appDocPath = appDocDir.path;
//
//     // Генерируем уникальное имя файла для сохранения
//     String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.wav';
//
//     // Полный путь к файлу
//     String filePath = '$appDocPath/$fileName';
//
//     print(filePath);
//     print('путь');
//     // Создаем экземпляр класса FlutterSound
//     var flutterSound = FlutterSoundRecorder();
//
//     // Начинаем запись аудио
//     await flutterSound.startRecorder(toFile: filePath, codec: Codec.pcm16WAV);
//
//     // Ждем окончания записи
//     await Future.delayed(Duration(seconds: 10)); // Пример: запись длится 10 секунд
//
//     // Останавливаем запись
//     await flutterSound.stopRecorder();
//
//     // Печатаем путь к сохраненному файлу
//     print('Audio saved to: $filePath');
//     // setState(() {
//     //
//     // });
//   }
//
//   /// This has to happen only once per app
//   void _initSpeech() async {
//     _speechEnabled = await _speechToText.initialize();
//     setState(() {});
//   }
//
//   Future<void> startRecording() async {
//     FlutterSoundSystem.startRecording('assets/mp.wav');
//
//   }
//
//   Future<void> stopRecording() async {
//     await FlutterSoundSystem.stopRecording();
//   }
//   /// Each time to start a speech recognition session
//   void _startListening() async {
//     soundRecorderAndPlayer.toggleRecording().then( (value)
//     { _speechToText.listen(onResult: _onSpeechResult);
//     });
//     // startRecording();
//     setState(() {});
//     // _saveAudioToFile();
//
//   }
//
//   /// Manually stop the active speech recognition session
//   /// Note that there are also timeouts that each platform enforces
//   /// and the SpeechToText plugin supports setting timeouts on the
//   /// listen method.
//   void _stopListening() async {
//     // stopRecording();
//     await _speechToText.stop();
//     soundRecorderAndPlayer.toggleRecording();
//     setState(() {
//       // path = done_path;
//       print(path);
//     });
//
//     // Сохраняем аудио в файл
//     print('путь2');
//   }
//
//
//   /// This is the callback that the SpeechToText plugin calls when
//   /// the platform returns recognized words.
//   void _onSpeechResult(SpeechRecognitionResult result) {
//     setState(() {
//       _lastWords = result.recognizedWords;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Speech Demo'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Container(
//               padding: EdgeInsets.all(16),
//               child: Text(
//                 'Recognized words:',
//                 style: TextStyle(fontSize: 20.0),
//               ),
//             ),
//             Expanded(
//               child: Container(
//                 padding: EdgeInsets.all(16),
//                 child: Text(
//                   // If listening is active show the recognized words
//                   _speechToText.isListening
//                       ? '$_lastWords'
//                   // If listening isn't active but could be tell the user
//                   // how to start it, otherwise indicate that speech
//                   // recognition is not yet ready or not supported on
//                   // the target device
//                       : _speechEnabled
//                       ? 'Tap the microphone to start listening...'
//                       : 'Speech not available',
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed:
//         // If not yet listening for speech start, otherwise stop
//         _speechToText.isNotListening ? _startListening : _stopListening,
//         tooltip: 'Listen',
//         child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
//       ),
//     );
//   }
// }



// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key? key}) : super(key: key);
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   stt.SpeechToText _speech = stt.SpeechToText();
//   bool _isListening = false;
//   String _text = 'Press the button and start speaking';
//   String _audioFilePath = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _initSpeech();
//   }
//
//   void _initSpeech() async {
//     bool isAvailable = await _speech.initialize();
//     if (isAvailable) {
//       setState(() {});
//     } else {
//       print('The user has denied access to speech recognition');
//     }
//   }
//
//   void _startListening() async {
//     if (!_isListening) {
//       bool available = await _speech.initialize();
//       if (available) {
//         setState(() {
//           _isListening = true;
//           _text = 'Listening...';
//         });
//         _speech.listen(
//           onResult: (result) {
//             setState(() {
//               _text = result.recognizedWords;
//             });
//           },
//           listenFor: Duration(minutes: 1),
//           localeId: 'ru', // Change this to your desired language locale
//         );
//       } else {
//         print('Speech recognition is not available');
//       }
//     }
//   }
//
//   void _stopListening() {
//     if (_isListening) {
//       var path2 = _speech.stop();
//       setState(() {
//         _isListening = false;
//         // _audioFilePath = path2;
//
//       });
//     }
//   }
//
//   void _saveAudioToFile(String audioFilePath) async {
//     final Directory appDir = await getApplicationDocumentsDirectory();
//     final String appDirPath = appDir.path;
//     final String fileName = 'audio.wav';
//     final String filePath = 'assets/$fileName';
//
//     File audioFile = File(audioFilePath);
//     await audioFile.copy(filePath);
//
//     setState(() {
//       _audioFilePath = filePath;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Speech Recognition Demo'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(_text),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _startListening,
//               child: Text('Start Listening'),
//             ),
//             ElevatedButton(
//               onPressed: _stopListening,
//               child: Text('Stop Listening'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 _saveAudioToFile(_audioFilePath);
//               },
//               child: Text('Save Audio to File'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// class VoskFlutterDemo extends StatefulWidget {
//   const VoskFlutterDemo({Key? key}) : super(key: key);
//
//   @override
//   State<VoskFlutterDemo> createState() => _VoskFlutterDemoState();
// }
//
// class _VoskFlutterDemoState extends State<VoskFlutterDemo> {
//   static const _textStyle = TextStyle(fontSize: 30, color: Colors.black);
//   static const _modelName = 'assets/models/vosk-model-small-en-us-0.15';
//   static const _sampleRate = 16000;
//
//   final _vosk = VoskFlutterPlugin.instance();
//   final _modelLoader = ModelLoader();
//   final _recorder = FlutterSoundRecord();
//
//   String? _fileRecognitionResult;
//   String? _error;
//   Model? _model;
//   Recognizer? _recognizer;
//   SpeechService? _speechService;
//
//   bool _recognitionStarted = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _modelLoader
//         .loadModelsList()
//         .then((modelsList) =>
//         modelsList.firstWhere((model) => model.name == _modelName))
//         .then((modelDescription) =>
//         _modelLoader.loadFromNetwork(modelDescription.url)) // load model
//         .then(
//             (modelPath) => _vosk.createModel(modelPath)) // create model object
//         .then((model) => setState(() => _model = model))
//         .then((_) => _vosk.createRecognizer(
//         model: _model!, sampleRate: _sampleRate)) // create recognizer
//         .then((value) => _recognizer = value)
//         .then((recognizer) {
//       if (Platform.isAndroid) {
//         _vosk
//             .initSpeechService(_recognizer!) // init speech service
//             .then((speechService) =>
//             setState(() => _speechService = speechService))
//             .catchError((e) => setState(() => _error = e.toString()));
//       }
//     }).catchError((e) {
//       setState(() => _error = e.toString());
//       return null;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_error != null) {
//       return Scaffold(
//           body: Center(child: Text("Error: $_error", style: _textStyle)));
//     } else if (_model == null) {
//       return const Scaffold(
//           body: Center(child: Text("Loading model...", style: _textStyle)));
//     } else if (Platform.isAndroid && _speechService == null) {
//       return const Scaffold(
//         body: Center(
//           child: Text("Initializing speech service...", style: _textStyle),
//         ),
//       );
//     } else {
//       return Platform.isAndroid ? _androidExample() : _commonExample();
//     }
//   }
//
//   Widget _androidExample() {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//                 onPressed: () async {
//                   if (_recognitionStarted) {
//                     await _speechService!.stop();
//                   } else {
//                     await _speechService!.start();
//                   }
//                   setState(() => _recognitionStarted = !_recognitionStarted);
//                 },
//                 child: Text(_recognitionStarted
//                     ? "Stop recognition"
//                     : "Start recognition")),
//             StreamBuilder(
//                 stream: _speechService!.onPartial(),
//                 builder: (context, snapshot) => Text(
//                     "Partial result: ${snapshot.data.toString()}",
//                     style: _textStyle)),
//             StreamBuilder(
//                 stream: _speechService!.onResult(),
//                 builder: (context, snapshot) => Text(
//                     "Result: ${snapshot.data.toString()}",
//                     style: _textStyle)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _commonExample() {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//                 onPressed: () async {
//                   if (_recognitionStarted) {
//                     await _stopRecording();
//                   } else {
//                     await _recordAudio();
//                   }
//                   setState(() => _recognitionStarted = !_recognitionStarted);
//                 },
//                 child: Text(
//                     _recognitionStarted ? "Stop recording" : "Record audio")),
//             Text("Final recognition result: $_fileRecognitionResult",
//                 style: _textStyle),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _recordAudio() async {
//     try {
//       await _recorder.start(
//           samplingRate: 16000);
//     } catch (e) {
//       _error = e.toString() +
//           '\n\n Make sure fmedia(https://stsaz.github.io/fmedia/)'
//               ' is installed on Linux';
//     }
//   }
//
//   Future<void> _stopRecording() async {
//     try {
//       final filePath = await _recorder.stop();
//       if (filePath != null) {
//         final bytes = File(filePath).readAsBytesSync();
//         _recognizer!.acceptWaveformBytes(bytes);
//         _fileRecognitionResult = await _recognizer!.getFinalResult();
//       }
//     } catch (e) {
//       _error = e.toString() +
//           '\n\n Make sure fmedia(https://stsaz.github.io/fmedia/)'
//               ' is installed on Linux';
//     }
//   }
// }
//



const modelAsset = 'assets/models/vosk-model-small-en-us-0.15.zip';

// class TestScreen extends StatefulWidget {
//   const TestScreen({Key? key}) : super(key: key);
//
//   @override
//   State<TestScreen> createState() => _TestScreenState();
// }

// class _TestScreenState extends State<TestScreen> {
//   final VoskFlutterPlugin _vosk = VoskFlutterPlugin.instance();
//
//   Model? _model;
//   bool _modelLoading = false;
//
//   Recognizer? _recognizer;
//   SpeechService? _speechService;
//
//   String _grammar = 'hello world foo boo';
//   int _maxAlternatives = 2;
//   String _recognitionError = '';
//
//   String _message = "";
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Vosk Demo'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               height: 100,
//               padding: const EdgeInsets.all(5),
//               alignment: Alignment.topLeft,
//               decoration: const BoxDecoration(
//                   color: Colors.grey,
//                   borderRadius: BorderRadius.all(Radius.circular(5))),
//               child: Text(
//                 _message,
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//             const SizedBox(height: 5),
//             Expanded(
//               child: ListView(
//                 children: [
//                   Text("Model: $_model"),
//                   btn('model.create', _modelCreate, color: Colors.orange),
//                   const Divider(color: Colors.grey, thickness: 1),
//                   Text("Recognizer: $_recognizer"),
//                   btn('recognizer.create', _recognizerCreate,
//                       color: Colors.green),
//                   Row(
//                     children: [
//                       Flexible(
//                         child: btn('recognizer.setMaxAlternatives',
//                             _recognizerSetMaxAlternatives,
//                             color: Colors.green),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: Text(
//                           _maxAlternatives.toString(),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                       Flexible(
//                         child: Slider(
//                           value: _maxAlternatives.toDouble(),
//                           min: 0,
//                           max: 3,
//                           divisions: 3,
//                           onChanged: (val) => setState(() {
//                             _maxAlternatives = val.toInt();
//                           }),
//                         ),
//                       )
//                     ],
//                   ),
//                   btn('recognizer.setWords', _recognizerSetWords,
//                       color: Colors.green),
//                   btn('recognizer.setPartialWords', _recognizerSetPartialWords,
//                       color: Colors.green),
//                   Row(
//                     children: [
//                       Flexible(
//                         child: btn(
//                             'recognizer.setGrammar', _recognizerSetGrammar,
//                             color: Colors.green),
//                       ),
//                       const SizedBox(width: 20),
//                       Flexible(
//                         child: TextField(
//                           style: const TextStyle(color: Colors.black),
//                           controller: TextEditingController(text: _grammar),
//                           onChanged: (val) => setState(() {
//                             _grammar = val;
//                           }),
//                         ),
//                       )
//                     ],
//                   ),
//                   btn('recognizer.acceptWaveForm', _recognizerAcceptWaveForm,
//                       color: Colors.green),
//                   btn('recognizer.getResult', _recognizerGetResult,
//                       color: Colors.green),
//                   btn('recognizer.getPartialResult',
//                       _recognizerGetPartialResult,
//                       color: Colors.green),
//                   btn('recognizer.getFinalResult', _recognizerGetFinalResult,
//                       color: Colors.green),
//                   btn('recognizer.reset', _recognizerReset,
//                       color: Colors.green),
//                   btn('recognizer.close', _recognizerClose,
//                       color: Colors.green),
//                   const Divider(color: Colors.grey, thickness: 1),
//                   Text("SpeechService: $_speechService"),
//                   btn('speechService.init', _initSpeechService,
//                       color: Colors.lightBlueAccent),
//                   btn('speechService.start', _speechServiceStart,
//                       color: Colors.lightBlueAccent),
//                   btn('speechService.stop', _speechServiceStop,
//                       color: Colors.lightBlueAccent),
//                   btn('speechService.setPause', _speechServiceSetPause,
//                       color: Colors.lightBlueAccent),
//                   btn('speechService.reset', _speechServiceReset,
//                       color: Colors.lightBlueAccent),
//                   btn('speechService.cancel', _speechServiceCancel,
//                       color: Colors.lightBlueAccent),
//                   btn('speechService.destroy', _speechServiceDestroy,
//                       color: Colors.lightBlueAccent),
//                   const SizedBox(height: 20),
//                   if (_speechService != null)
//                     StreamBuilder(
//                         stream: _speechService?.onPartial(),
//                         builder: (_, snapshot) =>
//                             Text('Partial: ' + snapshot.data.toString())),
//                   if (_speechService != null)
//                     StreamBuilder(
//                         stream: _speechService?.onResult(),
//                         builder: (_, snapshot) =>
//                             Text('Result: ' + snapshot.data.toString())),
//                   if (_speechService != null)
//                     Text('Recognition error: $_recognitionError'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget btn(String text, VoidCallback onPressed, {Color? color}) {
//     return ElevatedButton(
//         onPressed: onPressed,
//         child: Text(text),
//         style: ButtonStyle(backgroundColor: MaterialStateProperty.all(color)));
//   }
//
//   void _toastFutureError(Future<Object?> future) =>
//       future.onError((error, _) => _showMessage(msg: error.toString()));
//
//   void _modelCreate() async {
//     if (_model != null) {
//       _showMessage(msg: 'The model is already loaded');
//       return;
//     }
//
//     if (_modelLoading) {
//       _showMessage(msg: 'The model is loading right now');
//       return;
//     }
//     _modelLoading = true;
//
//     _toastFutureError(_vosk
//         .createModel(await ModelLoader().loadFromAssets(modelAsset))
//         .then((value) => setState(() => _model = value)));
//   }
//
//   void _recognizerCreate() async {
//     final localModel = _model;
//     if (localModel == null) {
//       _showMessage(msg: 'Create the model first');
//       return;
//     }
//
//     _toastFutureError(_vosk
//         .createRecognizer(model: localModel, sampleRate: 16000)
//         .then((value) => setState(() => _recognizer = value)));
//   }
//
//   void _recognizerSetMaxAlternatives() async {
//     final localRecognizer = _recognizer;
//     if (localRecognizer == null) {
//       _showMessage(msg: 'Create the recognizer first');
//       return;
//     }
//
//     _toastFutureError(localRecognizer.setMaxAlternatives(_maxAlternatives));
//   }
//
//   void _recognizerSetWords() async {
//     final localRecognizer = _recognizer;
//     if (localRecognizer == null) {
//       _showMessage(msg: 'Create the recognizer first');
//       return;
//     }
//
//     _toastFutureError(localRecognizer.setWords(words: true));
//   }
//
//   void _recognizerSetPartialWords() async {
//     final localRecognizer = _recognizer;
//     if (localRecognizer == null) {
//       _showMessage(msg: 'Create the recognizer first');
//       return;
//     }
//
//     _toastFutureError(localRecognizer.setPartialWords(partialWords: true));
//   }
//
//   void _recognizerSetGrammar() async {
//     final localRecognizer = _recognizer;
//     if (localRecognizer == null) {
//       _showMessage(msg: 'Create the recognizer first');
//       return;
//     }
//
//     _toastFutureError(localRecognizer.setGrammar(_grammar.split(' ')));
//   }
//
//   void _recognizerAcceptWaveForm() async {
//     final localRecognizer = _recognizer;
//     if (localRecognizer == null) {
//       _showMessage(msg: 'Create the recognizer first');
//       return;
//     }
//
//     _toastFutureError(localRecognizer
//         .acceptWaveformBytes((await rootBundle.load('assets/audio/test.wav'))
//         .buffer
//         .asUint8List())
//         .then((value) => _showMessage(msg: value.toString())));
//   }
//
//   void _recognizerGetResult() async {
//     final localRecognizer = _recognizer;
//     if (localRecognizer == null) {
//       _showMessage(msg: 'Create the recognizer first');
//       return;
//     }
//
//     _toastFutureError(localRecognizer
//         .getResult()
//         .then((value) => _showMessage(msg: value.toString())));
//   }
//
//   void _recognizerGetPartialResult() async {
//     final localRecognizer = _recognizer;
//     if (localRecognizer == null) {
//       _showMessage(msg: 'Create the recognizer first');
//       return;
//     }
//
//     _toastFutureError(localRecognizer
//         .getPartialResult()
//         .then((value) => _showMessage(msg: value.toString())));
//   }
//
//   void _recognizerGetFinalResult() async {
//     final localRecognizer = _recognizer;
//     if (localRecognizer == null) {
//       _showMessage(msg: 'Create the recognizer first');
//       return;
//     }
//
//     _toastFutureError(localRecognizer
//         .getFinalResult()
//         .then((value) => _showMessage(msg: value.toString())));
//   }
//
//   void _recognizerReset() async {
//     final localRecognizer = _recognizer;
//     if (localRecognizer == null) {
//       _showMessage(msg: 'Create the recognizer first');
//       return;
//     }
//
//     _toastFutureError(localRecognizer.reset());
//   }
//
//   void _recognizerClose() async {
//     final localRecognizer = _recognizer;
//     if (localRecognizer == null) {
//       _showMessage(msg: 'Create the recognizer first');
//       return;
//     }
//
//     _toastFutureError(
//         localRecognizer.dispose().then((_) => _recognizer = null));
//   }
//
//   void _initSpeechService() async {
//     final localRecognizer = _recognizer;
//     if (localRecognizer == null) {
//       _showMessage(msg: 'Create the recognizer first');
//       return;
//     }
//
//     _toastFutureError(_vosk
//         .initSpeechService(localRecognizer)
//         .then((value) => setState(() => _speechService = value)));
//   }
//
//   void _speechServiceStart() async {
//     final localSpeechService = _speechService;
//     if (localSpeechService == null) {
//       _showMessage(msg: 'Create the speech service first');
//       return;
//     }
//
//     _toastFutureError(localSpeechService
//         .start(
//         onRecognitionError: (error) =>
//             setState(() => _recognitionError = error.toString()))
//         .then((value) => _showMessage(msg: value.toString())));
//   }
//
//   void _speechServiceStop() async {
//     final localSpeechService = _speechService;
//     if (localSpeechService == null) {
//       _showMessage(msg: 'Create the speech service first');
//       return;
//     }
//
//     _toastFutureError(localSpeechService
//         .stop()
//         .then((value) => _showMessage(msg: value.toString())));
//   }
//
//   void _speechServiceSetPause() async {
//     final localSpeechService = _speechService;
//     if (localSpeechService == null) {
//       _showMessage(msg: 'Create the speech service first');
//       return;
//     }
//
//     _toastFutureError(localSpeechService.setPause(paused: true));
//   }
//
//   void _speechServiceReset() async {
//     final localSpeechService = _speechService;
//     if (localSpeechService == null) {
//       _showMessage(msg: 'Create the speech service first');
//       return;
//     }
//
//     _toastFutureError(localSpeechService.reset());
//   }
//
//   void _speechServiceCancel() async {
//     final localSpeechService = _speechService;
//     if (localSpeechService == null) {
//       _showMessage(msg: 'Create the speech service first');
//       return;
//     }
//
//     _toastFutureError(localSpeechService
//         .cancel()
//         .then((value) => _showMessage(msg: value.toString())));
//   }
//
//   void _speechServiceDestroy() async {
//     final localSpeechService = _speechService;
//     if (localSpeechService == null) {
//       _showMessage(msg: 'Create the speech service first');
//       return;
//     }
//
//     _toastFutureError(localSpeechService
//         .dispose()
//         .then((value) => setState(() => _speechService = null)));
//   }
//
//   void _showMessage({required String msg}) {
//     setState(() {
//       _message = msg;
//     });
//   }
// }
//



// class SpeechDemo extends StatefulWidget {
//   const SpeechDemo({Key? key}) : super(key: key);
//
//   @override
//   State<SpeechDemo> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<SpeechDemo> {
//   final VoiceToText _speech = VoiceToText();
//   final FlutterSoundRecord audioRecorder = FlutterSoundRecord();
//   String text = ""; //this is optional, I could get the text directly using speechResult
//   @override
//   void initState() {
//     super.initState();
//     _speech.initSpeech();
//     _speech.addListener(() {
//       setState(() {
//         text = _speech.speechResult;
//       });
//     });
//   }
//
//   start() {
//     _speech.startListening;
//     audioRecorder.start();
//
//   }
//
//   stop() {
//     audioRecorder.stop();
//     _speech.stop;
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Speech Demo'),
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(10),
//         alignment: Alignment.center,
//         child: Column(
//           textBaseline: TextBaseline.alphabetic,
//           children: <Widget>[
//             Text(
//                 _speech.isListening
//                     ? "Listening...."
//                     : 'Tap the microphone to start',
//                 style:
//                 const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             Text(_speech.isNotListening
//                 ? text.isNotEmpty
//                 ? text
//                 : "Try speaking again"
//                 : ""),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed:
//         // If not yet listening for speech start, otherwise stop
//         _speech.isNotListening ? start : stop,
//         tooltip: 'Listen',
//         child: Icon(_speech.isNotListening ? Icons.mic_off : Icons.mic),
//       ),
//     );
//   }
// }
//






class MyHomePage extends StatefulWidget {
  // final String audioPath;
  // MyHomePage(this.audioPath);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var model;
  String audio = "";
  String result = "";
  bool is_procces = false;

  loadModel() async {
    FirebaseStorage.instance.ref().child('models/ggml-tiny.bin');
    Directory tempDir = await getTemporaryDirectory();
    File downloadToFile = File('${tempDir.path}/model.bin');
    print('deif');
    final bytes = await rootBundle.load('./assets/models/ggml-tiny.bin');
    print('ав');
    await downloadToFile.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    setState(() {
      model = downloadToFile.path;
    });
  }

  @override
  void initState() {
    loadModel();
    super.initState();
  }

  Future<void> _convertToWav(File inputFile) async {
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    final User user = FirebaseAuth.instance.currentUser!;

    Directory tempDir = await getTemporaryDirectory();
    String outputFilePath = '${tempDir.path}/${inputFile.path.split('/').last.split('.').first}_16k.wav';

    String command = '-i ${inputFile.path} -ar 16000 -t 20 $outputFilePath';

    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();

      try {
        var _outputFile = File(outputFilePath);

        if (_outputFile.existsSync()) {
          print('Conversion successful: $outputFilePath');
          print(_outputFile.path);
          var filePath = '${user.uid}';

          try {
            await firebaseStorage
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

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: SingleChildScrollView(
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
                          onPressed: () async {
                            FilePickerResult? resul =
                            await FilePicker.platform.pickFiles();

                            if (resul != null) {
                              File file = File(resul.files.single.path!);


                              if (file.existsSync()) {
                                _convertToWav(file);
                                loadModel();
                                // setState(() {
                                //   audio = file.path;
                                // });
                              }
                            }
                          },
                          child: const Text("set audio"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (is_procces) {
                              return print(
                                  "Please wait for the process to finish");
                              //   await CoolAlert.show(
                              //   context: context,
                              //   type: CoolAlertType.info,
                              //   text: "Please wait for the process to finish",
                              // );
                            }
                            if (audio.isEmpty) {
                              print(
                                  "Sorry, the audio is empty, please set it first");
                              if (kDebugMode) {
                                print("audio is empty");
                              }
                              return;
                            }

                            if (!model.isEmpty) {
                            Future(() async {
                              // ignore: avoid_print
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
                                is_procces = false;
                              });
                            });
                            setState(() {
                              is_procces = true;
                            });
                          }
                            else {
                              print('файла нет');
                            }
                          },
                          child: const Text("Start"),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text("model: ${model}"),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text("audio: ${audio}"),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text("Result: ${result}"),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
