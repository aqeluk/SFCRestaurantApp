import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:socket_io_example/functions/capitalize.dart';
import 'package:socket_io_example/functions/fetch_ukaddress_details.dart';
import 'package:socket_io_example/functions/fetch_user_details.dart';
import 'package:socket_io_example/popups/adjust_time_dialog.dart';
import 'package:socket_io_example/functions/print_util.dart';

typedef OnStateUpdate = void Function(VoidCallback fn);
typedef AdjustTimeDialogBuilder = Widget Function(
    BuildContext context, dynamic order);

List<String> cancellationReasons = [
  "Out of stock ingredients",
  "Technical issue with order processing",
  "Unable to reach customer for confirmation",
  "Payment transaction failed",
  "Delivery service unavailable",
  "Extreme weather conditions",
  "Kitchen equipment malfunction",
  "Staffing shortages",
  "Order preparation error",
  "Customer requested cancellation",
  "Suspected fraudulent order",
  "Delivery address out of service area",
  "Product quality issues",
  "Customer unreachable at delivery",
  "Operational overload",
];

class OrdersListView extends StatelessWidget {
  final String status;
  final OnStateUpdate updateState;
  final Logger logger;
  final Stream stream;
  final AdjustTimeDialogBuilder adjustTimeDialogBuilder;
  final Map<String, AnimationController> flashingControllers;
  final void Function(String orderId) stopFlashingCallback;
  final void Function(String orderId) stopSoundCallback;
  final Future<void> Function(String orderId, String newStatus)
      supabaseUpdateCallback;
  final Future<void> Function(dynamic order, int timeAdjustment)
      supabaseAdjustTimeCallback;
  final Future<void> Function(String orderId, String reasoning)
      supabaseCancelCallback;

  const OrdersListView({
    super.key,
    required this.status,
    required this.updateState,
    required this.logger,
    required this.stream,
    required this.adjustTimeDialogBuilder,
    required this.flashingControllers,
    required this.stopFlashingCallback,
    required this.stopSoundCallback,
    required this.supabaseUpdateCallback,
    required this.supabaseAdjustTimeCallback,
    required this.supabaseCancelCallback,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const Text('Loading...');
        }
        List<dynamic> orders = snapshot.data ?? [];
        // No orders state
        if (orders.isEmpty) {
          // Customize the message based on the 'status' if needed
          String noOrdersMessage = status == 'Preparing'
              ? 'No pending orders'
              : 'No orders on the way';
          return Center(
            child: Text(noOrdersMessage),
          );
        }
        return ListView.separated(
          separatorBuilder: (context, index) =>
              const Divider(color: Colors.grey),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            dynamic order = orders[index];
            return AnimatedBuilder(
              animation: flashingControllers[order['id']] ??
                  const AlwaysStoppedAnimation(0),
              builder: (context, child) {
                final controller = flashingControllers[order['id']];
                final isFlashing = controller != null && controller.isAnimating;
                return Opacity(
                  opacity: isFlashing ? controller.value : 1.0,
                  child: child,
                );
              },
              child: _buildOrderTile(order, context, stopFlashingCallback,
                  stopSoundCallback), // Extract order tile building logic into a separate method.
            );
          },
        );
      },
    );
  }

  Widget _buildOrderTile(dynamic order, BuildContext context,
      void Function(String) stopFlashing, void Function(String) stopSound) {
    String remainingTime;
    if (order['deliveryTime'] != null) {
      final now = DateTime.now();
      final DateTime deliveryTime = DateTime.parse(order['deliveryTime']);
      final difference = deliveryTime.difference(now);
      if (difference.isNegative) {
        remainingTime =
            "Time exceeded by ${difference.inHours.abs()}h ${difference.inMinutes.abs().remainder(60)}m";
      } else {
        remainingTime =
            "${difference.inHours}h ${difference.inMinutes % 60}m remaining";
      }
    } else {
      remainingTime = "Not set";
    }

    return ListTile(
      title: Text("Order ID: ${order['id']}"),
      subtitle: FutureBuilder(
        future: fetchUserDetails(order['userEmail']),
        builder: (BuildContext context, AsyncSnapshot userDetailsSnapshot) {
          if (userDetailsSnapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (userDetailsSnapshot.hasError) {
            return Text("Error: ${userDetailsSnapshot.error}");
          } else {
            var userDetails = userDetailsSnapshot.data[0];
            // Check if delivery method is 'delivery' to decide on fetching UK address details
            if (order['deliveryMethod'] == "delivery") {
              // Inner FutureBuilder for fetching UK address details
              return FutureBuilder(
                future: fetchUKAddressDetails(order['uKAddressId']),
                builder: (BuildContext context, AsyncSnapshot addressSnapshot) {
                  if (addressSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (addressSnapshot.hasError) {
                    return Text("Error: ${addressSnapshot.error}");
                  } else {
                    var ukAddressDetails = addressSnapshot.data[0];
                    // Now build the ExpansionTile with both fetched user details and UK address details
                    return buildExpansionTile(
                        order,
                        userDetails,
                        ukAddressDetails,
                        remainingTime,
                        context,
                        stopFlashing,
                        stopSound);
                  }
                },
              );
            } else {
              // If not 'delivery', build the ExpansionTile without UK address details
              return buildExpansionTile(order, userDetails, null, remainingTime,
                  context, stopFlashing, stopSound);
            }
          }
        },
      ),
    );
  }

  Widget buildExpansionTile(
      dynamic order,
      var userDetails,
      var ukAddressDetails,
      String remainingTime,
      BuildContext context,
      void Function(String) stopFlashing,
      void Function(String) stopSound) {
    return ExpansionTile(
      title: Text("Customer: ${order['userName']} | Order ID: ${order['id']}"),
      subtitle: (ukAddressDetails != null)
          ? Text(
              'Postcode: ${ukAddressDetails['postcode']}, Phone: ${userDetails['phone']}\nTime Remaining: $remainingTime')
          : Text(
              'Phone: ${userDetails['phoneNumber']}\nTime Remaining: $remainingTime'),
      leading: const Icon(Icons.receipt),
      onExpansionChanged: (bool expanded) {
        if (expanded) {
          stopFlashing(order['id']);
          stopSound(order['id']);
        }
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (order['orderStatus'] == 'Preparing')
            ElevatedButton(
              onPressed: () {
                updateState(() {
                  supabaseUpdateCallback(order['id'], 'enRoute');
                  logger.info('Order ID: ${order['id']} is on its way');
                });
              },
              child: const Text('On its way'),
            ),
          if (order['orderStatus'] == 'enRoute')
            ElevatedButton(
              onPressed: () {
                updateState(() {
                  supabaseUpdateCallback(order['id'], 'completed');
                  logger.info('Order ID: ${order['id']} is completed');
                });
              },
              child: const Text('Completed'),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Reprint Ticket') {
                try {
                  if (order['deliveryMethod'] == "delivery" &&
                      ukAddressDetails != null) {
                    PrintUtils.printReceipt(order,
                        userDetails: userDetails,
                        ukAddressDetails: ukAddressDetails);
                  } else {
                    PrintUtils.printReceipt(order, userDetails: userDetails);
                  }
                  logger.info('Reprinting ticket for Order ID: ${order['id']}');
                } catch (error) {
                  logger.severe('Error reprinting receipt: $error');
                }
              } else if (value == 'Adjust Time') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AdjustTimeDialog(
                    order: order,
                    onAdjustTime: (dynamic order, int timeAdjustment) {
                      // Ensure the adjustment logic is called within updateState
                      updateState(() {
                        try {
                          supabaseAdjustTimeCallback(order, timeAdjustment);
                          logger.info(
                              "Time adjusted by $timeAdjustment minutes for Order ID: ${order['id']}");
                        } catch (error) {
                          logger.severe(
                              'Error adjusting time for Order ID: ${order['id']}: $error');
                        }
                      });
                    },
                  ),
                );
              } else if (value == 'Cancel') {
                // Variable to hold the selected reason
                String? selectedReason;
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      // Use StatefulBuilder to update the dropdown's state
                      builder: (context, setState) {
                        return AlertDialog(
                          title: const Text('Confirm Cancellation'),
                          content: SingleChildScrollView(
                            // Use SingleChildScrollView for content that might overflow
                            child: ListBody(
                              children: <Widget>[
                                const Text(
                                    'Please select a reason for cancellation:'),
                                DropdownButton<String>(
                                  hint: const Text("Select reason"),
                                  value: selectedReason,
                                  isExpanded: true,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedReason = newValue!;
                                    });
                                  },
                                  items: cancellationReasons
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); // Dismiss dialog without action
                              },
                            ),
                            TextButton(
                              onPressed: selectedReason != null
                                  ? () {
                                      // Proceed with cancellation using the selected reason
                                      updateState(() {
                                        supabaseUpdateCallback(order['id'],
                                            selectedReason!); // Update the order status
                                        logger.info(
                                            "Order ID: ${order['id']} cancelled for reason: $selectedReason");
                                        Navigator.of(context)
                                            .pop(); // Dismiss the dialog
                                      });
                                      logger.info(
                                          "Order ID: ${order['id']} cancelled for reason: $selectedReason");
                                    }
                                  : null,
                              child: const Text(
                                  'Confirm'), // Disable the button if no reason is selected
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              }
            },
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Reprint Ticket',
                child: Text('Reprint Ticket'),
              ),
              const PopupMenuItem<String>(
                value: 'Adjust Time',
                child: Text('Adjust Time'),
              ),
              const PopupMenuItem<String>(
                value: 'Cancel',
                child: Text('Cancel Order'),
              ),
            ],
          ),
        ],
      ),
      children: _buildOrderItems(order),
    );
  }

  List<Widget> _buildOrderItems(dynamic order) {
    List<dynamic> products = order['products'];

    List<Widget> productWidgets = products.map<Widget>((product) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Payment Method: ${capitalize(order['paymentMethod'])} - Payment Status: ${order['orderStatus']}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // This spreads out the children across the row's main axis
              children: <Widget>[
                Expanded(
                  child: Text(
                    "${product['quantity']} x ${product['title']}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    overflow:
                        TextOverflow.ellipsis, // Prevents text from overflowing
                  ),
                ),
                Text("£${product['price'].toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            if (product['specificMeal'] != null)
              Text("Meal Type: ${product['specificMeal']}"),
            if (product['extras'] != null && product['extras'].isNotEmpty)
              Text("Extras: ${product['extras'].join(', ')}"),
            if (product['salads'] != null && product['salads'].isNotEmpty)
              Text("${product['salads'].join(', ')}",
                  style: const TextStyle(fontSize: 12)),
            if (product['sauces'] != null && product['sauces'].isNotEmpty)
              Text("${product['sauces'].join(', ')}",
                  style: const TextStyle(fontSize: 12)),
            if (product['genericMeal'] != null)
              Text("${product['genericMeal']}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            if (product['drink'] != null && product['drink'].isNotEmpty)
              Text("${product['drink'].join(', ')}",
                  style: const TextStyle(fontSize: 12)),
            if (product['selectedPizzas'] != null &&
                product['selectedPizzas'].isNotEmpty)
              Text("Selected Pizzas: ${product['selectedPizzas'].join(', ')}"),
            if (product['pizzaToppings'] != null &&
                product['pizzaToppings'].isNotEmpty)
              Text("Pizza Toppings: ${product['pizzaToppings'].join(', ')}"),
          ],
        ),
      );
    }).toList();

    if (order['price'] != null) {
      productWidgets.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Subtotal: £${order['price'].toStringAsFixed(2)}", // Assuming 'subtotal' is correct
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                "Discounts Used: -£${order['price'].toStringAsFixed(2)}", // Assuming 'discountAmount' is correct
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                "Delivery Charge: £${order['price'].toStringAsFixed(2)}", // Assuming 'deliveryCharge' is correct
                style: const TextStyle(fontSize: 14),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  // This Column wraps the additional details
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Price: £${order['price'].toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return productWidgets;
  }
}
