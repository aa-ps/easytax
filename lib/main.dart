import 'package:easytax/screens/dashboard.dart';
import 'package:easytax/screens/demographic.dart';
import 'package:easytax/screens/main.dart';
import 'package:easytax/screens/login.dart';
import 'package:easytax/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';

void main() async {
  await Supabase.initialize(
    url: 'SUPABASE_URL',
    anonKey:
        'SUPABASE_ANON_KEY',
  );

  String themeStr = await rootBundle.loadString("assets/theme.json");
  dynamic themeJson = jsonDecode(themeStr);
  ThemeData theme = ThemeDecoder.decodeThemeData(themeJson)!;
  runApp(MyApp(theme: theme));
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  final ThemeData theme;
  const MyApp({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EasyTax',
        theme: theme,
        initialRoute: "/",
        routes: <String, WidgetBuilder>{
          "/": (_) => const SplashScreen(),
          "/dashboard": (_) => const DashBoardScreen(),
          "/login": (_) => const LoginScreen(),
          "/demographic": (_) => const DemographicScreen(),
          "/main": (_) => const MainScreen(),
        });
  }
}
