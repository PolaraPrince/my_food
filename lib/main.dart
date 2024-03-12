import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:my_food/admin/add_food.dart';
import 'package:my_food/admin/home_admin.dart';
import 'package:my_food/firebase_options.dart';
import 'package:my_food/pages/banner.dart';
import 'package:my_food/pages/bottomnav.dart';
import 'package:my_food/pages/home.dart';
import 'package:my_food/pages/login.dart';
import 'package:my_food/pages/onboard.dart';
import 'package:my_food/pages/profile.dart';
import 'package:my_food/pages/signup.dart';
import 'package:my_food/pages/wallet.dart';
import 'package:my_food/widget/app_constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = publishableKey;
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey:
          "AIzaSyAR7ylnBW5zgg3d9a-BkwOVSlQiBf8ZIoM", // paste your api key here
      appId:
          "1:485339877723:android:4f3cfc6359d1bce035ca7e", //paste your app id here
      messagingSenderId: "485339877723", //paste your messagingSenderId here
      projectId:
          "fooddeliveryapp-1fe78", //paste your project id here  WidgetsFlutterBinding.ensureInitialized();
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: BottomNev());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounter() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(),
    );
  }
}
