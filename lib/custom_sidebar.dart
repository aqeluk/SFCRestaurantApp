import 'package:flutter/material.dart';
import 'package:socket_io_example/main.dart';

class CustomSidebar extends StatefulWidget {
  final bool isExpanded;
  final bool isTakingOrders;
  final bool isTakingCashOrders;
  final VoidCallback toggleSidebar;
  final Function(String) onOptionSelected;
  final Function(bool) onToggleChanged;
  final Function(bool) onToggleCashChanged;

  const CustomSidebar(
      {super.key,
      required this.isExpanded,
      required this.isTakingOrders,
      required this.isTakingCashOrders,
      required this.toggleSidebar,
      required this.onOptionSelected,
      required this.onToggleChanged,
      required this.onToggleCashChanged});

  @override
  _CustomSidebarState createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.isExpanded ? 200 : 70,
      color: Colors.blue,
      child: Column(
        children: [
          _buildOrderToggle(),
          Expanded(
            child: SingleChildScrollView(
              // Scrollable middle part
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 100),
                  _buildOption('Previous Orders', Icons.show_chart),
                  _buildOption(
                      widget.isTakingOrders
                          ? 'Stop Taking Orders'
                          : 'Start Taking Orders',
                      Icons.stop_circle),
                  _buildOption(
                      widget.isTakingCashOrders
                          ? 'Stop Taking Cash Orders'
                          : 'Start Taking Cash Orders',
                      Icons.money_off),
                  _buildOption('Take Items Off Menu', Icons.remove_circle),
                ],
              ),
            ),
          ),
          // Bottom part with fixed options
          _buildOption('Status', Icons.info_sharp),
          _buildOption('Support', Icons.help),
        ],
      ),
    );
  }

  Widget _buildOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, size: 28, color: Colors.white),
      title: widget.isExpanded
          ? Text(title,
              style: const TextStyle(fontSize: 14, color: Colors.white))
          : null,
      onTap: () async {
        if (!widget.isExpanded) {
          widget.toggleSidebar();
        } else if (title == 'Start Taking Orders' ||
            title == 'Stop Taking Orders') {
          bool newStatus = title == 'Start Taking Orders';
          print("New status: $newStatus");
          await _updateRestaurantOrderStatus(newStatus);
        } else if (title == 'Start Taking Cash Orders' ||
            title == 'Stop Taking Cash Orders') {
          bool newStatus = title == 'Start Taking Cash Orders';
          print("New status: $newStatus");
          await _updateRestaurantTakingCash(newStatus);
        } else {
          widget.onOptionSelected(title);
          if (title != 'Stop Taking Orders' &&
              title != 'Start Taking Orders' &&
              title != 'Stop Taking Cash Orders' &&
              title != 'Start Taking Cash Orders') {
            widget.toggleSidebar();
          }
        }
      },
    );
  }

  Widget _buildOrderToggle() {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.swap_horiz, size: 20, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              widget.isTakingOrders ? 'Taking Orders Now' : 'Not Taking Orders',
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Switch(
              value: widget.isTakingOrders,
              onChanged: (value) async {
                await _updateRestaurantOrderStatus(value);
              },
              activeColor: Colors.white,
              inactiveThumbColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateRestaurantOrderStatus(bool isTakingOrders) async {
    try {
      await supabase
          .from('Restaurant')
          .update({'isDelivering': isTakingOrders}).match(
              {'id': 'clri9a29i0000ykawb42n7hz4'});

      setState(() {
        widget.onToggleChanged(isTakingOrders);
      });
    } catch (e) {
      print("Error updating restaurant status: $e");
    }
  }

  Future<void> _updateRestaurantTakingCash(bool isTakingCashOrders) async {
    try {
      await supabase
          .from('Restaurant')
          .update({'isTakingCash': isTakingCashOrders}).match(
              {'id': 'clri9a29i0000ykawb42n7hz4'});

      setState(() {
        widget.onToggleCashChanged(isTakingCashOrders);
      });
    } catch (e) {
      print("Error updating restaurant status: $e");
    }
  }
}
