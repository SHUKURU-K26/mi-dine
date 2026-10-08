import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../widgets/empty_state.dart';

class RestaurantsScreen extends StatelessWidget {
  const RestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: const EmptyState(
        icon: CupertinoIcons.search,
        title: 'Restaurants are coming',
        message: 'You will soon browse menus and see which dishes are safe for you.',
      ),
    );
  }
}