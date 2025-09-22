import 'package:clubify/common/constants/colors.dart';
import 'package:clubify/features/announcements/screens/announcementScreen.dart';
import 'package:clubify/features/home/Screens/homeScreen.dart';
import 'package:clubify/features/login_page/Screens/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [SystemUiOverlay.top],
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await dotenv.load(fileName: ".env");
  final supabaseUrl = dotenv.env["SUPABASE_URL"]!;
  final supabaseKey = dotenv.env["SUPABASE_KEY"]!;
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clubify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AuthCheck(),
      // onGenerateRoute: ,
    );
  }
}

class AuthCheck extends StatelessWidget {
  final supabase = Supabase.instance.client;
  AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator(color: primaryColor)),
          );
        }

        if (session != null) {
          return HomeScreen(title: "CLUBIFY");
        } else {
          return Loginscreen();
        }
      },
    );
  }
}
