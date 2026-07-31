import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/screens/splash_screen.dart';


class HorusApp extends StatelessWidget {

  const HorusApp({
    super.key,
  });


  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: "Horus Academy",

      theme: AppTheme.light,

      home: const SplashScreen(),

    );

  }

}