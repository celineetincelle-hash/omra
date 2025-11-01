import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'core/theme/app_theme.dart';
import 'core/storage/local_db.dart';
import 'core/services/connectivity_service.dart';
import 'core/bloc/connectivity_bloc.dart'; // Ajout de l'import du BLoC
import 'core/bloc/connectivity_state.dart'; // Ajout de l'import de l'état
import 'core/bloc/connectivity_event.dart'; // Ajout de l'import de l'événement
import 'core/services/battery_service.dart';
import 'core/services/location_service.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/rituals_screen.dart';
import 'screens/duas_screen.dart';
import 'screens/assistant_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/group_tracking_screen.dart';
import 'screens/group_bluetooth_screen.dart';
import 'screens/useful_links_screen.dart';
import 'screens/share_location_screen.dart';
import 'screens/health_dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/group_management_screen.dart';
import 'screens/qr_scan_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
    FlutterLocalNotificationsPlugin();

final getIt = GetIt.instance;

void setupLocator() {
  // Enregistrer les services
  getIt.registerSingleton<ConnectivityService>(ConnectivityService()); // Enregistrement du service
  getIt.registerSingleton<ConnectivityBloc>(ConnectivityBloc(getIt<ConnectivityService>())); // Initialisation avec le service
  getIt.registerSingleton<BatteryBloc>(BatteryBloc());
  getIt.registerSingleton<LocationBloc>(LocationBloc());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuration globale des erreurs
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Global error: ${details.exception}');
  };
  
  await EasyLocalization.ensureInitialized();
  tz.initializeTimeZones();
  await LocalDB.init();
  
  // Initialiser les notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  
  // Configurer les services
  setupLocator();
  
  // Vérification de la connectivité
  // La vérification de la connectivité est maintenant gérée par le BLoC
  // final connectivityResult = await Connectivity().checkConnectivity();
  // if (connectivityResult == ConnectivityResult.none) {
  //   print('No internet connection');
  // }
  
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('ar'), 
        Locale('fr'), 
        Locale('en'),
        Locale('ur'),  // Ourdou
        Locale('id'),  // Indonésien
      ],
      path: 'lib/l10n',
      fallbackLocale: const Locale('ar'),
      child: const OmraTruckApp(),
    ),
  );
}

class OmraTruckApp extends StatelessWidget {
  const OmraTruckApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
        GoRoute(path: '/map', builder: (c, s) => const MapScreen()),
        GoRoute(path: '/rituals', builder: (c, s) => const RitualsScreen()),
        GoRoute(path: '/duas', builder: (c, s) => const DuasScreen()),
        GoRoute(path: '/assistant', builder: (c, s) => const AssistantScreen()),
        GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
        GoRoute(path: '/group', builder: (c, s) => const GroupManagementScreen()),
        GoRoute(path: '/group_tracking', builder: (c, s) => const GroupTrackingScreen()),
        GoRoute(path: '/group_bluetooth', builder: (c, s) => const GroupBluetoothScreen()),
        GoRoute(path: '/scan_qr', builder: (c, s) => const QRScanScreen()),
        GoRoute(path: '/links', builder: (c, s) => const UsefulLinksScreen()),
        GoRoute(path: '/share', builder: (c, s) => const ShareLocationScreen()),
        GoRoute(path: '/health', builder: (c, s) => const HealthDashboardScreen()),
        GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page not found: ${state.uri}'),
        ),
      ),
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<ConnectivityBloc>(
          create: (context) => getIt<ConnectivityBloc>(),
        ),
        BlocProvider<BatteryBloc>(
          create: (context) => getIt<BatteryBloc>(),
        ),
        BlocProvider<LocationBloc>(
          create: (context) => getIt<LocationBloc>(),
        ),
      ],
      child: BlocBuilder<ConnectivityBloc, ConnectivityState>(
        builder: (context, connectivityState) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: tr('app_name'),
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: router,
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            builder: (context, child) {
              // Afficher une bannière si pas de connexion
              if (!connectivityState.isConnected) {
                return Banner(
                  message: tr('no_internet'),
                  location: BannerLocation.topStart,
                  color: Colors.red,
                  child: child!,
                );
              }
              return child!;
            },
          );
        },
      ),
    );
  }
}
