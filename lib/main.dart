import 'package:flutter/material.dart';
import 'dart:ffi';
import 'dart:io';
import 'wrapper.dart';
 
void main() {
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
    final glasswall = Glasswall(dllPath: r'C:\vessel guard\glasswall\libs\windows\x86-64\sdk_editor\glasswall_core2.dll');
    
    glasswall.protectFile(
      licencePath: r'C:\vessel guard\glasswall\gwkey.lic',
      inputPath: r'C:\vessel guard\test2.docx',
      outputPath: r'C:\vessel guard\test2_protected.docx',
    );
    print('File protected successfully.');
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
                  testGlasswall();
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