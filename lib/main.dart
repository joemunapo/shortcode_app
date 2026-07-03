import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'features/shortcode/presentation/screens/shortcode_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemUiOverlayStyle);
  runApp(const ShortcodeApp());
}

class ShortcodeApp extends StatelessWidget {
  const ShortcodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shortcode',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const ShortcodeScreen(),
    );
  }
}
