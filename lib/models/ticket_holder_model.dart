import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single ticket holder in the 'numbers' collection.
class TicketHolder {
  /// The document ID from Firestore, which corresponds to the ticket number (e.g., "1", "2", ... "50").
  final String id;

  /// The name(s) of the person or people holding the ticket.
  final String holders;

  /// The current financial balance for this ticket number.
  final double balance;

  TicketHolder({
    required this.id,
    required this.holders,
    required this.balance,
  });

  /// Creates a [TicketHolder] instance from a Firestore document snapshot.
  factory TicketHolder.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TicketHolder(
      id: doc.id,
      holders: data['holders'] ?? '',
      // Ensure balance is treated as a double, defaulting to 0.0 if null or wrong type.
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Converts a [TicketHolder] instance into a map for Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'holders': holders,
      'balance': balance,
    };
  }

  /// Creates a copy of this [TicketHolder] but with the given fields replaced with new values.
  TicketHolder copyWith({
    String? id,
    String? holders,
    double? balance,
  }) {
    return TicketHolder(
      id: id ?? this.id,
      holders: holders ?? this.holders,
      balance: balance ?? this.balance,
    );
  }
}

