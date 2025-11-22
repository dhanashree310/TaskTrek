import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'constants/theme.dart';
import 'providers/theme_provider.dart';
import 'screens/profile_screen.dart ';

class RemindApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Remind',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/', // SplashScreen will handle auth redirect
      routes: {
        '/': (_) => SplashScreen(),
        '/home': (_) => HomeScreen(),
        '/add': (_) => AddTaskScreen(),
        '/calendar': (_) => CalendarScreen(),
        '/login': (_) => LoginScreen(),
        '/register': (_) => RegisterScreen(),
        '/profile': (_) => ProfileScreen(),
      },
    );
  }
}
