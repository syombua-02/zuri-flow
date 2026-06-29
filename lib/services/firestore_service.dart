 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ================= USER PROFILE =================

  Future<void> saveUserData({
    required String goal,
    required String weight,
    required String height,
    required String activity,
    String name = '',

    // Extra personalization fields
    String movementPreference = 'Pilates + Yoga',
    String workoutIntensity = 'Moderate',
    String focusArea = 'Full Body',
    String equipment = 'None',
    String workoutDuration = '20-30 min',
    String workoutDays = '4 days/week',
    String limitations = 'None',
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No logged in user found');
    }

    await _db.collection('users').doc(user.uid).set({
      'email': user.email,
      if (name.trim().isNotEmpty) 'name': name.trim(),
      'goal': goal.trim(),
      'weight': weight.trim(),
      'height': height.trim(),
      'activity': activity.trim(),

      // New personalized fields
      'movementPreference': movementPreference.trim(),
      'workoutIntensity': workoutIntensity.trim(),
      'focusArea': focusArea.trim(),
      'equipment': equipment.trim(),
      'workoutDuration': workoutDuration.trim(),
      'workoutDays': workoutDays.trim(),
      'limitations': limitations.trim(),

      'profileCompleted': true,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.data();
  }

  Future<bool> userProfileExists() async {
    final user = _auth.currentUser;

    if (user == null) return false;

    final doc = await _db.collection('users').doc(user.uid).get();

    if (!doc.exists) return false;

    final data = doc.data();
    return data != null && data['profileCompleted'] == true;
  }

  // ================= PROGRESS TRACKER =================

  Future<void> saveProgressEntry({
    required String weight,
    required String waist,
    required String hips,
    required String bust,
    required String thigh,
    required String arm,
    required String notes,
    DateTime? date,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No logged in user found');
    }

    final entryData = {
      'weight': weight.trim(),
      'waist': waist.trim(),
      'hips': hips.trim(),
      'bust': bust.trim(),
      'thigh': thigh.trim(),
      'arm': arm.trim(),
      'notes': notes.trim(),
      'createdAt': date != null ? Timestamp.fromDate(date) : Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('progress_entries')
        .add(entryData);

    await _db.collection('users').doc(user.uid).set({
      'latestProgress': entryData,
      'lastProgressUpdated': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getProgressEntries() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No logged in user found');
    }

    final snapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('progress_entries')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<Map<String, dynamic>?> getLatestProgress() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();

    if (!doc.exists) return null;

    final data = doc.data();
    if (data == null || data['latestProgress'] == null) return null;

    return Map<String, dynamic>.from(data['latestProgress']);
  }

  Future<void> updateProgressEntry({
    required String entryId,
    required String weight,
    required String waist,
    required String hips,
    required String bust,
    required String thigh,
    required String arm,
    required String notes,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No logged in user found');
    }

    final userRef = _db.collection('users').doc(user.uid);
    final progressRef = userRef.collection('progress_entries').doc(entryId);

    final existingDoc = await progressRef.get();
    if (!existingDoc.exists) {
      throw Exception('Progress entry not found');
    }

    final existingData = existingDoc.data() ?? {};
    final createdAt = existingData['createdAt'] ?? Timestamp.now();

    final updatedEntry = {
      'weight': weight.trim(),
      'waist': waist.trim(),
      'hips': hips.trim(),
      'bust': bust.trim(),
      'thigh': thigh.trim(),
      'arm': arm.trim(),
      'notes': notes.trim(),
      'createdAt': createdAt,
      'updatedAt': Timestamp.now(),
    };

    await progressRef.set(updatedEntry, SetOptions(merge: true));
    await _refreshLatestProgress(user.uid);
  }

  Future<void> deleteProgressEntry(String entryId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No logged in user found');
    }

    final userRef = _db.collection('users').doc(user.uid);
    final progressRef = userRef.collection('progress_entries');

    await progressRef.doc(entryId).delete();
    await _refreshLatestProgress(user.uid);
  }

  Future<void> _refreshLatestProgress(String uid) async {
    final userRef = _db.collection('users').doc(uid);
    final progressRef = userRef.collection('progress_entries');

    final snapshot = await progressRef
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      await userRef.set({
        'latestProgress': FieldValue.delete(),
        'lastProgressUpdated': Timestamp.now(),
      }, SetOptions(merge: true));
    } else {
      final latestEntry = snapshot.docs.first.data();

      await userRef.set({
        'latestProgress': latestEntry,
        'lastProgressUpdated': Timestamp.now(),
      }, SetOptions(merge: true));
    }
  }
}