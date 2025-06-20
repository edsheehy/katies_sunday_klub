import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katies_sunday_klub/models/ticket_holder_model.dart';
import 'package:katies_sunday_klub/providers/providers.dart';

class AddCreditScreen extends ConsumerStatefulWidget {
  final TicketHolder ticketHolder;

  const AddCreditScreen({
    Key? key,
    required this.ticketHolder,
  }) : super(key: key);

  @override
  _AddCreditScreenState createState() => _AddCreditScreenState();
}

class _AddCreditScreenState extends ConsumerState<AddCreditScreen> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Adds a predefined amount to the text field.
  void _addPredefinedAmount(int amount) { // Changed parameter type to int
    _controller.text = amount.toString(); // Changed to toString() for integer display
  }

  /// Handles the save action.
  Future<void> _addCredit() async {
    if (_formKey.currentState!.validate()) {
      final amount = int.tryParse(_controller.text); // Changed to int.tryParse
      if (amount == null || amount <= 0) { // Check for int amount
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid whole amount greater than zero.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // CORRECTED: Use the new, simplified ticketActionsProvider.
        await ref.read(ticketActionsProvider).addCredit(widget.ticketHolder.id, amount.toDouble()); // Pass as double if addCredit expects double
        // If your addCredit method expects an int, remove .toDouble()

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('€$amount added successfully!')), // Display as int
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding credit: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Credit for ${widget.ticketHolder.holders}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Current Balance: €${widget.ticketHolder.balance.toInt().toString()}', // Display current balance as int
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Amount to Add (€)',
                  prefixText: '€',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+')), // Allow only digits
                ],
                keyboardType: TextInputType.number, // Suggest numeric keyboard without decimal
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount.';
                  }
                  final parsedValue = int.tryParse(value); // Parse as int
                  if (parsedValue == null) {
                    return 'Please enter a valid whole number.';
                  }
                  if (parsedValue <= 0) { // Check for positive integer
                    return 'Amount must be greater than zero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8.0,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(onPressed: () => _addPredefinedAmount(10), child: const Text('€10')), // Pass int
                  ElevatedButton(onPressed: () => _addPredefinedAmount(20), child: const Text('€20')), // Pass int
                  ElevatedButton(onPressed: () => _addPredefinedAmount(50), child: const Text('€50')), // Pass int
                ],
              ),
              const Spacer(),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                icon: const Icon(Icons.add_card),
                label: const Text('Add Credit'),
                onPressed: _addCredit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}