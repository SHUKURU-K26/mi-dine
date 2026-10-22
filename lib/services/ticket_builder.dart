import '../core/constants/ticket_templates.dart';
import '../models/kitchen_ticket.dart';
import '../models/severity.dart';
import '../models/user_allergen.dart';

class TicketBuilder {
  const TicketBuilder();

  KitchenTicket build({
    required List<UserAllergen> allergens,
    required String languageCode,
    required String guestName,
    String note = '',
  }) {
    final copy = TicketTemplates.copyOf(languageCode);
    final sorted = [...allergens]
      ..sort((a, b) => a.allergen.id.compareTo(b.allergen.id));

    final sections = <TicketSection>[];
    for (final severity in Severity.values) {
      final names = sorted
          .where((u) => u.severity == severity)
          .map((u) => copy.allergens[u.allergen.name] ?? u.allergen.name)
          .toList();
      if (names.isEmpty) continue;

      final summary = names.join(copy.listSeparator);
      final heading = switch (severity) {
        Severity.anaphylactic => copy.anaphylacticHeading,
        Severity.severe => copy.severeHeading,
        Severity.preference => copy.preferenceHeading,
      };
      final templates = switch (severity) {
        Severity.anaphylactic => copy.anaphylacticLines,
        Severity.severe => copy.severeLines,
        Severity.preference => copy.preferenceLines,
      };

      sections.add(TicketSection(
        severity: severity,
        heading: heading,
        allergens: names,
        summary: summary,
        lines: [for (final t in templates) t.replaceAll('{x}', summary)],
      ));
    }

    return KitchenTicket(
      language: languageCode,
      guestName: guestName,
      title: copy.title,
      intro: copy.intro,
      sections: sections,
      closing: copy.closing,
      footer: copy.footer,
      note: note.trim(),
      noteHeading: TicketTemplates.noteHeading(languageCode),
    );
  }
}