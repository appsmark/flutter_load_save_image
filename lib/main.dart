import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

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
      home: const Experiment(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class Experiment extends StatefulWidget {
  const Experiment({super.key});

  @override
  State<Experiment> createState() => _Experiment();
}

class _Experiment extends State<Experiment> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF731816),
        appBar: AppBar(
          backgroundColor: const Color(0xFF731816),
          foregroundColor: const Color(0xFF00AADE),
          title: const Text("SAVE & SHOW LOCAL IMAGES"),
        ),
        body: Center(
          child: Column(children: [
            MaterialButton(
                child: Image.asset(
                  "assets/images/gallery.png",
                  height: 0.1 * MediaQuery.of(context).size.height,
                ),
                onPressed: () {
                  loadFromGallery();
                }),
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 3, color: const Color(0xFF00AADE)),
              ),
              child: RepaintBoundary(
                key: _globalKey,
                child: SizedBox(
                  height: 0.5 * MediaQuery.of(context).size.height,
                  width: 0.3 * MediaQuery.of(context).size.width,
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
