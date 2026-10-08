import 'severity.dart';

class TicketSection {
  const TicketSection({
    required this.severity,
    required this.heading,
    required this.allergens,
    required this.summary,
    required this.lines,
  });

  final Severity severity;
  final String heading;
  final List<String> allergens;

  /// The allergen names joined into one line.
  final String summary;
  final List<String> lines;
}

class KitchenTicket {
  const KitchenTicket({
    required this.language,
    required this.guestName,
    required this.title,
    required this.intro,
    required this.sections,
    required this.closing,
    required this.footer,
  });

  final String language;
  final String guestName;
  final String title;
  final String intro;
  final List<TicketSection> sections;
  final String closing;
  final String footer;

  /// Text version used for copy and share.
  String toPlainText() {
    final b = StringBuffer()..writeln(title);
    if (guestName.isNotEmpty) b.writeln(guestName);
    b
      ..writeln()
      ..writeln(intro);
    for (final s in sections) {
      b
        ..writeln()
        ..writeln(s.heading)
        ..writeln(s.summary);
      for (final line in s.lines) {
        b.writeln('- $line');
      }
    }
    b
      ..writeln()
      ..writeln(closing)
      ..writeln()
      ..writeln(footer);
    return b.toString().trim();
  }
}