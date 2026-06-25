import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'dashboard_screen.dart';
import 'file_explorer_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import 'reader_screen.dart';
import 'editor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final activeView = provider.activeView;
        final isDocumentView = activeView == ActiveView.reader || activeView == ActiveView.editor;

        return Scaffold(
          body: _buildMainContent(context, provider, activeView),
          bottomNavigationBar: !isDocumentView 
              ? _buildBottomNavigation(context, provider, activeView)
              : null,
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context, AppProvider provider, ActiveView activeView) {
    switch (activeView) {
      case ActiveView.dashboard:
        return const DashboardScreen();
      case ActiveView.files:
        return const FileExplorerScreen();
      case ActiveView.search:
        return const SearchScreen();
      case ActiveView.favorites:
        return const FavoritesScreen();
      case ActiveView.settings:
        return const SettingsScreen();
      case ActiveView.reader:
        return const ReaderScreen();
      case ActiveView.editor:
        return const EditorScreen();
    }
  }

  Widget _buildBottomNavigation(BuildContext context, AppProvider provider, ActiveView activeView) {
    // Map ActiveView to index
    int selectedIndex = 0;
    switch (activeView) {
      case ActiveView.dashboard:
        selectedIndex = 0;
        break;
      case ActiveView.files:
        selectedIndex = 1;
        break;
      case ActiveView.search:
        selectedIndex = 2;
        break;
      case ActiveView.favorites:
        selectedIndex = 3;
        break;
      case ActiveView.settings:
        selectedIndex = 4;
        break;
      default:
        selectedIndex = 0;
    }

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            provider.setActiveView(ActiveView.dashboard);
            break;
          case 1:
            provider.setActiveView(ActiveView.files);
            break;
          case 2:
            provider.setActiveView(ActiveView.search);
            break;
          case 3:
            provider.setActiveView(ActiveView.favorites);
            break;
          case 4:
            provider.setActiveView(ActiveView.settings);
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder),
          label: 'Files',
        ),
        NavigationDestination(
          icon: Icon(Icons.search),
          selectedIcon: Icon(Icons.search),
          label: 'Search',
        ),
        NavigationDestination(
          icon: Icon(Icons.star_outline),
          selectedIcon: Icon(Icons.star),
          label: 'Favorites',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
