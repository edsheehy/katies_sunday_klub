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
  void _addPredefinedAmount(double amount) {
    _controller.text = amount.toStringAsFixed(2);
  }

  /// Handles the save action.
  Future<void> _addCredit() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_controller.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final repository = ref.read(ticketRepositoryProvider);
        await repository.addCredit(widget.ticketHolder.id, amount);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('€$amount added successfully!')),
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
                'Current Balance: €${widget.ticketHolder.balance.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineMedium,
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
                // Use a regex to allow only numbers and a single decimal point.
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number.';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than zero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Quick-add buttons for common amounts
              Wrap(
                spacing: 8.0,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(onPressed: () => _addPredefinedAmount(10), child: const Text('€10')),
                  ElevatedButton(onPressed: () => _addPredefinedAmount(20), child: const Text('€20')),
                  ElevatedButton(onPressed: () => _addPredefinedAmount(40), child: const Text('€40')),
                  ElevatedButton(onPressed: () => _addPredefinedAmount(50), child: const Text('€50')),
                ],
              ),
              const Spacer(), // Pushes the button to the bottom
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                icon: const Icon(Icons.add_card),
                label: const Text('Add Credit'),
                onPressed: _addCredit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0), backgroundColor: Colors.green, // A distinct color for adding money
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}