import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // pentru LogicalKeyboardKey

class CardPaymentPage extends StatefulWidget {
  final String type;
  final String line;

  const CardPaymentPage({Key? key, required this.type, required this.line})
    : super(key: key);

  @override
  State<CardPaymentPage> createState() => _CardPaymentPageState();
}

class _CardPaymentPageState extends State<CardPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();

    _expiryController.addListener(() {
      final text = _expiryController.text;

      if (_isDeleting) {
        _isDeleting = false;
        return;
      }

      if (text.length == 2 && !text.contains('/')) {
        _expiryController.text = text + '/';
        _expiryController.selection = TextSelection.fromPosition(
          TextPosition(offset: _expiryController.text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _onExpiryKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      _isDeleting = true;
    }
  }

  void _submitPayment() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(true); // întoarce true la final
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Plătește cu cardul')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _cardNumberController,
                  decoration: const InputDecoration(labelText: 'Număr card'),
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  validator:
                      (value) =>
                          value == null || value.length != 16
                              ? 'Card invalid'
                              : null,
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nume de pe card',
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Completează numele'
                              : null,
                ),
                RawKeyboardListener(
                  focusNode: FocusNode(),
                  onKey: _onExpiryKey,
                  child: TextFormField(
                    controller: _expiryController,
                    decoration: const InputDecoration(
                      labelText: 'Expirare (MM/YY)',
                    ),
                    validator: (value) {
                      if (value == null) return 'Dată invalidă';
                      final regex = RegExp(r'^\d{2}/\d{2}$');
                      if (!regex.hasMatch(value)) {
                        return 'Format invalid. Folosește MM/YY';
                      }

                      final parts = value.split('/');
                      final month = int.tryParse(parts[0]);
                      final year = int.tryParse(parts[1]);

                      if (month == null || year == null) return 'Dată invalidă';
                      if (month < 1 || month > 12) return 'Lună invalidă';

                      final now = DateTime.now();
                      final currentYear = now.year % 100;
                      final currentMonth = now.month;

                      if (year < currentYear) return 'Card expirat';
                      if (year == currentYear && month < currentMonth) {
                        return 'Card expirat';
                      }

                      return null;
                    },
                  ),
                ),
                TextFormField(
                  controller: _cvvController,
                  decoration: const InputDecoration(labelText: 'CVV'),
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  validator:
                      (value) =>
                          value == null || value.length != 3
                              ? 'CVV invalid'
                              : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitPayment,
                  child: const Text('Plătește și obține bilet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
