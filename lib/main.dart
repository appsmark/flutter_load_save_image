import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/rendering.dart';

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
    MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF731816),
      ),
      home: const LocalImage(),
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

  loadFromFiles() {}
  saveToFiles() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF731816),
        appBar: AppBar(
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
                /*
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                        child: Image.asset(
                          "assets/images/to_files.png",
                          height: 0.1 * MediaQuery.of(context).size.height,
                        ),
                        onPressed: () {
                          saveToFiles();
                        }),
                    MaterialButton(
                        child: Image.asset(
                          "assets/images/from_files.png",
                          height: 0.1 * MediaQuery.of(context).size.height,
                        ),
                        onPressed: () {
                          loadFromFiles();
                        }),
                  ],
                  
                ),*/
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                        child: Image.asset(
                          Platform.isAndroid
                              ? "assets/images/to_gallery_android.png"
                              : "assets/images/to_gallery_ios.png",
                          height: 0.1 * MediaQuery.of(context).size.height,
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
