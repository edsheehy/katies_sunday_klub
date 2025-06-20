import 'package:katies_sunday_klub/models/transaction_model.dart';

class TransactionWithTicketId {
  final String ticketId;
  final Transaction transaction;

  TransactionWithTicketId({
    required this.ticketId,
    required this.transaction,
  });
}