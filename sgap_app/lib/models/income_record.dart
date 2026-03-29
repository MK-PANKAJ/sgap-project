/// Represents a single income entry logged by a gig worker.
class IncomeRecord {
  final String id;
  final double amount;
  final String source;
  final IncomeType type;
  final DateTime date;
  final bool verified;
  final String? voiceNoteUrl;
  final String? notes;

  const IncomeRecord({
    required this.id,
    required this.amount,
    required this.source,
    required this.type,
    required this.date,
    this.verified = false,
    this.voiceNoteUrl,
    this.notes,
  });

  factory IncomeRecord.fromJson(Map<String, dynamic> json) {
    return IncomeRecord(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      source: json['source'] as String,
      type: IncomeType.fromString(json['type'] as String),
      date: DateTime.parse(json['date'] as String),
      verified: json['verified'] as bool? ?? false,
      voiceNoteUrl: json['voice_note_url'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'source': source,
        'type': type.value,
        'date': date.toIso8601String().split('T').first,
        'verified': verified,
        'voice_note_url': voiceNoteUrl,
        'notes': notes,
      };

  IncomeRecord copyWith({
    double? amount,
    String? source,
    IncomeType? type,
    bool? verified,
    String? voiceNoteUrl,
    String? notes,
  }) {
    return IncomeRecord(
      id: id,
      amount: amount ?? this.amount,
      source: source ?? this.source,
      type: type ?? this.type,
      date: date,
      verified: verified ?? this.verified,
      voiceNoteUrl: voiceNoteUrl ?? this.voiceNoteUrl,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() =>
      'IncomeRecord(id: $id, ₹$amount, $source, ${type.value})';
}

/// Types of income a gig worker can log.
enum IncomeType {
  wage('wage'),
  overtime('overtime'),
  contract('contract'),
  tip('tip'),
  bonus('bonus'),
  other('other');

  final String value;
  const IncomeType(this.value);

  static IncomeType fromString(String val) {
    return IncomeType.values.firstWhere(
      (e) => e.value == val,
      orElse: () => IncomeType.other,
    );
  }
}
