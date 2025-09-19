import 'dart:async';
import 'dart:convert';
import 'package:befab/Screens/ActivityCalendarPage.dart';
import 'package:befab/Screens/ActivityFitness.dart';
import 'package:befab/Screens/AddMeal.dart';
import 'package:befab/Screens/AddMeal2.dart';
import 'package:befab/Screens/AllNewsLetterScreen.dart';
import 'package:befab/Screens/AllReels.dart';
import 'package:befab/Screens/BodyCompositionScreen.dart';
import 'package:befab/Screens/ChatScreen.dart';
import 'package:befab/Screens/CompetitionsActiveCompetitions.dart';
import 'package:befab/Screens/CompetitionsProgressPage.dart';
import 'package:befab/Screens/DashboardScreen.dart';
import 'package:befab/Screens/FitnessSummary.dart';
import 'package:befab/Screens/ForgotPassword1.dart';
import 'package:befab/Screens/ForgotPassword2.dart';
import 'package:befab/Screens/ForgotPassword3.dart';
import 'package:befab/Screens/ForgotPassword4.dart';
import 'package:befab/Screens/GroupsScreen.dart';
import 'package:befab/Screens/HydrationTracker.dart';
import 'package:befab/Screens/MealLogging.dart';
import 'package:befab/Screens/MessagesScreen.dart';
import 'package:befab/Screens/NewGoalEntryForm.dart';
import 'package:befab/Screens/NewsLetterScreen.dart';
import 'package:befab/Screens/Nutrition.dart';
import 'package:befab/Screens/Nutrition2.dart';
import 'package:befab/Screens/ProfileScreen.dart';
import 'package:befab/Screens/SettingsScreen.dart';
import 'package:befab/Screens/Reel.dart';
import 'package:befab/Screens/SearchFood.dart';
import 'package:befab/Screens/SignInScreen.dart';
import 'package:befab/Screens/SignUpScreen.dart';
import 'package:befab/Screens/SingleNewsLetterScreen.dart';
import 'package:befab/Screens/DeepDiveScreen.dart';
import 'package:befab/Screens/SingleReel.dart';
import 'package:befab/Screens/SingleVideoScreen.dart';
import 'package:befab/Screens/SplashScreen.dart';
import 'package:befab/Screens/SurveyScreen.dart';
import 'package:befab/Screens/SurveyStartScreen.dart';
import 'package:befab/Screens/VideoCategoriesScreen.dart';
import 'package:befab/Screens/VitalsMeasurement.dart';
import 'package:befab/Screens/WelcomeScreen.dart';
import 'package:befab/components/FitnessGroup.dart';
import 'package:befab/components/notifications_popup.dart';
import 'package:befab/services/health_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

final storage = FlutterSecureStorage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Ensure status bar is visible and styled
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _pingTimer;

  @override
  void initState() {
    super.initState();
    _startPingIfNeeded();
  }

  void _startPingIfNeeded() async {
    final userId = await storage.read(key: 'userId');
    if (userId == null) return;

    final backendUrl = dotenv.env['BACKEND_URL'] ?? '';
    if (backendUrl.isEmpty) return;

    // Immediately ping once
    _ping(userId, backendUrl);

    // Start periodic ping every 5 seconds
    _pingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _ping(userId, backendUrl);
    });
  }

  Future<void> _ping(String userId, String backendUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/ping'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        debugPrint('Ping successful: ${response.body}');
      } else {
        debugPrint('Ping failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error pinging server: $e');
    }
  }

  @override
  void dispose() {
    _pingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BeFAB HBCU',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF862633),
        fontFamily: 'Helvetica',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/signup': (context) => SignUpScreen(),
        '/signin': (context) => SignInScreen(),
        '/forgot-password-1': (context) => ForgotPassword1(),
        '/forgot-password-2': (context) => ForgotPassword2(),
        '/forgot-password-3': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return ForgotPassword3(otp: args["otp"]);
        },

        '/forgot-password-4': (context) => ForgotPassword4(),
        '/newsletter': (context) => NewsletterScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/single-newsletter': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          final newsletterId = args?['newsletterId'];

          return SingleNewsletterScreen(newsletterId: newsletterId);
        },
        '/all-newsletters': (context) => AllNewslettersScreen(),
        '/video-categories': (context) => VideoCategoriesScreen(),
        '/single-video': (context) => SingleVideoScreen(),
        '/all-reels': (context) => AllReels(),
        '/single-reel': (context) => SingleReel(),
        '/reel': (context) => Reel(),
        '/deep-dive': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;

          final deepDives = args?['deepDives'] as List<dynamic>? ?? [];

          return DeepDiveScreen(deepDives: deepDives);
        },
        '/message': (context) => MessagesPage(),
        '/chat-screen': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;

          if (args == null ||
              args['chatId'] == null ||
              args['userId'] == null) {
            return const Scaffold(
              body: Center(child: Text("Missing chat arguments")),
            );
          }

          return ChatScreen(
            chatId: args['chatId'] as String,
            userId: args['userId'] as String,
            name: args['name'] as String? ?? "User",
          );
        },
        '/groups': (context) => GroupsPage(),
        '/fitness-group': (_) => FitnessGroupPage(),
        '/fitness-page': (context) => FitnessGroupPage(),
        '/competitions-progress': (_) => CompetitionsProgressPage(),
        '/competitions-list': (_) => CompetitionsListPage(),
        '/calendar': (_) => CalendarPage(),
        '/new-goal': (_) => NewGoalPage(),
        '/survey': (_) => Surveyscreen(),
        '/survey-start': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          final surveyId = args?['surveyId'];

          return SurveyStartScreen(surveyId: surveyId);
        },
        '/nutrition': (_) => NutritionPage(),
        '/meal-logging': (_) => MealLogging(),
        '/add-meal2': (_) => AddMeal2(),
        '/search-food': (_) => SearchFood(),
        '/add-meal': (_) => AddMeal(),
        '/hydration-tracker': (_) => HydrationTracker(),
        '/fitness': (_) => NutritionPage2(),
        '/fitness-summary': (_) => FitnessSummary(),
        '/activity-fitness': (_) => ActivityFitness(),
        '/vitals-measurement': (_) => VitalsMeasurement(),
        '/body-composition': (_) => BodyCompositionScreen(),
        '/profile': (_) => ProfileScreen(),
        '/settings': (_) => SettingsScreen(),
      },
    );
  }
}
