import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static int _nextMediaId = 0;
  final _audioSource = LockCachingAudioSource(
    Uri.parse(
        "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3"),
    tag: MediaItem(
      id: '${_nextMediaId++}',
      album: "Science Friday",
      title: "A Salute To Head-Scratching Science",
      artUri: Uri.parse(
          "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
    ),
  );

  @override
  void initState() {
    super.initState();
    _audioSource.clearCache();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _init();
  }

  Future<void> _prefetch() async {
    try {
      print("Beginning prefetch");
      final response = await _audioSource.request();
      await for (List<int> bytes in response.stream) {
        final length = bytes.length;
        print('received $length bytes');
      }
      print("Finished prefetching");
    } catch (e) {
      print("Error while prefetching: $e");
    }
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: _prefetch, child: Text("Prefetch"))
            ],
          ),
        ),
      ),
    );
  }
}
