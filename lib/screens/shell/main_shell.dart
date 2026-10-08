import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../state/navigation_provider.dart';
import '../home/home_screen.dart';
import '../profile/medical_profile_screen.dart';
import '../restaurants/restaurants_screen.dart';
import '../ticket/ticket_screen.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          HomeScreen(),
          RestaurantsScreen(),
          TicketScreen(),
          MedicalProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: ref.read(navIndexProvider.notifier).select,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primaryTint,
        destinations: const [
          NavigationDestination(
            icon: Icon(CupertinoIcons.house),
            selectedIcon:
                Icon(CupertinoIcons.house_fill, color: AppColors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.search),
            selectedIcon: Icon(CupertinoIcons.search, color: AppColors.primary),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.doc_text),
            selectedIcon:
                Icon(CupertinoIcons.doc_text_fill, color: AppColors.primary),
            label: 'Ticket',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.person_crop_circle),
            selectedIcon: Icon(CupertinoIcons.person_crop_circle_fill,
                color: AppColors.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}