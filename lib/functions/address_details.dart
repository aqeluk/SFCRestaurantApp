import 'package:flutter/material.dart';
import 'package:socket_io_example/functions/fetch_ukaddress_details.dart';

class AddressDetailsWidget extends StatelessWidget {
  final String addressId;

  const AddressDetailsWidget({super.key, required this.addressId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: fetchUKAddressDetails(addressId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        var addressDetails = snapshot.data;
        return Text("Address Details: ${addressDetails['address']}");
      },
    );
  }
}
