import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  final VoidCallback onBack;

  const SupportPage({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("For any queries or support, please contact us at:"),
            SizedBox(height: 20),
            Text("Email: aqeluk@outlook.com | support@aqel.uk", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Phone: +44 7554 075 725", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
