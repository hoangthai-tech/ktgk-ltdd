import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/exam_provider.dart';
import 'screens/home_portal_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ToeicExamApp());
}

class ToeicExamApp extends StatelessWidget {
  const ToeicExamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExamProvider()),
      ],
      child: MaterialApp(
        title: 'TOEIC Reading Practice Test',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B365D),
            primary: const Color(0xFF1B365D),
            secondary: const Color(0xFF0066CC),
            surface: const Color(0xFFF4F6F9),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1B365D),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            surfaceTintColor: Colors.transparent,
          ),
          fontFamily: 'Segoe UI',
        ),
        home: const HomePortalScreen(),
      ),
    );
  }
}
