import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/prediction_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

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

  Future<void> savePrediction(PredictionModel prediction) async {
    await _firestore
        .collection('predictions')
        .doc(prediction.predictionId)
        .set(prediction.toMap());
  }

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
