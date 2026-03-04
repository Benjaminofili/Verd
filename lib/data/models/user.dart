import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

/// Hive typeId: 0
@HiveType(typeId: 0)
class AppUser extends HiveObject {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String displayName;

  @HiveField(3)
  final String? photoUrl;

  @HiveField(4)
  final String? farmLocation;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final String? phoneNumber;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.farmLocation,
    required this.createdAt,
    this.phoneNumber,
  });

  // ── Firestore Serialization ──

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      farmLocation: data['farmLocation'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      phoneNumber: data['phoneNumber'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'farmLocation': farmLocation,
      'createdAt': Timestamp.fromDate(createdAt),
      'phoneNumber': phoneNumber,
    };
  }

  // ── JSON (for general serialization) ──

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoUrl: json['photoUrl'],
      farmLocation: json['farmLocation'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'farmLocation': farmLocation,
      'createdAt': createdAt.toIso8601String(),
      'phoneNumber': phoneNumber,
    };
  }

  // ── CopyWith ──

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? farmLocation,
    DateTime? createdAt,
    String? phoneNumber,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      farmLocation: farmLocation ?? this.farmLocation,
      createdAt: createdAt ?? this.createdAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  String toString() =>
      'AppUser(uid: $uid, email: $email, displayName: $displayName)';
}
