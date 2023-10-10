/*
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Reading and Writing Files',
      home: FlutterDemo(storage: CounterStorage()),
    ),
  );
}

class CounterStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<File> writeCounter(int counter) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$counter');
  }
}

class FlutterDemo extends StatefulWidget {
  const FlutterDemo({super.key, required this.storage});

  final CounterStorage storage;

  @override
  State<FlutterDemo> createState() => _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    widget.storage.readCounter().then((value) {
      setState(() {
        _counter = value;
      });
    });
  }

  Future<File> _incrementCounter() {
    setState(() {
      _counter++;
    });

    // Write the variable as a string to the file.
    return widget.storage.writeCounter(_counter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading and Writing Files'),
      ),
      body: Center(
        child: Text(
          'Button tapped $_counter time${_counter == 1 ? '' : 's'}.',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
*/

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Device orientation
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Suppress statusbar
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom]);

  Permissions.requestAll();

  runApp(
    const MaterialApp(
      home: LocalImage(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class LocalImage extends StatefulWidget {
  const LocalImage({super.key});

  @override
  State<LocalImage> createState() => _LocalImage();
}

class _LocalImage extends State<LocalImage> {
  File? image;
  final GlobalKey _globalKey = GlobalKey();
  String imageName = "MyPicture.png";

  Future loadFromGallery() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() {
        this.image = imageTemp;
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }

  Future takeImageWithCamera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }

  Future saveToGallery() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData =
        await (image.toByteData(format: ui.ImageByteFormat.png));
    if (byteData != null) {
      final result =
          await ImageGallerySaver.saveImage(byteData.buffer.asUint8List());
      if (result.toString().contains("isSuccess: true")) {
        return true;
      }
    }
  }

  Future loadFromFiles(String name) async {
    final directory = await getExternalStorageDirectory();
    // getTemporaryDirectory();
    // getApplicationDocumentsDirectory();
    final myImagePath = directory?.path;
    final imageTemp = File("$myImagePath/$name");
    setState(() {
      image = imageTemp;
    });
  }

  Future saveToFiles(String name) async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData =
        await (image.toByteData(format: ui.ImageByteFormat.png));
    if (byteData != null) {
      final directory = await getExternalStorageDirectory();
      // getTemporaryDirectory();
      // getApplicationDocumentsDirectory();
      if (directory != null) {
        debugPrint(directory.toString());
        final myImagePath = directory.path;
        await Directory(myImagePath).create();
        final file = File("$myImagePath/$name");
        final buffer = byteData.buffer;
        await file.writeAsBytes(
            buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF731816),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xFF731816),
          foregroundColor: const Color(0xFF00AADE),
          title: const Text("LOCAL IMAGE"),
        ),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(
                    child: Image.asset(
                      "assets/images/camera.png",
                      height: 0.1 * MediaQuery.of(context).size.height,
                    ),
                    onPressed: () {
                      takeImageWithCamera();
                    }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                        child: Image.asset(
                          "assets/images/to_files.png",
                          height: 0.1 * MediaQuery.of(context).size.height,
                          width: 0.1 * MediaQuery.of(context).size.height,
                        ),
                        onPressed: () {
                          saveToFiles(imageName);
                        }),
                    MaterialButton(
                        child: Image.asset(
                          "assets/images/from_files.png",
                          height: 0.1 * MediaQuery.of(context).size.height,
                          width: 0.1 * MediaQuery.of(context).size.height,
                        ),
                        onPressed: () {
                          loadFromFiles(imageName);
                        }),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                        child: Image.asset(
                          Platform.isAndroid
                              ? "assets/images/to_gallery_android.png"
                              : "assets/images/to_gallery_ios.png",
                          height: 0.1 * MediaQuery.of(context).size.height,
                          width: 0.1 * MediaQuery.of(context).size.height,
                        ),
                        onPressed: () {
                          saveToGallery();
                        }),
                    MaterialButton(
                        child: Image.asset(
                          Platform.isAndroid
                              ? "assets/images/from_gallery_android.png"
                              : "assets/images/from_gallery_ios.png",
                          height: 0.1 * MediaQuery.of(context).size.height,
                          width: 0.1 * MediaQuery.of(context).size.height,
                        ),
                        onPressed: () {
                          loadFromGallery();
                        }),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    border:
                        Border.all(width: 3, color: const Color(0xFF00AADE)),
                  ),
                  child: RepaintBoundary(
                    key: _globalKey,
                    child: SizedBox(
                      height: 0.5 * MediaQuery.of(context).size.height,
                      width: 0.7 * MediaQuery.of(context).size.width,
                      child: image != null
                          ? Image.file(image!)
                          : Center(
                              child: Text("PLACEHOLDER",
                                  style: TextStyle(
                                      color: const Color(0xFFF9B234),
                                      fontSize: 0.03 *
                                          MediaQuery.of(context).size.height)),
                            ),
                    ),
                  ),
                ),
              ]),
        ));
  }
}

class Permissions {
  static List<Permission> androidPermissions = <Permission>[Permission.storage];
  static List<Permission> iosPermissions = <Permission>[Permission.storage];

  static Future<Map<Permission, PermissionStatus>> requestAll() async {
    if (Platform.isIOS) {
      return await iosPermissions.request();
    }
    return await androidPermissions.request();
  }

  static Future<Map<Permission, PermissionStatus>> request(
      Permission permission) async {
    final List<Permission> permissions = <Permission>[permission];
    return await permissions.request();
  }
}
