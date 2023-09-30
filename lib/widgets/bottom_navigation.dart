import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newsdroid/telas/config/config.dart';
import 'package:newsdroid/telas/favoritos/favoritos.dart';
import 'package:newsdroid/telas/home/home.dart';

class BottomNavigationContainer extends StatefulWidget {
  const BottomNavigationContainer({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BottomNavigationContainerState createState() =>
      _BottomNavigationContainerState();
}

class _BottomNavigationContainerState extends State<BottomNavigationContainer> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    Home(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  // Metodo da button nav
  void onTabTapped(int index) {
    if (currentIndex == index) return;

    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      // Bottom Nav
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            shadowColor: Colors.blue,
            labelTextStyle: MaterialStateProperty.all(
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ),
          child: NavigationBar(
            onDestinationSelected: onTabTapped,
            selectedIndex: currentIndex,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(CupertinoIcons.house),
                selectedIcon: Icon(CupertinoIcons.house_fill),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(CupertinoIcons.heart),
                selectedIcon: Icon(CupertinoIcons.heart_fill),
                label: 'Favoritos',
              ),
              NavigationDestination(
                icon: Icon(CupertinoIcons.settings),
                selectedIcon: Icon(CupertinoIcons.settings_solid),
                label: 'Ajustes',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
