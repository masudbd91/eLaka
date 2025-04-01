import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class OfferScreen extends StatefulWidget {
  final String chatId;
  final String listingId;
  final double originalPrice;

  const OfferScreen({
    super.key,
    required this.chatId,
    required this.listingId,
    required this.originalPrice,
  });

  @override
  _OfferScreenState createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set initial price to 80% of original price
    _priceController.text = (widget.originalPrice * 0.8).toStringAsFixed(
      widget.originalPrice.truncateToDouble() == widget.originalPrice ? 0 : 2,
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _sendOffer() async {
    final price = double.tryParse(_priceController.text);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Send offer
      await DatabaseService().sendOffer(
        widget.chatId,
        widget.listingId,
        price,
        _noteController.text.trim(),
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer sent successfully')),
      );

      // Navigate back
      Navigator.of(context).pop();
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send offer: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make an Offer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Original price
            Text(
              'Original Price',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              widget.originalPrice == 0
                  ? 'Free'
                  : '\$${widget.originalPrice.toStringAsFixed(widget.originalPrice.truncateToDouble() == widget.originalPrice ? 0 : 2)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24.0),
            // Offer price
            Text(
              'Your Offer',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24.0),
            // Note
            Text(
              'Add a Note (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Example: I can pick it up today if you accept my offer.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24.0),
            // Tips
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tips for Making an Offer',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    '• Be reasonable with your offer\n'
                        '• Explain why you\'re offering a different price\n'
                        '• Mention if you can pick up soon\n'
                        '• Be polite and respectful',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            // Send button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendOffer,
                child: _isLoading
                    ? const SizedBox(
                  height: 20.0,
                  width: 20.0,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.0,
                  ),
                )
                    : const Text('Send Offer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}