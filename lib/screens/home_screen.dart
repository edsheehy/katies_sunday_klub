import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katies_sunday_klub/models/ticket_holder_model.dart';
import 'package:katies_sunday_klub/providers/providers.dart';
import 'package:katies_sunday_klub/screens/add_credit_screen.dart';
import 'package:katies_sunday_klub/screens/edit_holder_screen.dart';

import '../providers/auth_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the ticketsProvider to get the stream of ticket holders.
    final ticketsAsyncValue = ref.watch(ticketsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Katie's Sunday Klub"),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.upload_file),
          //   tooltip: 'Upload Initial Data',
          //   onPressed: () => _confirmAndUploadData(context, ref),
          // ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
      // Using a Column to separate the static header from the scrollable list.
      body: Column(
        children: [
          // 1. This is the static header row that will not scroll.
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
          // 2. The list of tickets will now expand and scroll independently.
          Expanded(
            child: ticketsAsyncValue.when(
              data: (tickets) => _buildTicketList(tickets),
              error:
                  (err, stack) =>
                      Center(child: Text('An error occurred: $err')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the scrollable list of tickets.
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
            '€${ticket.balance.toStringAsFixed(2)}',
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

  /// Shows a confirmation dialog before uploading data.
  void _confirmAndUploadData(BuildContext context, WidgetRef ref) async {
    final shouldUpload = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Data Upload'),
            content: const Text(
              'This will upload the initial list of ticket holders. This should only be done once. Proceed?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('UPLOAD'),
              ),
            ],
          ),
    );

    if (shouldUpload == true && context.mounted) {
      _uploadInitialData(context, ref);
    }
  }

  /// The upload function now uses the new provider.
  void _uploadInitialData(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final Map<String, String> holdersData = {
      "3": "Rachel Fahy & Cong",
      "4": "Jimmy O'Donohue & Pat Dela",
      "5": "Haulie Kenny",
      "6": "Mackey & Jockser",
      "7": "Seven & Brid",
      "8": "Smiley & Yvonne",
      "9": "John Greaney & Hugh",
      "10": "Jockser & Mackey",
      "11": "Pa Moran & Mike Shanahan",
      "12": "Carmel Fitzsimons",
      "13": "Mick & Frankie Walsh",
      "14": "Joe & Mick Walsh",
      "15": "Mal Keaveney",
      "16": "Ailbhe & Ronnie Kelly",
      "17": "Colin & Catriona",
      "18": "Pa Moran & Mikey Barr",
      "19": "Jamie Moran",
      "20": "Ed Sheehy & Denis Keating",
      "21": "Mikey Barr",
      "22": "Paul & Marie",
      "23": "Luigi Lenihan",
      "24": "Johnny McMahon",
      "25": "Tommy Hartigan",
      "26": "Mick Flannery & Deron",
      "27": "Jackie & Pat Delahunty",
      "28": "Mike & Gabrielle Horan",
      "29": "Christy Walsh",
      "30": "Alan & Ita Kehoe",
      "31": "Ger Ranahan & Johnny McMahon",
      "32": "Eddie & Noreen Ryan",
      "33": "Pakie Moran",
      "34": "Tara & Colm",
      "35": "Francy O'Connell",
      "36": "Ondine & Haulie",
      "37": "Ronnie & Ailbhe Kelly",
      "38": "Jake & Senan",
      "39": "Anthony & Michelle McMahon",
      "40": "Mike Murphy",
      "41": "Noreen & Eddie Ryan",
      "42": "Hannah & Eamon",
      "43": "Deron Keating",
      "44": "Tom Corrigan",
      "45": "Pat Hehir",
      "46": "John Stokes",
      "47": "William & Ita Sheahan",
      "48": "Ann Lenihan",
      "49": "Danny Harty Snr.",
      "50": "Richie Downes",
    };

    try {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Uploading...')),
      );
      await ref.read(ticketActionsProvider).batchUploadHolders(holdersData);
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Upload successful!')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }
}
