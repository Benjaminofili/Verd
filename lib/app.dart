import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:df_localization/df_localization.dart';
import 'core/constants/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'providers/notification_provider.dart';
import 'shared/widgets/app_toast.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(appRouterProvider);

    return ValueListenableBuilder<Locale>(
      valueListenable: TranslationController.i.pLocale,
      builder: (context, locale, child) {
        return MaterialApp.router(
          title: 'VERD',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          locale: locale,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          builder: (context, child) => _FCMHandler(child: child!),
        );
      },
    );
  }
}

class _FCMHandler extends ConsumerWidget {
  final Widget child;
  const _FCMHandler({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Setup foreground notification handling inside the navigator's context
    ref.listen(fcmServiceProvider, (previous, next) {
      if (previous == null) {
        next.onForegroundMessage((message) {
          final title = message.notification?.title ?? 'Notification';
          final body = message.notification?.body ?? '';

          AppToast.show(
            context,
            message: '$title\n$body',
            variant: ToastVariant.info,
          );
        });
      }
    });
    return child;
  }
}