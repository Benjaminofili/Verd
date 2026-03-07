import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'data/services/local_storage.dart';
import 'data/services/app_check_service.dart';
import 'providers/auth_provider.dart';
import 'app.dart';
import 'data/services/fcm_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Backend
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase App Check for security
  await AppCheckService.initialize();

  // Register background handler early
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Hive Offline Storage
  await Hive.initFlutter();

  // Open Hive boxes (register adapters + open typed boxes)
  final localStorage = LocalStorageService();
  await localStorage.init();



  runApp(
    ProviderScope(
      overrides: [
        // Make the initialized LocalStorageService available throughout the app
        localStorageServiceProvider.overrideWith((ref) => localStorage),
      ],
      child: const MyApp(),
    ),
  );
}