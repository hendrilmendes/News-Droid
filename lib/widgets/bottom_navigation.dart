import 'package:flutter/material.dart';
import 'package:newsdroid/l10n/app_localizations.dart';
import 'package:newsdroid/screens/favorites/favorites.dart';
import 'package:newsdroid/screens/home/home.dart';
import 'package:newsdroid/screens/search/search.dart';
import 'package:newsdroid/screens/settings/settings.dart';

class BottomNavigationContainer extends StatefulWidget {
  const BottomNavigationContainer({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BottomNavigationContainerState createState() =>
      _BottomNavigationContainerState();
}

class _BottomNavigationContainerState extends State<BottomNavigationContainer> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const HomeScreen(),
    const SearchScreen(),
    const FavoritesScreen(),
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
          Widget currentScreen = screens[currentIndex];
          if (orientation == Orientation.landscape) {
            return Row(
              children: [
                NavigationRail(
                  groupAlignment: 0.0,
                  selectedIndex: currentIndex,
                  indicatorColor:
                      Theme.of(
                        context,
                      ).bottomNavigationBarTheme.selectedItemColor,
                  onDestinationSelected: onTabTapped,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(Icons.home_outlined),
                      label: Text(AppLocalizations.of(context)!.home),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.search_outlined),
                      label: Text(AppLocalizations.of(context)!.search),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.favorite_border_outlined),
                      label: Text(AppLocalizations.of(context)!.favorites),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.settings_outlined),
                      label: Text(AppLocalizations.of(context)!.settings),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: currentScreen,
                  ),
                ),
              ],
            );
          } else {
            return Scaffold(
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: currentScreen,
              ),
              // Bottom Nav
              bottomNavigationBar: NavigationBarTheme(
                data: NavigationBarThemeData(
                  indicatorColor:
                      Theme.of(
                        context,
                      ).bottomNavigationBarTheme.selectedItemColor,
                  backgroundColor:
                      Theme.of(
                        context,
                      ).bottomNavigationBarTheme.backgroundColor,
                  labelTextStyle: WidgetStateProperty.all(
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ),
                child: NavigationBar(
                  onDestinationSelected: onTabTapped,
                  selectedIndex: currentIndex,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.home_outlined),
                      label: AppLocalizations.of(context)!.home,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.search_outlined),
                      label: AppLocalizations.of(context)!.search,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.favorite_border_outlined),
                      label: AppLocalizations.of(context)!.favorites,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.settings_outlined),
                      label: AppLocalizations.of(context)!.settings,
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
