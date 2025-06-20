import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katies_sunday_klub/models/ticket_holder_model.dart';
import 'package:katies_sunday_klub/providers/package_info_provider.dart';
import 'package:katies_sunday_klub/providers/providers.dart';
import 'package:katies_sunday_klub/screens/add_credit_screen.dart';
import 'package:katies_sunday_klub/screens/edit_holder_screen.dart';
import 'package:katies_sunday_klub/screens/transactions_screen.dart';

import '../providers/auth_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsyncValue = ref.watch(ticketsProvider);
    final authState = ref.watch(authStateChangesProvider);
    final packageInfoAsyncValue = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Katie's Sunday Klub"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authState.when(
                      data: (user) => user?.email ?? 'No user logged in',
                      loading: () => 'Loading...',
                      error: (err, stack) => 'Error',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  packageInfoAsyncValue.when(
                    data: (packageInfo) => Text(
                      'Version: ${packageInfo.version}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    loading: () => const Text(
                      'Loading version...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    error: (err, stack) => const Text(
                      'Error loading version',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Transactions'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TransactionsScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => ref.read(authProvider.notifier).signOut(),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'No.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Expanded(
                  flex: 7,
                  child: Text(
                    'Holder',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: const Text(
                      'Balance',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: ticketsAsyncValue.when(
              data: (tickets) => _buildTicketList(tickets),
              error: (err, stack) =>
                  Center(child: Text('An error occurred: $err')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketList(List<TicketHolder> tickets) {
    if (tickets.isEmpty) {
      return const Center(child: Text('No ticket data found.'));
    }
    return ListView.separated(
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        final balanceColor =
        ticket.balance < 10 ? Colors.red.shade700 : Colors.green.shade800;
        return ListTile(
          leading: CircleAvatar(child: Text(ticket.id)),
          title: Text(
            ticket.holders.isEmpty ? 'Tap to assign' : ticket.holders,
          ),
          trailing: Text(
            '€${ticket.balance.toStringAsFixed(0)}',
            style: TextStyle(
              color: balanceColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddCreditScreen(ticketHolder: ticket),
              ),
            );
          },
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditHolderScreen(ticketHolder: ticket),
              ),
            );
          },
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 1),
    );
  }
}