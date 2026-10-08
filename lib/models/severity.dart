enum Severity {
  anaphylactic('anaphylactic', 'Anaphylactic',
      'Life-threatening reaction. The kitchen must avoid all contact.'),
  severe('severe', 'Severe intolerance',
      'Serious illness or pain. Avoid cross-contact.'),
  preference('preference', 'Preference',
      'Avoid where possible. Not a medical requirement.');

  const Severity(this.value, this.label, this.description);

  final String value;
  final String label;
  final String description;

  static Severity fromValue(String v) => Severity.values.firstWhere(
        (s) => s.value == v,
        orElse: () => Severity.preference,
      );
}