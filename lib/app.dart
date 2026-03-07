import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:verd/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/router/app_router.dart';
import 'providers/notification_provider.dart';
import 'shared/widgets/app_toast.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'VERD',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('es'),
      ],
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => _FCMHandler(child: child!),
    );
  }
}

class _FCMHandler extends ConsumerStatefulWidget {
  final Widget child;
  const _FCMHandler({required this.child});

  @override
  ConsumerState<_FCMHandler> createState() => _FCMHandlerState();
}

class _FCMHandlerState extends ConsumerState<_FCMHandler> {
  @override
  void initState() {
    super.initState();
    _setupFCM();
  }

  void _setupFCM() {
    final fcm = ref.read(fcmServiceProvider);

    // ── Foreground messages: show as in-app toast ──
    fcm.onForegroundMessage((message) {
      final title = message.notification?.title ?? 'Notification';
      final body = message.notification?.body ?? '';
      if (mounted) {
        AppToast.show(
          context,
          message: '$title\n$body',
          variant: ToastVariant.info,
        );
      }
    });

    // ── Background/tray tap: navigate to the route in data payload ──
    fcm.onMessageOpenedApp(_navigateFromMessage);

    // ── Terminated state: app was fully closed when notification was tapped ──
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        // Small delay so the app's router finishes its initial setup
        Future.delayed(const Duration(milliseconds: 500), () {
          _navigateFromMessage(message);
        });
      }
    });
  }

  /// Reads the `route` key from the notification's data payload.
  /// Falls back to `/home` if not provided.
  void _navigateFromMessage(RemoteMessage message) {
    final route = message.data['route'] as String? ?? '/home';
    navigatorKey.currentContext?.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}