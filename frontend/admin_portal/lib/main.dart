import 'package:flutter/material.dart';
import 'api/api_client.dart';
import 'screens/login_screen.dart';
import 'theme/admin_app_theme.dart';

void main() {
  runApp(const AdminPortalApp());
}

class AdminPortalApp extends StatelessWidget {
  const AdminPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aurum Control Room',
      debugShowCheckedModeBanner: false,
      theme: AdminAppTheme.build(),
      home: AdminLoginScreen(apiClient: ApiClient()),
    );
  }
}
