import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verd/data/services/ai_routing_service.dart';
import 'package:verd/data/services/local_ml_service.dart';
import 'package:verd/providers/auth_provider.dart'; // To get firestore/storage providers

final localMLServiceProvider = Provider<LocalMLService>((ref) {
  return LocalMLService();
});

final aiRoutingServiceProvider = Provider<AIRoutingService>((ref) {
  return AIRoutingService(
    storageService: ref.watch(storageServiceProvider),
    firestoreService: ref.watch(firestoreServiceProvider),
    localMLService: ref.watch(localMLServiceProvider),
  );
});
