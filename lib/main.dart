import 'package:flutter/material.dart';
import 'nato_phonetic_alphabet.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SpeechCounter(),
    );
  }
}

class SpeechCounter extends StatefulWidget {
  @override
  _SpeechCounterState createState() => _SpeechCounterState();
}


class _SpeechCounterState extends State<SpeechCounter> {

  String translatedWord = "";
  SpeechToText _speechToText = SpeechToText();
  String _text = '';

  @override
  void initState() {
    super.initState();
    //_speechToText = stt.SpeechToText();
    _initSpeech();
  }

  void _initSpeech() async {
    final PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus == PermissionStatus.denied) {
      dialogBox("Please enable mic permission");
    }
    await _speechToText.initialize();
    setState(() {
    });
  }

  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.microphone.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
      await [Permission.microphone].request();
      return permissionStatus[Permission.microphone] ??
          PermissionStatus.permanentlyDenied;
    } else {
      return permission;
    }
  }

  void _startListening() async {
    await _speechToText.listen(
        onResult: _onSpeechResult
    );
    setState(() {
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _text = result.recognizedWords;
      if(kDebugMode) {
        print(_text);
      }
      List<String> words = _text.split(" "); // Split the string into words
      for(String word in words){
        String? res = invertedNatoPhoneticAlphabet[word];
        if(res == null) {
          continue;
        }
        translatedWord = translatedWord + res;
      }
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
    });
  }

  dialogBox(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(message),
          content: const Column(
              mainAxisSize: MainAxisSize.min
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text("Nato-phonetic speech decoder"),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
            color: Colors.lightBlueAccent.shade100,
            image: const DecorationImage(image : AssetImage("assets/images/compass.png" ), opacity: 0.1)
        ),
        child:
        Center(
          child:
          SingleChildScrollView(
            child:
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  translatedWord,
                  style:  const TextStyle(fontWeight: FontWeight.bold,),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            padding:  EdgeInsets.all(20),
          ),
          onPressed: _speechToText.isListening ? _stopListening : _startListening,
          child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic, size: 40,),
        ),
    );
  }
}
