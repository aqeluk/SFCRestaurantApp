import 'package:flutter/material.dart';

class ProductDetails extends StatelessWidget {
  final List<dynamic> products;

  const ProductDetails({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ...products.map((product) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: <Widget>[
                            Text(
                              "${product['title']}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(" x ${product['quantity']}"),
                          ],
                        ),
                        if (product['specificMeal'] != null)
                          Text("Meal Type: ${product['specificMeal']}"),
                        if (product['extras'] != null &&
                            product['extras'].isNotEmpty)
                          Text("Extras: ${product['extras'].join(', ')}"),
                        if (product['salads'] != null &&
                            product['salads'].isNotEmpty)
                          Text("${product['salads'].join(', ')}",
                              style: const TextStyle(fontSize: 12)),
                        if (product['sauces'] != null &&
                            product['sauces'].isNotEmpty)
                          Text("${product['sauces'].join(', ')}",
                              style: const TextStyle(fontSize: 12)),
                        if (product['genericMeal'] != null)
                          Text("${product['genericMeal']}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        if (product['drink'] != null &&
                            product['drink'].isNotEmpty)
                          Text("${product['drink'].join(', ')}",
                              style: const TextStyle(fontSize: 12)),
                        if (product['selectedPizzas'] != null &&
                            product['selectedPizzas'].isNotEmpty)
                          Text(
                              "Selected Pizzas: ${product['selectedPizzas'].join(', ')}"),
                        if (product['pizzaToppings'] != null &&
                            product['pizzaToppings'].isNotEmpty)
                          Text(
                              "Pizza Toppings: ${product['pizzaToppings'].join(', ')}"),
                        const SizedBox(height: 10),
                        Text("Price: £${product['price'].toStringAsFixed(2)}",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    )),
              ],
            )),
          ],
        ),
      ],
    );
  }
}
