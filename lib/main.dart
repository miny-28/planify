
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'presentation/screens/login_screen.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized();

await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);

await GoogleSignIn.instance.initialize();

runApp(const MyApp());
}

class MyApp extends StatefulWidget {
const MyApp({super.key});

@override
State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
ThemeMode _themeMode = ThemeMode.dark;

void toggleTheme() {
setState(() {
if (_themeMode == ThemeMode.dark) {
_themeMode = ThemeMode.light;
} else {
_themeMode = ThemeMode.dark;
}
});
}

@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
title: 'Planify',

themeMode: _themeMode,

theme: ThemeData(
brightness: Brightness.light,
scaffoldBackgroundColor: Colors.white,
colorScheme: ColorScheme.fromSeed(
seedColor: Colors.blue,
brightness: Brightness.light,
),
inputDecorationTheme: InputDecorationTheme(
filled: true,
fillColor: Colors.grey.shade100,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide: BorderSide.none,
),
),
),

darkTheme: ThemeData(
brightness: Brightness.dark,
scaffoldBackgroundColor: Colors.black,
colorScheme: ColorScheme.fromSeed(
seedColor: Colors.blue,
brightness: Brightness.dark,
),
inputDecorationTheme: InputDecorationTheme(
filled: true,
fillColor: const Color(0xFF1A1A1A),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide: BorderSide.none,
),
),
),

home: LoginScreen(
onToggleTheme: toggleTheme,
isDarkMode: _themeMode == ThemeMode.dark,
),
);
}
}
