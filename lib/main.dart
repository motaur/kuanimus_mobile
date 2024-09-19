import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:kuanimus/agreement_page.dart';

import 'chat_page.dart';

class Constants {
  static const String userBox = 'userBox';
  static const String emailKey = 'email';
}


void main() async {
  await Hive.initFlutter();
  await Hive.openBox(Constants.userBox);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Hive.box(Constants.userBox).get(Constants.emailKey) == null
          ? const AgreementPage()
          : const ChatPage(),
    );
  }
}


