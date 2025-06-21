// lib/models/transaction_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
/// Represents a single transaction in the 'transactions' sub-collection.
class Transaction {
  /// The document ID from Firestore (e.g., "xds").
  final String id;

  /// The value of the transaction.
  final double amount;

  /// Indicates if the transaction was a credit (true) or a debit (false).
  final bool isPayment;

  /// The date and time the transaction occurred.
  final Timestamp timestamp;

  Transaction({
    required this.id,
    required this.amount,
    required this.isPayment,
    required this.timestamp,
  });

  /// Creates a [Transaction] instance from a Firestore document snapshot.
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      isPayment: data['payment'] ?? false,
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  /// Converts a [Transaction] instance into a map for Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'payment': isPayment,
      'timestamp': timestamp,
    };
  }
}