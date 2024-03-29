import 'package:flutter/material.dart';
import 'package:socket_io_example/functions/capitalize.dart'; 

class UserDetailsWidget extends StatelessWidget {
  final dynamic userDetails;
  final String deliveryMethod;

  const UserDetailsWidget({
    super.key,
    required this.userDetails,
    required this.deliveryMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Delivery Method: ${capitalize(deliveryMethod)}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        const Text("User Details:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text("${userDetails['name']}"),
        Text("${userDetails['phoneNumber']}"),
      ],
    );
  }
}
