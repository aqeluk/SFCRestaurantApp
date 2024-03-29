import 'dart:typed_data';
import 'package:flutter_star_prnt/flutter_star_prnt.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:socket_io_example/functions/convert_image_to_bytes.dart';
import 'package:socket_io_example/functions/fetch_user_details.dart';
import 'package:socket_io_example/functions/fetch_ukaddress_details.dart';
import 'package:socket_io_example/functions/format_due_time.dart';

final _logger = Logger('PrintingUtility');

class PrintUtils {
  static Future<void> printReceipt(
    var order, {
    dynamic userDetails,
    dynamic ukAddressDetails,
  }) async {
    List<PortInfo> printers =
        await StarPrnt.portDiscovery(StarPortType.Bluetooth);

    for (var printer in printers) {
      // Check printer status
      PrinterResponseStatus status = await StarPrnt.getStatus(
          portName: printer.portName!, emulation: 'StarGraphic');
      if (!status.offline && userDetails != null) {
        final DateTime currentDeliveryTime =
          DateTime.parse(order['deliveryTime']);
        PrintCommands commands = PrintCommands();
        dynamic fetchingUserDetails =
            await fetchUserDetails(userDetails['email']);
        dynamic userDetail = fetchingUserDetails.first;

        try {
          Uint8List imageData =
              await convertImageToBytes('assets/images/fullSFCLogo.png');
          commands.appendBitmapByte(
              byteData: imageData, alignment: StarAlignmentPosition.Center);
        } catch (error) {
          _logger.severe('Error loading image: $error');
        }

        String formattedCurrentTime =
            DateFormat('HH:mm dd/MM/yy').format(DateTime.now());
        String formattedDueTime = formatDueTime(currentDeliveryTime);
        // String restaurantInfo = "---------------------------------------\n"
        //     "         Southern Fried Chicken        \n"
        //     "         37A St Botolphs Street        \n"
        //     "           Colchester, Essex           \n"
        //     "                CO2 7EA                \n"
        //     "              01206 769181             \n"
        //     "              01206 762767             \n"
        //     "                                       \n"
        //     "          SFC-Colchester.com           \n"
        //     "\n"
        //     "             $formattedCurrentTime         "
        //     "\n"
        //     "---------------------------------------\n";
        // commands.appendBitmapText(text: restaurantInfo, fontSize: 12);

        commands.appendBitmapText(
            text: "  Order Type:    Due At:  \n", fontSize: 16);

        String orderTypeAndDueTime;
        if (order['deliveryMethod'] == "delivery") {
          orderTypeAndDueTime = "    Delivery      $formattedDueTime\n";
        } else {
          orderTypeAndDueTime = "   Collection     $formattedDueTime\n";
        }
        commands.appendBitmapText(text: orderTypeAndDueTime, fontSize: 14);

        commands.appendBitmapText(
            text: "---------------------------------------\n", fontSize: 12);

        commands.appendBitmapText(
            text: "Customer: ${userDetail['name']}\n", fontSize: 14);

        if (order['deliveryMethod'] == "delivery") {
          try {
            String deliveryDetails;
            var addressDetails =
                await fetchUKAddressDetails(order['uKAddressId']);
            deliveryDetails = "Address: ${addressDetails['line1']}\n";
            if (addressDetails['line2'] != null) {
              deliveryDetails += "${addressDetails['line2']}\n";
            }
            if (addressDetails['town_or_city'] != null) {
              deliveryDetails += "${addressDetails['town_or_city']}\n";
            }
            if (addressDetails['county'] != null) {
              deliveryDetails += "${addressDetails['county']}\n";
            }
            deliveryDetails += "${addressDetails['postcode']}\n";
            commands.appendBitmapText(text: deliveryDetails, fontSize: 14);
          } catch (error) {
            _logger.severe('Error fetching address details: $error');
          }
        }

        commands.appendBitmapText(
            text: "Phone: ${userDetail['phoneNumber']}\n", fontSize: 14);

        commands.appendBitmapText(
            text: "---------------------------------------\n", fontSize: 12);

        commands.appendBitmapText(text: "     Order Details\n", fontSize: 20);

        for (var product in order['products']) {
          commands.appendBitmapText(
              text: "---------------------------------------\n", fontSize: 12);
          commands.appendBitmapText(
              text: "${product['quantity']}x ${product['title']}",
              fontSize: 18);

          String orderDetails = "";
          if (product['specificMeal'] != null) {
            orderDetails += "    ${product['specificMeal']}\n";
          }
          if (product['selectedPizzas'] != null &&
              product['selectedPizzas'].isNotEmpty) {
            orderDetails += "    ${product['selectedPizzas'].join(', ')}\n";
          }
          if (product['pizzaToppings'] != null &&
              product['pizzaToppings'].isNotEmpty) {
            orderDetails += "    ${product['pizzaToppings'].join(', ')}\n";
          }
          if (product['extras'] != null && product['extras'].isNotEmpty) {
            orderDetails += "    ${product['extras'].join(', ')}\n";
          }
          if (product['salads'] != null && product['salads'].isNotEmpty) {
            for (var salad in product['salads']) {
              orderDetails += "    $salad\n";
            }
          }
          if (product['sauces'] != null && product['sauces'].isNotEmpty) {
            for (var sauce in product['sauces']) {
              orderDetails += "    $sauce\n";
            }
          }
          if (orderDetails.isNotEmpty) {
            orderDetails = orderDetails.substring(0, orderDetails.length - 1);
            commands.appendBitmapText(text: orderDetails, fontSize: 14);
          }

          if (product['genericMeal'] != null) {
            String genericMeal;
            genericMeal = "   ${product['genericMeal']}";
            commands.appendBitmapText(text: genericMeal, fontSize: 16);
          }

          if (product['drink'] != null && product['drink'].isNotEmpty) {
            String drink;
            drink = "    ${product['drink'].join(', ')}";
            commands.appendBitmapText(text: drink, fontSize: 14);
          }

          commands.appendBitmapText(
              text:
                  "                  £${product['price'].toStringAsFixed(2)}\n",
              fontSize: 18);
        }

        commands.appendBitmapText(
            text: "---------------------------------------\n", fontSize: 12);

        // Print Total
        commands.appendBitmapText(
            text: "Total:      £${order['totalPrice'].toStringAsFixed(2)}" "\n",
            fontSize: 24);

        // Courtesy Message
        commands.appendBitmapText(
            text: "Thank you for your order!", fontSize: 18);

        String curtoseyMessage = "   We hope you enjoy your meal\n"
            "     and we look forward to\n"
            "     seeing you again soon!\n";
        commands.appendBitmapText(text: curtoseyMessage, fontSize: 14);

        String websiteCTA = "     Visit us at\n"
            "   SFC-Colchester.com\n"
            " For our latest offers\n"
            "      and deals!\n";

        commands.appendBitmapText(text: websiteCTA, fontSize: 20);

        String websitePromoCode = "psst... Use Code 'WELOVESFC' At \n"
            "Checkout For 10% Off Your Order\n";

        commands.appendBitmapText(text: websitePromoCode, fontSize: 14);

        commands.appendBitmapText(
            text: "   Free Delivery Over £15!", fontSize: 16);

        // Cut Paper
        commands.appendCutPaper(StarCutPaperAction.FullCutWithFeed);

        // Print the receipt
        await StarPrnt.sendCommands(
            portName: printer.portName!,
            emulation: 'StarGraphic',
            printCommands: commands);
      }
    }
  }
}
