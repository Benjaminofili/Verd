import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides a real-time stream of the device's connectivity status.
final connectivityProvider =
    StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Convenience provider that returns true if the device is online.
final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.maybeWhen(
    data: (results) => results.any((r) => r != ConnectivityResult.none),
    orElse: () => true, // Assume online by default
  );
});
