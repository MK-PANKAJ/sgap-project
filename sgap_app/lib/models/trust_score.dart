/// Represents a worker's composite trust/credit score on S-GAP.
class TrustScore {
  final int score;
  final int maxScore;
  final String grade;
  final TrustFactors factors;
  final DateTime lastUpdated;
  final TrustTrend trend;

  const TrustScore({
    required this.score,
    this.maxScore = 100,
    required this.grade,
    required this.factors,
    required this.lastUpdated,
    required this.trend,
  });

  /// Score as a 0.0–1.0 ratio.
  double get ratio => score / maxScore;

  /// Human-readable trend label.
  String get trendLabel {
    switch (trend) {
      case TrustTrend.improving:
        return '↑ Improving';
      case TrustTrend.stable:
        return '→ Stable';
      case TrustTrend.declining:
        return '↓ Declining';
    }
  }

  factory TrustScore.fromJson(Map<String, dynamic> json) {
    return TrustScore(
      score: json['score'] as int,
      maxScore: json['max_score'] as int? ?? 100,
      grade: json['grade'] as String,
      factors: TrustFactors.fromJson(
          json['factors'] as Map<String, dynamic>),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      trend: TrustTrend.fromString(json['trend'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'score': score,
        'max_score': maxScore,
        'grade': grade,
        'factors': factors.toJson(),
        'last_updated': lastUpdated.toIso8601String(),
        'trend': trend.value,
      };
}

/// Individual factors that contribute to the trust score.
class TrustFactors {
  final int incomeConsistency;
  final int employerVerification;
  final int repaymentHistory;
  final int identityVerification;
  final int communityTrust;

  const TrustFactors({
    required this.incomeConsistency,
    required this.employerVerification,
    required this.repaymentHistory,
    required this.identityVerification,
    required this.communityTrust,
  });

  factory TrustFactors.fromJson(Map<String, dynamic> json) {
    return TrustFactors(
      incomeConsistency: json['income_consistency'] as int,
      employerVerification: json['employer_verification'] as int,
      repaymentHistory: json['repayment_history'] as int,
      identityVerification: json['identity_verification'] as int,
      communityTrust: json['community_trust'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'income_consistency': incomeConsistency,
        'employer_verification': employerVerification,
        'repayment_history': repaymentHistory,
        'identity_verification': identityVerification,
        'community_trust': communityTrust,
      };

  /// Returns factors as a list of (label, value) pairs for UI display.
  List<MapEntry<String, int>> toList() => [
        MapEntry('Income Consistency', incomeConsistency),
        MapEntry('Employer Verification', employerVerification),
        MapEntry('Repayment History', repaymentHistory),
        MapEntry('Identity Verification', identityVerification),
        MapEntry('Community Trust', communityTrust),
      ];
}

enum TrustTrend {
  improving('improving'),
  stable('stable'),
  declining('declining');

  final String value;
  const TrustTrend(this.value);

  static TrustTrend fromString(String val) {
    return TrustTrend.values.firstWhere(
      (e) => e.value == val,
      orElse: () => TrustTrend.stable,
    );
  }
}
