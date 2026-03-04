import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:ffi';
import 'dart:io';
import 'wrapper.dart';
import 'filetype.dart';
 
late final String sdkEditor;
late final String glasswallPath;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  sdkEditor = dotenv.env['SDKEDITOR']!;
  glasswallPath = dotenv.env['GLASSWALL_PATH']!;

  runApp(const MyApp());
}
 
class MyApp extends StatefulWidget {
  const MyApp({super.key});
 
  @override
  State<MyApp> createState() => _MyAppState();
}
 
class _MyAppState extends State<MyApp> {
  String screenText = 'Press the button to create a session';
 
  void testGlasswall() {
    final glasswall = Glasswall(dllPath: '$sdkEditor\\glasswall_core2.dll');
    
    glasswall.protectFile(
      licencePath: '$glasswallPath\\gwkey.lic',
      inputPath: '$glasswallPath\\test2.docx',
      outputPath: '$glasswallPath\\test2_protected.docx',
    );
    print('File protected successfully.');
  }

  void testFileType() {
    final glasswall = Glasswall(dllPath: '$sdkEditor\\glasswall_core2.dll');

    final fileType = glasswall.checkFileType('$glasswallPath\\tablet_identity.csv');
    final name = GlasswallFileTypes.getName(fileType);

    setState(() {
      screenText = "File Type Returned: $name";
    });
  }
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glasswall Test',
      home: Scaffold(
        appBar: AppBar(title: const Text('Glasswall Test')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(screenText),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  testFileType();
                },
                child: const Text('Test'),
              ),
            ]
          )
        )
      )
    );
  }
}