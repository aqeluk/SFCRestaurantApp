import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket_io_example/custom_sidebar.dart';
import 'package:socket_io_example/functions/fetch_ukaddress_details.dart';
import 'package:socket_io_example/functions/fetch_user_details.dart';
import 'package:socket_io_example/main.dart';
import 'package:logging/logging.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:socket_io_example/popups/adjust_time_dialog.dart';
import 'package:socket_io_example/widgets/orders_list_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:socket_io_example/functions/print_util.dart';

final _logger = Logger('OrdersPage');
typedef AdjustTimeDialogBuilder = Widget Function(
    BuildContext context, dynamic order);

class OrdersPage extends StatefulWidget {
  final Function(String) onSidebarOptionSelected;
  final bool isTakingOrders;
  final bool isTakingCashOrders;
  final Function(bool) onToggleChanged;
  final Function(bool) onToggleCashChanged;

  const OrdersPage(
      {super.key,
      required this.onSidebarOptionSelected,
      required this.isTakingOrders,
      required this.isTakingCashOrders,
      required this.onToggleChanged,
      required this.onToggleCashChanged});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late final AdjustTimeDialogBuilder adjustTimeDialogBuilder;
  late final Map<String, AnimationController> flashingControllers;
  bool isSidebarExpanded = false;
  AudioPlayer audioPlayer = AudioPlayer();
  final Map<String, bool> _audioPlayingStates = {};
  final Map<String, AnimationController> _flashingControllers = {};
  late RealtimeChannel _subscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _subscribeToChanges();
  }

  void _subscribeToChanges() {
    _subscription = supabase
        .channel('public:Order')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: '*',
            table: '*',
            callback: (payload) {
              if (payload.newRecord['deliveryMethod'] == "delivery") {
                _handleNewOrder(
                    payload.newRecord['id'],
                    payload.newRecord['deliveryMethod'],
                    payload.newRecord['ukAddressId'],
                    payload.newRecord['userEmail']);
              } else {
                _handleNewOrder(
                    payload.newRecord['id'],
                    payload.newRecord['deliveryMethod'],
                    null,
                    payload.newRecord['userEmail']);
              }
              _logger.info('Change received: ${payload.toString()}');
            })
        .subscribe();
  }

  Future<void> _handleNewOrder(String orderId, String deliveryMethod,
      String? ukAddressId, String userEmail) async {
    try {
      final order = await supabase.from('Order').select().eq('id', orderId);
      final userDetails = await fetchUserDetails(userEmail);
      String ukAddressDetails;
      if (deliveryMethod == "delivery") {
        ukAddressDetails = await fetchUKAddressDetails(ukAddressId!);
        PrintUtils.printReceipt(order[0],
            userDetails: userDetails[0], ukAddressDetails: ukAddressDetails[0]);
      } else {
        PrintUtils.printReceipt(order[0], userDetails: userDetails[0]);
      }
      _initiateFlashing(orderId);
      _playAlertSound(orderId);
    } catch (error) {
      // Handle errors, potentially show an error message to the user
      _logger.severe('Error handling new order: $error');
    }
  }

  void _initiateFlashing(String orderId) {
    var controller = AnimationController(
      duration: const Duration(milliseconds: 500), // Flash every 0.5 seconds
      vsync: this,
    )..repeat(reverse: true);

    _flashingControllers[orderId] = controller;

    // Stop flashing after 5 seconds
    Timer(const Duration(seconds: 5), () {
      controller.stop();
      controller.value = 1.0;
    });
  }

  void stopFlashingForOrder(String orderId) {
    var controller = _flashingControllers[orderId];
    if (controller != null && controller.isAnimating) {
      controller.stop();
      controller.value = 1.0; // Ensure the widget is fully opaque
    }
  }

  void stopAlertSoundForOrder(String orderId) {
    _audioPlayingStates[orderId] = false;
  }

  Future<void> _playAlertSound(String orderId) async {
    _audioPlayingStates[orderId] = true;
    try {
      for (int i = 0; i < 10; i++) {
        if (!(_audioPlayingStates[orderId] ?? false)) break;
        await audioPlayer.play(AssetSource('sounds/alert_sound.mp3'));
        await Future.delayed(const Duration(seconds: 1));
      }
    } catch (e) {
      _logger.severe("Error playing alert sound: $e");
    }
    _audioPlayingStates[orderId] = false;
  }

  void _toggleSidebar() {
    setState(() {
      isSidebarExpanded = !isSidebarExpanded;
    });
  }

  Future<void> updateOrderStatusInSupabase(
      String orderId, String newStatus) async {
    try {
      await supabase
          .from('Order')
          .update({'orderStatus': newStatus}).match({'id': orderId});
      _logger.info('Order status updated in Supabase for Order ID: $orderId');
    } catch (e) {
      _logger.severe('Failed to update order status in Supabase: $e');
    }
  }

  Future<void> adjustOrderTimingInSupabase(
      dynamic order, int timeAdjustment) async {
    try {
      final DateTime currentDeliveryTime =
          DateTime.parse(order['deliveryTime']);
      final adjustedDeliveryTime = currentDeliveryTime
          .add(Duration(minutes: timeAdjustment))
          .toIso8601String();
      await supabase.from('Order').update(
          {'deliveryTime': adjustedDeliveryTime}).match({'id': order['id']});
      _logger.info(
          'Order status updated in Supabase for Order ID: ${order['id']}');
    } catch (e) {
      _logger.severe('Failed to adjust delivery time in Supabase: $e');
    }
  }

  Future<void> cancelOrderInSupabase(String orderId, String reasoning) async {
    try {
      await supabase.from('Order').update({
        'orderStatus': 'Cancelled', // Update status to 'cancelled'
        'cancelReasoning': reasoning, // Add the cancellation reasoning
      }).match({'id': orderId}); // Match the specific order by its ID

      _logger.info(
          'Order status updated in Supabase for Order ID: $orderId with reason: $reasoning');
    } catch (e) {
      _logger.severe('Failed to cancel order status in Supabase: $e');
    }
  }

  Widget _buildTopBar() {
    return AppBar(
      backgroundColor: Colors.blue,
      leadingWidth: 100, // Increase the width
      leading: IconButton(
        icon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSidebarExpanded ? Icons.close : Icons.menu,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Flexible(
              // Wrap the Text widget with Flexible
              child: Text(
                isSidebarExpanded ? 'Close' : 'Menu',
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        onPressed: _toggleSidebar,
      ),
      title: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Preparing'),
          Tab(text: 'On The Way'),
        ],
      ),
      elevation: 0.0,
    );
  }

  Stream<List<dynamic>> streamPreparingOrders() {
    return supabase
        .from('Order')
        .stream(primaryKey: ['id']).eq('orderStatus', 'Preparing');
  }

  Stream<List<dynamic>> streamEnRouteOrders() {
    return supabase
        .from('Order')
        .stream(primaryKey: ['id']).eq('orderStatus', 'On The Way');
  }

  Widget _adjustTimeDialogBuilder(BuildContext context, dynamic order) {
    return AdjustTimeDialog(
      order: order,
      onAdjustTime: (dynamic order, int timeAdjustment) {
        setState(() {
          order.adjustDeliveryTime(timeAdjustment);
        });
        _logger.info(
            "Time adjusted by $timeAdjustment minutes for Order ID: ${order.id}");
      },
    );
  }

  Widget _ordersListView(String status, Stream stream) {
    return OrdersListView(
      status: status,
      updateState: (fn) => setState(fn),
      logger: _logger,
      stream: stream,
      adjustTimeDialogBuilder: _adjustTimeDialogBuilder,
      flashingControllers: _flashingControllers,
      stopFlashingCallback: stopFlashingForOrder,
      stopSoundCallback: stopAlertSoundForOrder,
      supabaseUpdateCallback: updateOrderStatusInSupabase,
      supabaseAdjustTimeCallback: adjustOrderTimingInSupabase,
      supabaseCancelCallback: cancelOrderInSupabase,
    );
  }

  @override
  void dispose() {
    for (var controller in _flashingControllers.values) {
      controller.dispose();
    }
    supabase.removeChannel(_subscription);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      _buildTopBar(),
      Expanded(
        child: Row(children: [
          CustomSidebar(
              isExpanded: isSidebarExpanded,
              isTakingOrders: widget.isTakingCashOrders,
              isTakingCashOrders: widget.isTakingCashOrders,
              toggleSidebar: _toggleSidebar,
              onOptionSelected: widget.onSidebarOptionSelected,
              onToggleChanged: widget.onToggleChanged,
              onToggleCashChanged: widget.onToggleCashChanged),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (isSidebarExpanded) {
                  _toggleSidebar();
                }
              },
              behavior: HitTestBehavior.opaque,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ordersListView('Preparing', streamPreparingOrders()),
                  _ordersListView('EnRoute', streamEnRouteOrders()),
                ],
              ),
            ),
          ),
        ]),
      )
    ]));
  }
}
