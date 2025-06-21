// lib/screens/transactions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:katies_sunday_klub/providers/providers.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsyncValue = ref.watch(allTransactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('All Transactions')),
      body: Column(
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 2, // Adjusted flex for "Date"
                  child: Text(
                    'Date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Expanded(
                  flex: 2, // New column for "Time"
                  child: Text(
                    'Time',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Number',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: const Text(
                      'Amount',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          // Transaction List
          Expanded(
            child: transactionsAsyncValue.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Center(child: Text('No transactions found.'));
                }
                return ListView.separated(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transWithId = transactions[index];
                    final transaction = transWithId.transaction;
                    final formattedDate = DateFormat(
                      'dd MMM',
                    ).format(transaction.timestamp.toDate()); // Changed date format
                    final formattedTime = DateFormat(
                      'HH:mm',
                    ).format(transaction.timestamp.toDate()); // New time format
                    final amountColor =
                    transaction.isPayment
                        ? Colors.green.shade800
                        : Colors.red.shade700;
                    final amountPrefix = transaction.isPayment ? '+' : '-';

                    return ListTile(
                      title: Row(
                        children: [
                          Expanded(flex: 2, child: Text(formattedDate)), // Adjusted flex
                          Expanded(
                            flex: 2,
                            child: Text(
                              formattedTime, // Display time
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              transWithId.ticketId,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '$amountPrefix€${transaction.amount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: amountColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder:
                      (context, index) => const Divider(height: 1),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, stack) =>
                  Center(child: Text('An error occurred: $err')),
            ),
          ),
        ],
      ),
    );
  }
}