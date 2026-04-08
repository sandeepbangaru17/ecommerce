import 'package:flutter/material.dart';
import 'api/api_client.dart';
import 'screens/home_screen.dart';
import 'theme/customer_app_theme.dart';

void main() {
  runApp(const EcommerceApp());
}

class EcommerceApp extends StatelessWidget {
  const EcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    return MaterialApp(
      title: 'Aurum Collective',
      debugShowCheckedModeBanner: false,
      theme: CustomerAppTheme.build(),
      home: HomeScreen(apiClient: apiClient),
    );
  }
}
