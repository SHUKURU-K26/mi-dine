import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/error_text.dart';
import '../../repositories/restaurant_repository.dart';
import 'qr_scanner_screen.dart';
import 'restaurant_detail_screen.dart';

/// Opens the scanner, looks the code up, and opens the restaurant.
Future<void> scanAndOpenRestaurant(BuildContext context, WidgetRef ref) async {
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);

  final code = await navigator.push<String>(
    CupertinoPageRoute(
      fullscreenDialog: true,
      builder: (_) => const QrScannerScreen(),
    ),
  );
  if (code == null) return;

  try {
    final restaurant =
        await ref.read(restaurantRepositoryProvider).fetchByQr(code);
    if (restaurant == null) {
      messenger.showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.risky,
        content: Text('No restaurant matches that code'),
      ));
    } else {
      navigator.push(CupertinoPageRoute(
        builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
      ));
    }
  } catch (e) {
    messenger.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.unsafe,
      content: Text(friendlyError(e)),
    ));
  }
}