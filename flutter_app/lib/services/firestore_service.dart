// Centralized Cloud Firestore persistence and real-time queries.

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/prediction_model.dart';
import '../models/user_model.dart';

/// Provides typed access to the `users` and `predictions` collections.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Writes a user profile using the Firebase UID as its document ID.
  Future<void> saveUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  /// Retrieves one user profile by Firebase UID.
  Future<UserModel?> getUserById(String uid) async {
    final DocumentSnapshot document = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    if (!document.exists) {
      return null;
    }

    return UserModel.fromMap(document.data() as Map<String, dynamic>);
  }

  /// Stores an immutable prediction record under its generated UUID.
  Future<void> savePrediction(PredictionModel prediction) async {
    await _firestore
        .collection('predictions')
        .doc(prediction.predictionId)
        .set(prediction.toMap());
  }

  /// Streams one patient's predictions with newest results first.
  Stream<List<PredictionModel>> getPredictionsByUser(String userId) {
    return _firestore
        .collection('predictions')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final predictions = snapshot.docs.map((doc) {
            return PredictionModel.fromMap(doc.data());
          }).toList();

          predictions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return predictions;
        });
  }

  /// Streams profiles whose shared user document has the Patient role.
  Stream<List<UserModel>> getPatients() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'Patient')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return UserModel.fromMap(doc.data());
          }).toList();
        });
  }

  /// Streams all prediction records for authorized Practitioner screens.
  Stream<List<PredictionModel>> getAllPredictions() {
    return _firestore
        .collection('predictions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return PredictionModel.fromMap(doc.data());
          }).toList();
        });
  }
}
