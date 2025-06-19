import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katies_sunday_klub/models/ticket_holder_model.dart';
import 'package:katies_sunday_klub/models/transaction_model.dart' as model;

/// Provider for the FirebaseFirestore instance.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for the TicketRepository.
final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return TicketRepository(firestore);
});

/// StreamProvider that provides a real-time stream of all ticket holders.
final ticketsProvider = StreamProvider<List<TicketHolder>>((ref) {
  final repository = ref.watch(ticketRepositoryProvider);
  return repository.getTicketHolders();
});


/// Repository for handling all ticket and transaction related
/// operations with Firestore.
class TicketRepository {
  final FirebaseFirestore _firestore;

  TicketRepository(this._firestore);

  /// Collection reference for the 'numbers' collection.
  CollectionReference get _numbers => _firestore.collection('numbers');

  /// Fetches a real-time stream of all ticket holders.
  Stream<List<TicketHolder>> getTicketHolders() {
    return _numbers.snapshots().map((snapshot) {
      final docs = snapshot.docs;
      docs.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
      return docs.map((doc) => TicketHolder.fromFirestore(doc)).toList();
    });
  }

  /// NEW: A more flexible function to update ticket details.
  /// It can update the holders name, the balance, or both at the same time.
  Future<void> updateTicketDetails({
    required String ticketId,
    String? holders,
    double? balance,
  }) async {
    final Map<String, dynamic> dataToUpdate = {};

    // Only add fields to the update map if they are provided.
    if (holders != null) {
      dataToUpdate['holders'] = holders;
    }
    if (balance != null) {
      dataToUpdate['balance'] = balance;
    }

    // Only run the update if there is actually data to change.
    if (dataToUpdate.isNotEmpty) {
      try {
        await _numbers.doc(ticketId).update(dataToUpdate);
      } catch (e) {
        print('Error updating ticket details: $e');
        rethrow;
      }
    }
  }

  /// Adds credit to a ticket holder's balance and logs the transaction.
  Future<void> addCredit(String ticketId, double amount) async {
    final ticketRef = _numbers.doc(ticketId);
    final transactionRef = ticketRef.collection('transactions').doc();

    try {
      await _firestore.runTransaction((firestoreTransaction) async {
        final ticketSnapshot = await firestoreTransaction.get(ticketRef);
        if (!ticketSnapshot.exists) {
          throw Exception("Ticket document does not exist!");
        }

        final data = ticketSnapshot.data() as Map<String, dynamic>;
        final currentBalance = (data['balance'] as num).toDouble();
        final newBalance = currentBalance + amount;
        final newTransaction = model.Transaction(
          id: transactionRef.id,
          amount: amount,
          isPayment: true,
          timestamp: Timestamp.now(),
        );

        firestoreTransaction.update(ticketRef, {'balance': newBalance});
        firestoreTransaction.set(transactionRef, newTransaction.toFirestore());
      });
    } catch (e) {
      print('Error adding credit: $e');
      rethrow;
    }
  }

  /// Performs a batch write to Firestore to upload initial holder data.
  Future<void> batchUploadHolders(Map<String, String> holdersData) async {
    final batch = _firestore.batch();
    holdersData.forEach((id, holderName) {
      final docRef = _numbers.doc(id);
      batch.set(docRef, {
        'holders': holderName,
        'balance': 0,
      }, SetOptions(merge: true));
    });
    await batch.commit();
  }
}
