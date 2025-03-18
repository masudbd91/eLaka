import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'services/auth_service.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [Provider<AuthService>(create: (_) => AuthService())],
      child: MaterialApp(
        title: 'elaka',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.login,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
