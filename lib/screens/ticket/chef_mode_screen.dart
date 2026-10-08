import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../models/kitchen_ticket.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/kitchen_ticket_view.dart';

/// Full-screen, large-text view to hand to kitchen staff.
class ChefModeScreen extends StatefulWidget {
  const ChefModeScreen({super.key, required this.ticket});

  final KitchenTicket ticket;

  @override
  State<ChefModeScreen> createState() => _ChefModeScreenState();
}

class _ChefModeScreenState extends State<ChefModeScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                16, MediaQuery.paddingOf(context).top + 84, 16, 32),
            child: KitchenTicketView(ticket: widget.ticket, scale: 1.2),
          ),
          Positioned(
            top: 0,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: GlassContainer(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Close',
                        icon: const Icon(CupertinoIcons.xmark,
                            color: AppColors.primaryDark),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Expanded(
                        child: Text('Show this screen to the kitchen',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}