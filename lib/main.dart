import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'screens/login_page.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory =
        databaseFactoryFfiWeb;
  }

  runApp(
    const StudentInformationSystem(),
  );
}

class StudentInformationSystem
    extends StatelessWidget {
  const StudentInformationSystem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title:
          'Student Information System 2.0',
      theme: AppTheme.theme,
      home: const LoginPage(),
    );
  }
}