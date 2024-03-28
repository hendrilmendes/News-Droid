import 'package:flutter/material.dart';
import 'package:newsdroid/telas/config/config.dart';
import 'package:newsdroid/telas/favoritos/favoritos.dart';
import 'package:newsdroid/telas/home/home.dart';
import 'package:newsdroid/telas/pesquisa/pesquisa.dart';

class BottomNavigationContainer extends StatefulWidget {
  const BottomNavigationContainer({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BottomNavigationContainerState createState() =>
      _BottomNavigationContainerState();
}

class _BottomNavigationContainerState extends State<BottomNavigationContainer> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    SearchScreen(),
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
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            return Row(
              children: [
                NavigationRail(
                  groupAlignment: 0.0,
                  selectedIndex: currentIndex,
                  onDestinationSelected: onTabTapped,
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      selectedIcon: Icon(Icons.home_outlined),
                      label: Text("Início"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.search),
                      selectedIcon: Icon(Icons.search_outlined),
                      label: Text("Buscar"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      selectedIcon: Icon(Icons.favorite_outline),
                      label: Text("Favoritos"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      selectedIcon: Icon(Icons.settings_outlined),
                      label: Text("Ajustes"),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: screens[currentIndex]),
              ],
            );
          } else {
            return Scaffold(
              body: screens[currentIndex],
              // Bottom Nav
              bottomNavigationBar: NavigationBarTheme(
                data: NavigationBarThemeData(
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
                      icon: Icon(Icons.home),
                      selectedIcon: Icon(Icons.home_outlined),
                      label: "Início",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.search),
                      selectedIcon: Icon(Icons.search_outlined),
                      label: "Buscar",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.favorite),
                      selectedIcon: Icon(Icons.favorite_outline),
                      label: "Favoritos",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings),
                      selectedIcon: Icon(Icons.settings_outlined),
                      label: "Ajustes",
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
