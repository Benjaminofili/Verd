import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'scan_result.g.dart';

/// Hive typeId: 1
@HiveType(typeId: 1)
class ScanResult extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String? imageUrl; // Remote Firebase Storage URL (null if not yet synced)

  @HiveField(3)
  final String? localImagePath; // Local file path of the original image

  @HiveField(4)
  final String plantName;

  @HiveField(5)
  final String diagnosis; // e.g. "Healthy", "Bacterial Leaf Blight"

  @HiveField(6)
  final double confidence; // 0.0 – 1.0

  @HiveField(7)
  final List<String> recommendations; // Action items for the farmer

  @HiveField(8)
  final DateTime scannedAt;

  @HiveField(9)
  final bool synced; // Whether this result has been uploaded to Firestore

  @HiveField(10)
  final Map<String, dynamic>? analysisMap; // Full AI analysis results for persistent display

  ScanResult({
    required this.id,
    required this.userId,
    this.imageUrl,
    this.localImagePath,
    required this.plantName,
    required this.diagnosis,
    required this.confidence,
    required this.recommendations,
    required this.scannedAt,
    this.synced = false,
    this.analysisMap,
  });

  /// Whether this scan indicates a healthy plant.
  bool get isHealthy => diagnosis.toLowerCase() == 'healthy';

  // ── Firestore Serialization ──

  factory ScanResult.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    // Attempt to parse AI analysis if it exists but isn't already a Map
    Map<String, dynamic>? analysis;
    if (data['analysisMap'] != null) {
      analysis = Map<String, dynamic>.from(data['analysisMap']);
    } else if (data['output'] != null) {
      // It's a raw Gemini Extension result
      final dynamic output = data['output'];
      if (output is String) {
        try {
          String rawJson = output.replaceAll('```json', '').replaceAll('```', '').trim();
          analysis = jsonDecode(rawJson) as Map<String, dynamic>;
        } catch (_) {
          // Silent fail - we'll show "Unknown" in UI
        }
      } else if (output is Map) {
        analysis = Map<String, dynamic>.from(output);
      }
    }

    return ScanResult(
      id: doc.id,
      userId: data['userId'] ?? '',
      imageUrl: data['imageUrl'],
      localImagePath: data['localImagePath'],
      plantName: analysis?['cropType'] ?? data['plantName'] ?? '',
      diagnosis: analysis?['healthStatus'] ?? data['diagnosis'] ?? '',
      confidence: (analysis?['confidence'] ?? data['confidence'] ?? 0.0).toDouble(),
      recommendations: List<String>.from(analysis?['diseases']?.map((d) => d['treatment']?.toString()) ?? data['recommendations'] ?? []),
      scannedAt: (data['scannedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      synced: true,
      analysisMap: analysis,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'plantName': plantName,
      'diagnosis': diagnosis,
      'confidence': confidence,
      'recommendations': recommendations,
      'scannedAt': Timestamp.fromDate(scannedAt),
      'analysisMap': analysisMap,
    };
  }

  // ── JSON ──

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      imageUrl: json['imageUrl'],
      localImagePath: json['localImagePath'],
      plantName: json['plantName'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      scannedAt: json['scannedAt'] != null
          ? DateTime.parse(json['scannedAt'])
          : DateTime.now(),
      synced: json['synced'] ?? false,
      analysisMap: json['analysisMap'] != null ? Map<String, dynamic>.from(json['analysisMap']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'localImagePath': localImagePath,
      'plantName': plantName,
      'diagnosis': diagnosis,
      'confidence': confidence,
      'recommendations': recommendations,
      'scannedAt': scannedAt.toIso8601String(),
      'synced': synced,
      'analysisMap': analysisMap,
    };
  }

  // ── CopyWith ──

  ScanResult copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    String? localImagePath,
    String? plantName,
    String? diagnosis,
    double? confidence,
    List<String>? recommendations,
    DateTime? scannedAt,
    bool? synced,
    Map<String, dynamic>? analysisMap,
  }) {
    return ScanResult(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      plantName: plantName ?? this.plantName,
      diagnosis: diagnosis ?? this.diagnosis,
      confidence: confidence ?? this.confidence,
      recommendations: recommendations ?? this.recommendations,
      scannedAt: scannedAt ?? this.scannedAt,
      synced: synced ?? this.synced,
      analysisMap: analysisMap ?? this.analysisMap,
    );
  }

  @override
  String toString() =>
      'ScanResult(id: $id, plantName: $plantName, diagnosis: $diagnosis, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
}
