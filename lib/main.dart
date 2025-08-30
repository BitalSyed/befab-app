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
import 'package:befab/Screens/Reel.dart';
import 'package:befab/Screens/SearchFood.dart';
import 'package:befab/Screens/SignInScreen.dart';
import 'package:befab/Screens/SignUpScreen.dart';
import 'package:befab/Screens/SingleNewsLetterScreen.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Ensure status bar is visible and styled
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Make it transparent or set a color
      statusBarIconBrightness:
          Brightness.dark, // Use `Brightness.light` for light icons
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BeFAB HBCU',
      theme: ThemeData(
        scaffoldBackgroundColor:
            Colors.white, // Sets background for all screens
        primaryColor: const Color(0xFF862633),
        fontFamily: 'Helvetica',
      ),
      // Use routes directly
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/signup': (context) => SignUpScreen(),
        '/signin': (context) => SignInScreen(),
        '/forgot-password-1': (context) => ForgotPassword1(),
        '/forgot-password-2': (context) => ForgotPassword2(),
        '/forgot-password-3': (context) => ForgotPassword3(),
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
        '/message': (context) => MessagesPage(),
        // main.dart (or wherever your routes are defined)
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
      },
    );
  }
}
