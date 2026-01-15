import 'package:fire_note/login_page.dart';
import 'package:fire_note/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'home_page.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
          bodySmall: TextStyle(
            fontSize: 17
          ),
          headlineLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20
          ),
            headlineSmall: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
            ),
            headlineMedium: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15
        )
        )
      ),

      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: SplashScreen(),
    );

  }

}
