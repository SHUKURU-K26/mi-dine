import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/constants/ticket_templates.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/severity_style.dart';
import '../models/kitchen_ticket.dart';

class KitchenTicketView extends StatelessWidget {
  const KitchenTicketView({super.key, required this.ticket, this.scale = 1});

  final KitchenTicket ticket;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final rtl = TicketTemplates.languageOf(ticket.language).rtl;

    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryTint, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(ticket: ticket, scale: scale),
            Padding(
              padding: EdgeInsets.all(20 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ticket.intro,
                      style: TextStyle(
                          fontSize: 14 * scale,
                          height: 1.5,
                          color: AppColors.text)),
                  for (final section in ticket.sections) ...[
                    SizedBox(height: 22 * scale),
                    _SectionView(section: section, scale: scale),
                  ],
                   if (ticket.note.isNotEmpty) ...[
                    SizedBox(height: 22 * scale),
                    _NoteView(
                        heading: ticket.noteHeading,
                        note: ticket.note,
                        scale: scale),
                  ],
                  SizedBox(height: 24 * scale),
                  Divider(color: AppColors.primaryTint, thickness: 1.5),
                  SizedBox(height: 12 * scale),
                  Text(ticket.closing,
                      style: TextStyle(
                          fontSize: 14 * scale,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text)),
                  SizedBox(height: 12 * scale),
                  Text(ticket.footer,
                      style: TextStyle(
                          fontSize: 11 * scale,
                          height: 1.4,
                          color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.ticket, required this.scale});

  final KitchenTicket ticket;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: EdgeInsets.all(20 * scale),
      child: Row(
        children: [
          Icon(CupertinoIcons.shield_lefthalf_fill,
              color: Colors.white, size: 30 * scale),
          SizedBox(width: 14 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticket.title,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        fontSize: 16 * scale)),
                if (ticket.guestName.isNotEmpty) ...[
                  SizedBox(height: 4 * scale),
                  Text(ticket.guestName,
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13 * scale)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionView extends StatelessWidget {
  const _SectionView({required this.section, required this.scale});

  final TicketSection section;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final color = section.severity.color;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(section.severity.icon, color: color, size: 20 * scale),
              SizedBox(width: 8 * scale),
              Expanded(
                child: Text(section.heading,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 13 * scale,
                        height: 1.3)),
              ),
            ],
          ),
          SizedBox(height: 10 * scale),
          Text(section.summary,
              style: TextStyle(
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: AppColors.text)),
          SizedBox(height: 12 * scale),
          for (final line in section.lines)
            Padding(
              padding: EdgeInsets.only(bottom: 8 * scale),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 7 * scale),
                    child: Container(
                      width: 6 * scale,
                      height: 6 * scale,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                  ),
                  SizedBox(width: 10 * scale),
                  Expanded(
                    child: Text(line,
                        style: TextStyle(
                            fontSize: 14 * scale,
                            height: 1.5,
                            color: AppColors.text)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NoteView extends StatelessWidget {
  const _NoteView({
    required this.heading,
    required this.note,
    required this.scale,
  });

  final String heading;
  final String note;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading,
              style: TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 12 * scale)),
          SizedBox(height: 8 * scale),
          Text(note,
              style: TextStyle(
                  fontSize: 16 * scale,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text)),
        ],
      ),
    );
  }
}