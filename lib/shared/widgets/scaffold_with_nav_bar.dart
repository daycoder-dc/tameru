import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: Icon(PhosphorIconsLight.house),
            selectedIcon: Icon(PhosphorIconsFill.house,
                color: isDark ? Colors.white : Colors.white),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsLight.receipt),
            selectedIcon: Icon(PhosphorIconsFill.receipt,
                color: isDark ? Colors.white : Colors.white),
            label: 'Gastos',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsLight.clipboardText),
            selectedIcon: Icon(PhosphorIconsFill.clipboardText,
                color: isDark ? Colors.white : Colors.white),
            label: 'Fijos',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsLight.creditCard),
            selectedIcon: Icon(PhosphorIconsFill.creditCard,
                color: isDark ? Colors.white : Colors.white),
            label: 'Creditos',
          ),
        ],
      ),
    );
  }
}
