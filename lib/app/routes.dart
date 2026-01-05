import 'package:flutter/material.dart';
import '../features/start/screens/start_screen.dart';
import '../features/start/screens/gas_law_selection_screen.dart';
import '../features/boyles_law/screens/boyles_law_activities_screen.dart';
import '../features/boyles_law/activities/syringe_test/syringe_test_activity.dart';
import '../features/boyles_law/activities/scuba_diving/scuba_diving_activity.dart';
import '../features/boyles_law/quiz/drag_drop_quiz_screen.dart';
import '../features/charles_law/screens/charles_law_activities_screen.dart';
import '../features/combined_gas_law/screens/combined_gas_law_activities_screen.dart';
import '../features/settings/screens/settings_screen.dart';

/// Application route names
class AppRoutes {
  static const String start = '/';
  static const String gasLawSelection = '/gas-law-selection';
  static const String boylesLawActivities = '/boyles-law-activities';
  static const String syringeTest = '/syringe-test';
  static const String scubaDiving = '/scuba-diving';
  static const String boylesLawQuiz = '/boyles-law-quiz';
  static const String charlesLawActivities = '/charles-law-activities';
  static const String combinedGasLawActivities = '/combined-gas-law-activities';
  static const String settings = '/settings';
}

/// Route generator for the application
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.start:
        return MaterialPageRoute(builder: (_) => const StartScreen());
      case AppRoutes.gasLawSelection:
        return MaterialPageRoute(builder: (_) => const GasLawSelectionScreen());
      case AppRoutes.boylesLawActivities:
        return MaterialPageRoute(builder: (_) => const BoylesLawActivitiesScreen());
      case AppRoutes.syringeTest:
        return MaterialPageRoute(builder: (_) => const SyringeTestActivity());
      case AppRoutes.scubaDiving:
        return MaterialPageRoute(builder: (_) => const ScubaDivingActivity());
      case AppRoutes.boylesLawQuiz:
        return MaterialPageRoute(builder: (_) => const DragDropQuizScreen());
      case AppRoutes.charlesLawActivities:
        return MaterialPageRoute(builder: (_) => const CharlesLawActivitiesScreen());
      case AppRoutes.combinedGasLawActivities:
        return MaterialPageRoute(builder: (_) => const CombinedGasLawActivitiesScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

