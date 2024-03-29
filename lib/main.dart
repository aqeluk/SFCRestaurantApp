import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:socket_io_example/pages/adjust_menu.dart';
import 'package:socket_io_example/pages/orders_page.dart';
import 'package:socket_io_example/pages/previous_orders_page.dart';
import 'package:socket_io_example/pages/support_page.dart';
import 'package:socket_io_example/popups/popup_actions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  _setupLogging();
  await Supabase.initialize(
    url: "https://pegxnmkaobidooyzmety.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBlZ3hubWthb2JpZG9veXptZXR5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDY3NDc1NjMsImV4cCI6MjAyMjMyMzU2M30.K9TcOAnpTmBDLZn_QDqPNz_hLDLSaiSmehyrrXC6TLE",
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(
        onSidebarOptionSelected: (option) {},
        onToggleChanged: (value) {},
        onToggleCashChanged: (value) {},
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  final Function(String) onSidebarOptionSelected;
  final Function(bool) onToggleChanged;
  final Function(bool) onToggleCashChanged;

  const MainPage(
      {super.key,
      required this.onSidebarOptionSelected,
      required this.onToggleChanged,
      required this.onToggleCashChanged});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  bool _isTakingOrders = true;
  bool _isTakingCashOrders = true;

  void _toggleTakingOrders(bool isTakingOrders) {
    setState(() {
      _isTakingOrders = isTakingOrders;
    });
  }

  void _toggleTakingCashOrders(bool isTakingCashOrders) {
    setState(() {
      _isTakingCashOrders = isTakingCashOrders;
    });
  }

  void _onSidebarOptionSelected(String title) {
    switch (title) {
      case 'Previous Orders':
        setState(() => _selectedIndex = 1);
        break;
      case 'Take Items Off Menu':
        setState(() => _selectedIndex = 2);
        break;
      case 'Status':
        setState(() => _selectedIndex = 3);
        break;
      case 'Support':
        setState(() => _selectedIndex = 4);
        break;
      case 'Start Taking Orders':
      case 'Stop Taking Orders':
        PopupActions.showPopup(context, title, (confirmedTitle) {
          setState(() {
            _isTakingOrders = !_isTakingOrders;
          });
          PopupActions.handleAction(
              confirmedTitle); // Call API or perform action
        });
        break;
      case 'Start Taking Cash Orders':
      case 'Stop Taking Cash Orders':
      PopupActions.showPopup(context, title, (confirmedTitle) {
          setState(() {
            _isTakingCashOrders = !_isTakingCashOrders;
          });
          PopupActions.handleAction(
              confirmedTitle); // Call API or perform action
        });
        break;
      case 'Refresh':
        PopupActions.showPopup(context, title, PopupActions.handleAction);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      OrdersPage(
          onSidebarOptionSelected: _onSidebarOptionSelected,
          isTakingOrders: _isTakingOrders,
          isTakingCashOrders: _isTakingCashOrders,
          onToggleChanged: _toggleTakingOrders,
          onToggleCashChanged: _toggleTakingCashOrders
          ),
      PreviousOrdersPage(onBack: () {
        setState(() {
          _selectedIndex = 0;
        });
      }),
      AdjustMenuPage(onBack: () {
        setState(() {
          _selectedIndex = 0;
        });
      }),
      SupportPage(onBack: () {
        setState(() {
          _selectedIndex = 0;
        });
      }),
    ];
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
    );
  }
}
