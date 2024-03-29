import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_example/main.dart';
import 'package:socket_io_example/functions/capitalize.dart';
import 'package:socket_io_example/functions/fetch_user_details.dart';
import 'package:socket_io_example/functions/fetch_ukaddress_details.dart';
import 'package:socket_io_example/functions/print_util.dart';
import 'package:logging/logging.dart';

final _logger = Logger('PreviousOrdersPage');

class PreviousOrdersPage extends StatefulWidget {
  final VoidCallback onBack;
  const PreviousOrdersPage({super.key, required this.onBack});

  @override
  State<PreviousOrdersPage> createState() => _PreviousOrdersPage();
}

class _PreviousOrdersPage extends State<PreviousOrdersPage> {
  final _stream = supabase
      .from('Order')
      .stream(primaryKey: ['id']).inFilter('orderStatus', ['Completed', 'Cancelled']);

  void onBack() {
    widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Previous Orders"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: StreamBuilder(
        stream: _stream,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data.isEmpty) {
            return const Center(child: Text("No previous orders found"));
          }

          List orders = snapshot.data; // Assuming data is a list of orders

          return ListView.separated(
            itemCount: orders.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.grey),
            itemBuilder: (context, index) {
              var order = orders[index];
              List<dynamic> products = order['products'];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ExpandablePanel(
                  header: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        "Customer: ${order['userName']} | Order ID: ${order['id']}"),
                  ),
                  collapsed: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Due At: ${order['deliveryTime']} | Status: ${capitalize(order['orderStatus'])}",
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  expanded: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Order Details:",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                ...products.map((product) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            "${product['title']}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                          Text(" x ${product['quantity']}"),
                                        ],
                                      ),
                                      if (product['specificMeal'] != null)
                                        Text(
                                            "Meal Type: ${product['specificMeal']}"),
                                      if (product['extras'] != null &&
                                          product['extras'].isNotEmpty)
                                        Text(
                                            "Extras: ${product['extras'].join(', ')}"),
                                      if (product['salads'] != null &&
                                          product['salads'].isNotEmpty)
                                        Text("${product['salads'].join(', ')}",
                                            style:
                                                const TextStyle(fontSize: 12)),
                                      if (product['sauces'] != null &&
                                          product['sauces'].isNotEmpty)
                                        Text("${product['sauces'].join(', ')}",
                                            style:
                                                const TextStyle(fontSize: 12)),
                                      if (product['genericMeal'] != null)
                                        Text("${product['genericMeal']}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      if (product['drink'] != null &&
                                          product['drink'].isNotEmpty)
                                        Text("${product['drink'].join(', ')}",
                                            style:
                                                const TextStyle(fontSize: 12)),
                                      if (product['selectedPizzas'] != null &&
                                          product['selectedPizzas'].isNotEmpty)
                                        Text(
                                            "Selected Pizzas: ${product['selectedPizzas'].join(', ')}"),
                                      if (product['pizzaToppings'] != null &&
                                          product['pizzaToppings'].isNotEmpty)
                                        Text(
                                            "Pizza Toppings: ${product['pizzaToppings'].join(', ')}"),
                                      const SizedBox(height: 10),
                                      Text(
                                          "Price: £${product['price'].toStringAsFixed(2)}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  );
                                }),
                              ],
                            )),
                            Expanded(
                              child: FutureBuilder(
                                future: fetchUserDetails(order['userEmail']),
                                builder: (context, AsyncSnapshot snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }
                                  if (snapshot.hasError) {
                                    return Text("Error: ${snapshot.error}");
                                  }
                                  var userDetails = snapshot.data[0];
                                  dynamic ukAddressDetails;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Delivery Method: ${capitalize(order['deliveryMethod'])}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      const SizedBox(height: 10),
                                      const Text("User Details:",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                      Text("${userDetails['name']}"),
                                      if (order['deliveryMethod'] ==
                                          "delivery") ...[
                                        FutureBuilder(
                                          future: fetchUKAddressDetails(
                                              order['uKAddressId']),
                                          builder: (context,
                                              AsyncSnapshot snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const CircularProgressIndicator();
                                            }
                                            if (snapshot.hasError) {
                                              return Text(
                                                  "Error: ${snapshot.error}");
                                            }
                                            ukAddressDetails = snapshot.data[0];
                                            return Text(
                                                "Address Details: $ukAddressDetails");
                                          },
                                        ),
                                      ],
                                      Text("${userDetails['phoneNumber']}"),
                                      ElevatedButton(
                                        onPressed: () async {
                                          try {
                                            if (order['deliveryMethod'] ==
                                                    "delivery" &&
                                                ukAddressDetails != null) {
                                              PrintUtils.printReceipt(order,
                                                  userDetails: userDetails,
                                                  ukAddressDetails:
                                                      ukAddressDetails);
                                            } else {
                                              PrintUtils.printReceipt(order,
                                                  userDetails: userDetails);
                                            }
                                          } catch (error) {
                                            _logger.severe(
                                                'Error reprinting receipt: $error');
                                          }
                                        },
                                        child: const Text("Reprint Receipt"),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                "Due At: ${order['deliveryTime']} | Status: ${capitalize(order['orderStatus'])}",
                                softWrap: true,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  theme: const ExpandableThemeData(
                    iconColor: Colors.black,
                    useInkWell: true,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
