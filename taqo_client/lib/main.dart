import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:taqo_client/pages/experiment_detail_page.dart';
import 'package:taqo_client/pages/find_experiments_page.dart';
import 'package:taqo_client/pages/informed_consent_page.dart';
import 'package:taqo_client/pages/post_join_instructions_page.dart';
import 'package:taqo_client/pages/running_experiments_page.dart';
import 'package:taqo_client/pages/schedule_detail_page.dart';
import 'package:taqo_client/pages/schedule_overview_page.dart';
import 'package:taqo_client/pages/survey/feedback_page.dart';

import 'package:taqo_client/pages/survey/survey_page.dart';
import 'package:taqo_client/pages/survey_picker_page.dart';
import 'package:taqo_client/pages/welcome_page.dart';
import 'package:taqo_client/pages/invitation_entry_page.dart';
import 'package:taqo_client/pages/login_page.dart';
import 'package:taqo_client/service/notification_service.dart' as notification_manager;

import 'package:taqo_client/net/google_auth.dart';

var gAuth = GoogleAuth();

void main() {
  // Desktop platforms are not recognized as valid targets by
  // Flutter; force a specific target to prevent exceptions.
  // TODO this should change as we adopt the new Flutter Desktop Embedder
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

  // notification_manager.init() should be called once and only once
  // Calling it here ensures that it completes before the app launches
  notification_manager.init().then((_) {
    notification_manager.getLaunchDetails().then((launchDetails) {
      runApp(MyApp(launchDetails));
    });
  });
}

class MyApp extends StatelessWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();
  final NotificationAppLaunchDetails _launchDetails;

  MyApp(this._launchDetails);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taqo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      navigatorKey: navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomePage(_launchDetails),
        LoginPage.routeName: (context) => LoginPage(),
        FeedbackPage.routeName: (context) => FeedbackPage(),
        SurveyPickerPage.routeName: (context) => SurveyPickerPage(),
        FindExperimentsPage.routeName: (context) => FindExperimentsPage(),
        ExperimentDetailPage.routeName: (context) => ExperimentDetailPage(),
        InformedConsentPage.routeName: (context) => InformedConsentPage(),
        ScheduleOverviewPage.routeName: (context) => ScheduleOverviewPage(),
        ScheduleDetailPage.routeName: (context) => ScheduleDetailPage(),
        InvitationEntryPage.routeName: (context) => InvitationEntryPage(),
        WelcomePage.routeName: (context) => WelcomePage(_launchDetails),
        RunningExperimentsPage.routeName: (context) => RunningExperimentsPage(),
        PostJoinInstructionsPage.routeName: (context) => PostJoinInstructionsPage(),
      },
      // Here the route for SurveyPage is configured separately in onGenerateRoute(),
      // since we need to pass argument to this route before the page being built,
      // which is not supported by ModalRoute.of().
      onGenerateRoute: (settings) {
        if (settings.name == SurveyPage.routeName) {
          final List args = settings.arguments;
          return MaterialPageRoute(
              builder: (context) =>
                  SurveyPage(experiment: args[0],
                      experimentGroupName: args[1])
          );
        }
        return null;
      },
    );
  }
}
