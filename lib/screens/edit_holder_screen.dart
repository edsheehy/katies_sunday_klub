import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katies_sunday_klub/models/ticket_holder_model.dart';
import 'package:katies_sunday_klub/providers/providers.dart';

class EditHolderScreen extends ConsumerStatefulWidget {
  final TicketHolder ticketHolder;

  const EditHolderScreen({
    Key? key,
    required this.ticketHolder,
  }) : super(key: key);

  @override
  _EditHolderScreenState createState() => _EditHolderScreenState();
}

class _EditHolderScreenState extends ConsumerState<EditHolderScreen> {
  // Add a new controller for the balance field.
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize both controllers with the current ticket data.
    _nameController = TextEditingController(text: widget.ticketHolder.holders);
    _balanceController = TextEditingController(text: widget.ticketHolder.balance.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  /// Handles the save action for both name and balance.
  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Parse the balance from the text field.
      final newBalance = double.tryParse(_balanceController.text);

      try {
        // Use the new, more flexible repository method.
        final repository = ref.read(ticketRepositoryProvider);
        await repository.updateTicketDetails(
          ticketId: widget.ticketHolder.id,
          holders: _nameController.text,
          balance: newBalance,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Details updated successfully!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating details: $e')),
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
        // Updated title to be more generic.
        title: Text('Edit Ticket #${widget.ticketHolder.id}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name Text Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Holder Name(s)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name for the holder.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // NEW: Balance Text Field
              TextFormField(
                controller: _balanceController,
                decoration: const InputDecoration(
                  labelText: 'Balance',
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
                    return 'Please enter a balance.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
                onPressed: _saveChanges, // Call the updated save function
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
