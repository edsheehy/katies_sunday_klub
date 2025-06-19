import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katies_sunday_klub/models/ticket_holder_model.dart';
import 'package:katies_sunday_klub/providers/providers.dart';

import '../providers/auth_providers.dart';
import 'add_credit_screen.dart';
import 'edit_holder_screen.dart';

// Note: You will need to create these screen files in the next steps.
// import 'package:katie_sunday_klub/screens/edit_holder_screen.dart';
// import 'package:katie_sunday_klub/screens/add_credit_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the ticketsProvider to get the stream of ticket holders.
    // The `.when()` clause is a clean way to handle loading/error/data states.
    final ticketsAsyncValue = ref.watch(ticketsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Katie's Sunday Klub"),
        // Example of a potential action, like logging out.
        actions: [
          // =================================================================
          // TEMP: Button to upload initial data. Remove after first use.
          // =================================================================
          // IconButton(
          //   icon: const Icon(Icons.upload_file),
          //   tooltip: 'Upload Initial Data',
          //   onPressed: () async {
          //     // Show a confirmation dialog before proceeding.
          //     final shouldUpload = await showDialog<bool>(
          //       context: context,
          //       builder: (context) => AlertDialog(
          //         title: const Text('Confirm Data Upload'),
          //         content: const Text(
          //           'This will upload the initial list of ticket holders. This is a one-time operation. Proceed?',
          //         ),
          //         actions: [
          //           TextButton(
          //             onPressed: () => Navigator.of(context).pop(false),
          //             child: const Text('Cancel'),
          //           ),
          //           TextButton(
          //             onPressed: () => Navigator.of(context).pop(true),
          //             child: const Text('UPLOAD'),
          //           ),
          //         ],
          //       ),
          //     );
          //
          //     // If the user confirms, proceed with the upload.
          //     if (shouldUpload == true && context.mounted) {
          //       _uploadInitialData(context, ref);
          //     }
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).signOut(),

          ),
        ],
      ),
      body: ticketsAsyncValue.when(
        // The data is available, so we build the list.
        data: (tickets) => _buildTicketList(context, tickets),
        // An error occurred.
        error: (err, stack) => Center(child: Text('An error occurred: $err')),
        // Data is still loading.
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  /// This function contains the data from your list and calls the repository.
  void _uploadInitialData(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Data extracted from the image, starting from #3 as requested.
    final Map<String, String> holdersData = {
      "3": "Rachel Fahy & Cong", "4": "Jimmy O'Donohue & Pat Dela", "5": "Haulie Kenny", "6": "Mackey & Jockser",
      "7": "Seven & Brid", "8": "Smiley & Yvonne", "9": "John Greaney & Hugh", "10": "Jockser & Mackey",
      "11": "Pa Moran & Mike Shanahan", "12": "Carmel Fitzsimons", "13": "Mick & Frankie Walsh", "14": "Joe & Mick Walsh",
      "15": "Mal Keaveney", "16": "Ailbhe & Ronnie Kelly", "17": "Colin & Catriona", "18": "Pa Moran & Mikey Barr",
      "19": "Jamie Moran", "20": "Ed Sheehy & Denis Keating", "21": "Mikey Barr", "22": "Paul & Marie",
      "23": "Luigi Lenihan", "24": "Johnny McMahon", "25": "Tommy Hartigan", "26": "Mick Flannery & Deron",
      "27": "Jackie & Pat Delahunty", "28": "Mike & Gabrielle Horan", "29": "Christy Walsh", "30": "Alan & Ita Kehoe",
      "31": "Ger Ranahan & Johnny McMahon", "32": "Eddie & Noreen Ryan", "33": "Pakie Moran", "34": "Tara & Colm",
      "35": "Francy O'Connell", "36": "Ondine & Haulie", "37": "Ronnie & Ailbhe Kelly", "38": "Jake & Senan",
      "39": "Anthony & Michelle McMahon", "40": "Mike Murphy", "41": "Noreen & Eddie Ryan", "42": "Hannah & Eamon",
      "43": "Deron Keating", "44": "Tom Corrigan", "45": "Pat Hehir", "46": "John Stokes",
      "47": "William & Ita Sheahan", "48": "Ann Lenihan", "49": "Danny Harty Snr.", "50": "Richie Downes"
    };

    try {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Uploading data... Please wait.')));
      await ref.read(ticketRepositoryProvider).batchUploadHolders(holdersData);
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Upload successful! Refreshing list...')));
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }
  /// Builds the main list view of ticket holders.
  Widget _buildTicketList(BuildContext context, List<TicketHolder> tickets) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  'No.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'Holder',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Balance',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.separated(
            // shrinkWrap: true,
            // Important when nesting ListViews
            // physics: const NeverScrollableScrollPhysics(),
            // Important when nesting ListViews
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              // Determine text color based on balance
              final balanceColor =
                  ticket.balance < 10 ? Colors.red : Colors.green;

              return ListTile(
                dense: true,
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
                  print('Navigate to Add Credit for ticket ${ticket.id}');
                },
                onLongPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => EditHolderScreen(ticketHolder: ticket),
                    ),
                  );
                  print('Navigate to Edit Holder for ticket ${ticket.id}');
                },
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 1),
          ),
        ),
      ],
    );
  }
}
