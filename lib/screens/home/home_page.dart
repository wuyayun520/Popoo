import 'package:flutter/material.dart';
import '../modules/inventory_module.dart';
import '../modules/suppliers_module.dart';
import '../modules/orders_module.dart';
import '../modules/profile_module.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const InventoryModule(),
    const SuppliersModule(),
    const OrdersModule(),
    const ProfileModule(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFA68FF4),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/tabnor/arc_1_nor.png',
              width: 30,
              height: 30,
            ),
            activeIcon: Image.asset(
              'assets/images/tabpre/arc_1_pre.png',
              width: 30,
              height: 30,
            ),
            label: 'Popoo',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/tabnor/arc_2_nor.png',
              width: 30,
              height: 30,
            ),
            activeIcon: Image.asset(
              'assets/images/tabpre/arc_2_pre.png',
              width: 30,
              height: 30,
            ),
            label: 'Suppliers',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/tabnor/arc_3_nor.png',
              width: 30,
              height: 30,
            ),
            activeIcon: Image.asset(
              'assets/images/tabpre/arc_3_pre.png',
              width: 30,
              height: 30,
            ),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/tabnor/arc_4_nor.png',
              width: 30,
              height: 30,
            ),
            activeIcon: Image.asset(
              'assets/images/tabpre/arc_4_pre.png',
              width: 30,
              height: 30,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
} 