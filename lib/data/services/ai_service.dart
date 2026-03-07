import 'dart:io';
import 'package:verd/data/models/user.dart';
import 'package:verd/data/models/scan_result.dart';
import 'package:verd/data/services/ai_routing_service.dart';
import 'package:verd/data/services/firestore_service.dart';

/// AI service that integrates user profiles to provide
/// personalized crop analysis and recommendations.
class AIService {
  final FirestoreService _firestoreService;
  final AIRoutingService _aiRoutingService;

  AIService({
    required FirestoreService firestoreService,
    required AIRoutingService aiRoutingService,
  })  : _firestoreService = firestoreService,
        _aiRoutingService = aiRoutingService;

  /// Analyze crop with user context for personalized recommendations
  Future<Map<String, dynamic>> analyzeCropWithContext({
    required String userId,
    required String scanId,
    required File image,
    required AppUser userProfile,
  }) async {
    try {
      // Get user's scan history for context
      final scanHistory = await _firestoreService.getUserScans(userId, limit: 10);

      // Use AI routing service (handles online/offline routing)
      final result = await _aiRoutingService.routeScan(
        userId: userId,
        scanId: scanId,
        image: image,
      );

      // Add personalized improvements
      final improvedResult = await _improveAIResponse(
        aiResult: result,
        userId: userId,
        userProfile: userProfile,
        scanId: scanId,
        scanHistory: scanHistory,
      );

      return improvedResult;
    } catch (e) {
      // Fallback to basic AI routing service if enhanced analysis fails
      return await _aiRoutingService.routeScan(
        userId: userId,
        scanId: scanId,
        image: image,
      );
    }
  }

  /// Create contextual prompt based on user data
  String _createContextualPrompt({
    required String location,
    required List<ScanResult> scanHistory,
    required Map<String, dynamic> preferences,
  }) {
    final historyContext = scanHistory.isNotEmpty
        ? 'The user has previously scanned: ${scanHistory.map((r) => r.plantName).join(', ')}'
        : 'This appears to be the user\'s first scan';

    final preferenceContext = preferences.isNotEmpty
        ? 'User preferences: $preferences'
        : 'No specific user preferences recorded';

    return '''
    You are an agricultural AI assistant helping a farmer in $location.
    $historyContext.
    $preferenceContext.
    
    Consider the local climate, common crop diseases in this region, and the user's experience level.
    Provide practical, actionable advice that takes into account the user's farming context.
    ''';
  }

  /// Improve AI response with user-specific data and insights
  Future<Map<String, dynamic>> _improveAIResponse({
    required Map<String, dynamic> aiResult,
    required String userId,
    required AppUser userProfile,
    required String scanId,
    required List<ScanResult> scanHistory,
  }) async {
    // Add user profile context
    final improvedResult = Map<String, dynamic>.from(aiResult);
    improvedResult['userId'] = userId;
    improvedResult['userProfile'] = {
      'name': userProfile.displayName,
      'location': userProfile.farmLocation,
    };

    // ignore: unused_local_variable
    final contextPrompt = _createContextualPrompt(
      location: userProfile.farmLocation ?? 'Unknown',
      scanHistory: scanHistory,
      preferences: {},
    );

    // Add personalized recommendations based on user history
    final personalizedRecommendations = await _generatePersonalizedRecommendations(
      userId: userId,
      scanHistory: scanHistory,
      cropType: (aiResult['analysis'] as Map<String, dynamic>?)?['cropType'] as String?,
      healthStatus: (aiResult['analysis'] as Map<String, dynamic>?)?['healthStatus'] as String?,
    );

    improvedResult['personalizedRecommendations'] = personalizedRecommendations;

    // Add learning resources based on detected issues
    final diseases = (aiResult['analysis'] as Map<String, dynamic>?)?['diseases'] as List<dynamic>? ?? [];
    final learningResources = await _getLearningResources(
      cropType: (aiResult['analysis'] as Map<String, dynamic>?)?['cropType'] as String?,
      diseases: diseases,
    );

    improvedResult['learningResources'] = learningResources;

    return improvedResult;
  }

  /// Generate personalized recommendations based on user's scan history
  Future<List<String>> _generatePersonalizedRecommendations({
    required String userId,
    required List<ScanResult> scanHistory,
    required String? cropType,
    required String? healthStatus,
  }) async {
    final recommendations = <String>[];

    if (cropType != null) {
      // Get user's historical success with this crop
      final cropHistory = await _firestoreService.getCropScans(userId, cropType);

      if (cropHistory.isNotEmpty) {
        final healthyScans = cropHistory.where((r) => r.isHealthy).length;
        final successRate = healthyScans / cropHistory.length;

        if (successRate > 0.8) {
          recommendations.add('You have a great track record with $cropType! Keep following your current practices.');
        } else if (successRate < 0.5) {
          recommendations.add('Consider reviewing your $cropType care routine. Your success rate could be improved.');
        }
      }
    }

    if (healthStatus == 'warning' || healthStatus == 'critical') {
      recommendations.add('Schedule a follow-up scan in 3-5 days to monitor treatment progress.');
      recommendations.add('Document the treatment applied for future reference.');
    }

    return recommendations;
  }

  /// Get relevant learning resources based on crop and disease analysis
  Future<List<Map<String, dynamic>>> _getLearningResources({
    required String? cropType,
    required List<dynamic> diseases,
  }) async {
    final resources = <Map<String, dynamic>>[];

    if (cropType != null) {
      resources.add({
        'type': 'guide',
        'title': '$cropType Care Guide',
        'description': 'Best practices for growing healthy $cropType',
        'priority': 'high',
      });
    }

    for (final disease in diseases) {
      final diseaseName = disease['name'] as String?;
      if (diseaseName != null) {
        resources.add({
          'type': 'treatment',
          'title': 'Treating $diseaseName',
          'description': 'Step-by-step treatment guide for $diseaseName',
          'priority': disease['severity'] == 'high' ? 'urgent' : 'medium',
        });
      }
    }

    return resources;
  }

  /// Save scan result with user context
  Future<void> saveScanResult({
    required String userId,
    required String scanId,
    required ScanResult result,
  }) async {
    await _firestoreService.saveScanResult(userId, result);

    // Update user's crop statistics
    await _updateUserCropStats(userId, result);
  }

  /// Update user's crop statistics based on new scan
  Future<void> _updateUserCropStats(String userId, ScanResult result) async {
    final cropType = result.plantName;
    final healthStatus = result.isHealthy ? 'healthy' : 'unhealthy';

    if (cropType.isNotEmpty) {
      await _firestoreService.updateCropStats(
        userId: userId,
        cropType: cropType,
        healthStatus: healthStatus,
      );
    }
  }

  /// Get AI-powered insights about user's farming patterns
  Future<Map<String, dynamic>> getUserFarmingInsights(String userId) async {
    try {
      final scanHistory = await _firestoreService.getUserScans(userId);
      final userProfile = await _firestoreService.getUserProfile(userId);

      final cropTypes = scanHistory.map((r) => r.plantName).toSet().toList();
      final healthyCount = scanHistory.where((r) => r.isHealthy).length;
      final totalScans = scanHistory.length;

      final insights = totalScans > 0
          ? 'You have scanned $totalScans crops with a ${(healthyCount / totalScans * 100).toStringAsFixed(0)}% health rate. '
            'Crops grown: ${cropTypes.join(', ')}. '
            'Continue scanning regularly for better tracking.'
          : 'Start scanning crops to get personalized AI-driven insights.';

      return {
        'insights': insights,
        'scanCount': totalScans,
        'cropTypes': cropTypes,
        'healthRate': totalScans > 0 ? (healthyCount / totalScans * 100).toStringAsFixed(0) : '0',
        'userName': userProfile?.displayName ?? 'Farmer',
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': 'Failed to generate insights: $e',
        'scanCount': 0,
        'cropTypes': <String>[],
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }
}
