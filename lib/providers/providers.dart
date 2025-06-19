import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katies_sunday_klub/models/ticket_holder_model.dart';
import 'package:katies_sunday_klub/models/transaction_model.dart' as model;

/// Provider that gives us the current authentication state.
/// The app will react to changes here (e.g., login/logout).
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// A StreamProvider that listens to the Firestore collection.
/// It now watches the authStateChangesProvider and will only fetch data
/// if a user is logged in, preventing permission errors.
final ticketsProvider = StreamProvider<List<TicketHolder>>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  // If there's no logged-in user, return an empty list and do not fetch data.
  if (authState.asData?.value == null) {
    return Stream.value([]);
  }

  final collection = FirebaseFirestore.instance.collection('numbers');
  return collection.snapshots().map((snapshot) {
    final docs = snapshot.docs;
    docs.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
    return docs.map((doc) => TicketHolder.fromFirestore(doc)).toList();
  });
});

/// A simple Provider that creates an instance of our TicketActions class
/// for easy access to all data modification methods.
final ticketActionsProvider = Provider((ref) => TicketActions());

/// A simple class that consolidates all write/update/delete operations.
class TicketActions {
  final _firestore = FirebaseFirestore.instance;
  CollectionReference get _numbers => _firestore.collection('numbers');

  /// A flexible function to update ticket details.
  Future<void> updateTicketDetails({
    required String ticketId,
    String? holders,
    double? balance,
  }) async {
    final Map<String, dynamic> dataToUpdate = {};
    // CORRECTED: Using capitalized field names ('holders', 'balance') to match the model.
    if (holders != null) {
      dataToUpdate['holders'] = holders;
    }
    if (balance != null) {
      dataToUpdate['balance'] = balance;
    }
    if (dataToUpdate.isNotEmpty) {
      await _numbers.doc(ticketId).update(dataToUpdate);
    }
  }

  /// Adds credit to a ticket holder's balance and logs the transaction.
  Future<void> addCredit(String ticketId, double amount) async {
    final ticketRef = _numbers.doc(ticketId);
    final transactionRef = ticketRef.collection('transactions').doc();

    await _firestore.runTransaction((firestoreTransaction) async {
      final ticketSnapshot = await firestoreTransaction.get(ticketRef);
      if (!ticketSnapshot.exists) throw Exception("Ticket document does not exist!");

      final data = ticketSnapshot.data() as Map<String, dynamic>;
      final currentBalance = (data['balance'] as num).toDouble();
      final newBalance = currentBalance + amount;

      final newTransaction = model.Transaction(
          id: transactionRef.id, amount: amount, isPayment: true, timestamp: Timestamp.now());

      firestoreTransaction.update(ticketRef, {'balance': newBalance});
      firestoreTransaction.set(transactionRef, newTransaction.toFirestore());
    });
  }

  /// Performs a batch write to Firestore to upload initial holder data.
  Future<void> batchUploadHolders(Map<String, String> holdersData) async {
    final batch = _firestore.batch();
    holdersData.forEach((id, holderName) {
      final docRef = _numbers.doc(id);
      batch.set(docRef, {'holders': holderName, 'balance': 0}, SetOptions(merge: true));
    });
    await batch.commit();
  }
}
