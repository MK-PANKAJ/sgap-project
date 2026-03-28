/// Represents a loan offer or active loan.
class Loan {
  final String id;
  final String lender;
  final double amount;
  final double interestRate;
  final int tenureMonths;
  final double emi;
  final LoanType type;
  final LoanStatus status;
  final String? approvalTime;
  final double? remaining;
  final int? emisPaid;
  final int? totalEmis;
  final DateTime? nextEmiDate;

  const Loan({
    required this.id,
    required this.lender,
    required this.amount,
    required this.interestRate,
    required this.tenureMonths,
    required this.emi,
    required this.type,
    this.status = LoanStatus.offered,
    this.approvalTime,
    this.remaining,
    this.emisPaid,
    this.totalEmis,
    this.nextEmiDate,
  });

  /// Progress ratio for active loans (0.0 – 1.0).
  double get repaymentProgress {
    if (emisPaid == null || totalEmis == null || totalEmis == 0) return 0;
    return emisPaid! / totalEmis!;
  }

  /// Remaining amount or full amount if not yet disbursed.
  double get outstandingAmount => remaining ?? amount;

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'] as String,
      lender: json['lender'] as String,
      amount: (json['amount'] ?? json['principal'] as num).toDouble(),
      interestRate: (json['interest_rate'] as num?)?.toDouble() ?? 0,
      tenureMonths: json['tenure_months'] as int? ?? 0,
      emi: (json['emi'] as num).toDouble(),
      type: LoanType.fromString(json['type'] as String? ?? 'personal'),
      status: LoanStatus.fromString(json['status'] as String? ?? 'offered'),
      approvalTime: json['approval_time'] as String?,
      remaining: (json['remaining'] as num?)?.toDouble(),
      emisPaid: json['emis_paid'] as int?,
      totalEmis: json['total_emis'] as int?,
      nextEmiDate: json['next_emi_date'] != null
          ? DateTime.parse(json['next_emi_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lender': lender,
        'amount': amount,
        'interest_rate': interestRate,
        'tenure_months': tenureMonths,
        'emi': emi,
        'type': type.value,
        'status': status.value,
        'approval_time': approvalTime,
        'remaining': remaining,
        'emis_paid': emisPaid,
        'total_emis': totalEmis,
        'next_emi_date': nextEmiDate?.toIso8601String().split('T').first,
      };

  @override
  String toString() => 'Loan(id: $id, ₹$amount from $lender, ${status.value})';
}

enum LoanType {
  personal('personal'),
  emergency('emergency'),
  business('business'),
  education('education'),
  medical('medical');

  final String value;
  const LoanType(this.value);

  static LoanType fromString(String val) {
    return LoanType.values.firstWhere(
      (e) => e.value == val,
      orElse: () => LoanType.personal,
    );
  }

  String get displayName {
    switch (this) {
      case LoanType.personal:
        return 'Personal Loan';
      case LoanType.emergency:
        return 'Emergency Loan';
      case LoanType.business:
        return 'Business Loan';
      case LoanType.education:
        return 'Education Loan';
      case LoanType.medical:
        return 'Medical Loan';
    }
  }
}

enum LoanStatus {
  offered('offered'),
  applied('applied'),
  approved('approved'),
  active('active'),
  completed('completed'),
  rejected('rejected');

  final String value;
  const LoanStatus(this.value);

  static LoanStatus fromString(String val) {
    return LoanStatus.values.firstWhere(
      (e) => e.value == val,
      orElse: () => LoanStatus.offered,
    );
  }
}
