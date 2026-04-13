import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
  });

  /// Convert Firebase User → UserModel
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
    );
  }

  /// Convert Model → JSON (for Firestore if needed later)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
    };
  }

  /// Convert JSON → Model
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
    );
  }
}