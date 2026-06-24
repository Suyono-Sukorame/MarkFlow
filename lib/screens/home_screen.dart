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
          body: Stack(
            children: [
              // Main content
              _buildMainContent(context, provider, activeView),
              
              // Bottom navigation (only show for main views)
              if (!isDocumentView)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomNavigation(context, provider, activeView),
                ),
            ],
          ),
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
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              icon: Icons.home_outlined,
              label: 'Home',
              isActive: activeView == ActiveView.dashboard,
              onTap: () => provider.setActiveView(ActiveView.dashboard),
            ),
            _buildNavItem(
              context,
              icon: Icons.folder_open,
              label: 'Files',
              isActive: activeView == ActiveView.files,
              onTap: () => provider.setActiveView(ActiveView.files),
            ),
            _buildNavItem(
              context,
              icon: Icons.search,
              label: 'Search',
              isActive: activeView == ActiveView.search,
              onTap: () => provider.setActiveView(ActiveView.search),
            ),
            _buildNavItem(
              context,
              icon: Icons.star_outline,
              label: 'Favorites',
              isActive: activeView == ActiveView.favorites,
              onTap: () => provider.setActiveView(ActiveView.favorites),
            ),
            _buildNavItem(
              context,
              icon: Icons.settings_outlined,
              label: 'Settings',
              isActive: activeView == ActiveView.settings,
              onTap: () => provider.setActiveView(ActiveView.settings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? colorScheme.secondaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isActive
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
