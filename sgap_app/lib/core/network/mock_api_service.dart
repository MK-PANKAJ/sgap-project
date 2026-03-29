import 'api_client.dart';

/// ┌──────────────────────────────────────────────────────────────┐
/// │  MOCK MODE SWITCH                                            │
/// │  Set to `false` when the real backend is ready.              │
/// └──────────────────────────────────────────────────────────────┘
// ignore: constant_identifier_names
const bool USE_MOCK = false;

/// Unified API service that fronts both mock data and the real backend.
///
/// When [USE_MOCK] is `true`, every method returns realistic dummy data
/// after a 500 ms artificial delay — perfect for UI development and demos.
///
/// When [USE_MOCK] is `false`, the same methods call the real [ApiClient].
class MockApiService {
  MockApiService._();
  static final MockApiService instance = MockApiService._();

  final ApiClient _api = ApiClient.instance;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  AUTH
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Request OTP for the given phone number.
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    if (USE_MOCK) {
      await _mockDelay();
      return {
        'message': 'OTP sent',
        'demo_otp': '123456',
      };
    }
    final res = await _api.post('auth/send-otp', data: {'phone': phone});
    return res.data as Map<String, dynamic>;
  }

  /// Verify OTP and receive a JWT + user object.
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    if (USE_MOCK) {
      await _mockDelay();
      if (otp != '123456') {
        return {'success': false, 'message': 'गलत OTP। कृपया पुनः प्रयास करें।'};
      }
      return {
        'token': 'mock-jwt-token',
        'is_new_user': false,
        'user': _mockWorkerProfile(),
      };
    }
    final res = await _api.post(
      'auth/verify-otp',
      data: {'phone': phone, 'otp': otp},
    );
    return res.data as Map<String, dynamic>;
  }

  /// Register a new worker with full profile data.
  Future<Map<String, dynamic>> registerWorker(
      Map<String, dynamic> data) async {
    if (USE_MOCK) {
      await _mockDelay();
      return {
        'id': 'worker-001',
        'name': data['name'] ?? 'रमेश कुमार',
        'phone': data['phone'] ?? '+919876543210',
        'trust_score': 300,
        'occupation': data['occupation'] ?? 'Construction',
        'city': data['city'] ?? 'Delhi',
        'language': data['language'] ?? 'hi',
        'aadhaar_verified': false,
        'created_at': DateTime.now().toIso8601String(),
      };
    }
    final res = await _api.post('workers/register', data: data);
    return res.data as Map<String, dynamic>;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  WORKER PROFILE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Fetch the logged-in worker's profile.
  Future<Map<String, dynamic>> getMe() async {
    if (USE_MOCK) {
      await _mockDelay();
      return _mockWorkerProfile();
    }
    final res = await _api.get('workers/me');
    return res.data as Map<String, dynamic>;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  INCOME
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Monthly income summary for a worker.
  Future<Map<String, dynamic>> getMonthlyIncome(String workerId) async {
    if (USE_MOCK) {
      await _mockDelay();
      return {
        'total_earned': 28400,
        'verified_amount': 24200,
        'pending_amount': 4200,
        'total_entries': 18,
        'verified_entries': 14,
        'month': 'March 2026',
        'daily_average': 948,
        'comparison_last_month': '+12%',
      };
    }
    final res = await _api.get('income/monthly-summary/$workerId');
    return res.data as Map<String, dynamic>;
  }

  /// Process a voice log and extract structured income data.
  Future<Map<String, dynamic>> processVoiceLog(
    String audioPath,
    String lang,
  ) async {
    if (USE_MOCK) {
      await _mockDelay();
      return {
        'success': true,
        'text': 'आज सुरेश भाई से आठ सौ रुपये मिले',
        'amount': 800,
        'employer_name': 'Suresh',
        'work_type': 'Construction',
        'date': DateTime.now().toIso8601String().split('T').first,
        'confidence': 0.92,
        'language_detected': 'hi',
      };
    }
    // Real implementation would use multipart/form-data
    final res = await _api.post(
      'income/voice-process',
      data: {'audio_path': audioPath, 'language': lang},
    );
    return res.data as Map<String, dynamic>;
  }

  /// Confirm a parsed voice entry and create an income record.
  Future<Map<String, dynamic>> confirmEntry(
      Map<String, dynamic> data) async {
    if (USE_MOCK) {
      await _mockDelay();
      return {
        'id': 'record-001',
        'status': 'pending',
        'record_hash': 'sha256${DateTime.now().millisecondsSinceEpoch}',
        'amount': data['amount'] ?? 800,
        'employer_name': data['employer_name'] ?? 'Suresh',
        'work_type': data['work_type'] ?? 'Construction',
        'date': data['date'] ?? DateTime.now().toIso8601String().split('T').first,
        'created_at': DateTime.now().toIso8601String(),
      };
    }
    final res = await _api.post('income/confirm', data: data);
    return res.data as Map<String, dynamic>;
  }

  /// List all income records for a worker.
  Future<Map<String, dynamic>> getIncomeRecords(String workerId) async {
    if (USE_MOCK) {
      await _mockDelay();
      return {
        'records': _mockIncomeRecords(),
        'total_count': 10,
        'page': 1,
      };
    }
    final res = await _api.get('income/worker/$workerId');
    return res.data as Map<String, dynamic>;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  TRUST / CREDIT SCORE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Fetch the S-GAP Trust Score for a worker.
  Future<Map<String, dynamic>> getTrustScore(String workerId) async {
    if (USE_MOCK) {
      await _mockDelay();
      return {
        'score': 720,
        'max_score': 900,
        'band': 'good',
        'band_hindi': 'अच्छा है ⭐⭐',
        'factors': {
          'income_consistency': {'score': 82, 'label': 'आय नियमितता'},
          'employer_verification': {'score': 75, 'label': 'नियोक्ता सत्यापन'},
          'repayment_history': {'score': 90, 'label': 'भुगतान इतिहास'},
          'identity_strength': {'score': 88, 'label': 'पहचान मज़बूती'},
          'community_trust': {'score': 65, 'label': 'समुदाय विश्वास'},
        },
        'tips': [
          'अपनी आय रोज़ रिकॉर्ड करें — स्कोर 50 अंक बढ़ सकता है',
          'नियोक्ता से सत्यापन करवाएँ — 30 अंक मिलेंगे',
          'e-Shram कार्ड लिंक करें — 20 अंक और बढ़ेंगे',
        ],
        'last_updated': DateTime.now().toIso8601String(),
        'trend': 'improving',
      };
    }
    final res = await _api.get('trust-score/$workerId');
    return res.data as Map<String, dynamic>;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  LOANS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Check whether a worker is eligible for a loan.
  Future<Map<String, dynamic>> getLoanEligibility(String workerId) async {
    if (USE_MOCK) {
      await _mockDelay();
      return {
        'is_eligible': true,
        'max_loan_amount': 100000,
        'min_loan_amount': 5000,
        'max_tenure_months': 24,
        'interest_rate_range': '10% - 18%',
        'reason_hindi': 'आपका ट्रस्ट स्कोर अच्छा है। आप लोन के लिए पात्र हैं।',
        'documents_required': ['Aadhaar', 'PAN (optional)', 'Bank Statement'],
      };
    }
    final res = await _api.get('loans/check-eligibility/$workerId');
    return res.data as Map<String, dynamic>;
  }

  /// Submit a loan application and receive offers.
  Future<Map<String, dynamic>> applyLoan(Map<String, dynamic> data) async {
    if (USE_MOCK) {
      await _mockDelay();
      return {
        'application_id': 'app-001',
        'status': 'offers_available',
        'offers': [
          {
            'id': 'offer-001',
            'lender': 'MicroFin Bank',
            'lender_logo': null,
            'amount': data['amount'] ?? 50000,
            'interest_rate': 12.5,
            'tenure_months': 12,
            'emi': 4440,
            'processing_fee': 500,
            'approval_time': '24 घंटे',
            'type': 'personal',
          },
          {
            'id': 'offer-002',
            'lender': 'QuickCash NBFC',
            'lender_logo': null,
            'amount': data['amount'] ?? 50000,
            'interest_rate': 14.0,
            'tenure_months': 6,
            'emi': 8700,
            'processing_fee': 300,
            'approval_time': '2 घंटे',
            'type': 'emergency',
          },
          {
            'id': 'offer-003',
            'lender': 'Grameen Finance',
            'lender_logo': null,
            'amount': data['amount'] ?? 50000,
            'interest_rate': 10.0,
            'tenure_months': 24,
            'emi': 2320,
            'processing_fee': 750,
            'approval_time': '3 दिन',
            'type': 'business',
          },
        ],
      };
    }
    final res = await _api.post('loans/apply', data: data);
    return res.data as Map<String, dynamic>;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  GOVERNMENT SCHEMES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Fetch available government welfare schemes.
  Future<Map<String, dynamic>> getSchemes() async {
    if (USE_MOCK) {
      await _mockDelay();
      return {
        'schemes': [
          {
            'id': 'scheme-001',
            'name': 'PM-SYM (प्रधानमंत्री श्रम योगी मानधन)',
            'description':
                '18-40 वर्ष के असंगठित श्रमिकों के लिए पेंशन योजना। ₹15,000/माह से कम आय वालों के लिए।',
            'benefit': '60 वर्ष के बाद ₹3,000/माह पेंशन',
            'eligibility': 'eligible',
            'applied': false,
            'category': 'pension',
            'link': 'https://maandhan.in/',
          },
          {
            'id': 'scheme-002',
            'name': 'PMJJBY (प्रधानमंत्री जीवन ज्योति बीमा)',
            'description': '₹436/वर्ष प्रीमियम पर ₹2 लाख का जीवन बीमा कवर।',
            'benefit': '₹2,00,000 जीवन बीमा',
            'eligibility': 'eligible',
            'applied': true,
            'category': 'insurance',
            'link': 'https://jansuraksha.gov.in/',
          },
          {
            'id': 'scheme-003',
            'name': 'e-Shram Card (ई-श्रम कार्ड)',
            'description':
                'असंगठित श्रमिकों का राष्ट्रीय पोर्टल। ₹2 लाख दुर्घटना बीमा कवर।',
            'benefit': '₹2,00,000 दुर्घटना बीमा + पहचान पत्र',
            'eligibility': 'eligible',
            'applied': true,
            'category': 'identity',
            'link': 'https://eshram.gov.in/',
          },
          {
            'id': 'scheme-004',
            'name': 'PMSBY (प्रधानमंत्री सुरक्षा बीमा)',
            'description': '₹20/वर्ष प्रीमियम पर ₹2 लाख दुर्घटना बीमा।',
            'benefit': '₹2,00,000 दुर्घटना बीमा',
            'eligibility': 'eligible',
            'applied': false,
            'category': 'insurance',
            'link': 'https://jansuraksha.gov.in/',
          },
          {
            'id': 'scheme-005',
            'name': 'आयुष्मान भारत (PM-JAY)',
            'description':
                'गरीब और कमजोर परिवारों को ₹5 लाख/वर्ष स्वास्थ्य बीमा।',
            'benefit': '₹5,00,000/वर्ष स्वास्थ्य कवर',
            'eligibility': 'check_required',
            'applied': false,
            'category': 'health',
            'link': 'https://pmjay.gov.in/',
          },
          {
            'id': 'scheme-006',
            'name': 'PM Awas Yojana (प्रधानमंत्री आवास योजना)',
            'description':
                'शहरी गरीबों को किफ़ायती आवास। ₹2.67 लाख तक सब्सिडी।',
            'benefit': '₹2,67,000 तक ब्याज सब्सिडी',
            'eligibility': 'check_required',
            'applied': false,
            'category': 'housing',
            'link': 'https://pmaymis.gov.in/',
          },
        ],
      };
    }
    final res = await _api.get('schemes');
    return res.data as Map<String, dynamic>;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  INSURANCE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Fetch available insurance plans.
  Future<Map<String, dynamic>> getInsurance() async {
    if (USE_MOCK) {
      await _mockDelay();
      return {
        'plans': [
          {
            'id': 'ins-001',
            'name': 'S-GAP सुरक्षा कवच',
            'type': 'accident',
            'premium_monthly': 49,
            'cover_amount': 200000,
            'cover_hindi': '₹2,00,000 दुर्घटना कवर',
            'features': [
              'दुर्घटना मृत्यु — ₹2,00,000',
              'स्थायी विकलांगता — ₹1,00,000',
              'अस्पताल भत्ता — ₹500/दिन (30 दिन तक)',
            ],
            'popular': true,
          },
          {
            'id': 'ins-002',
            'name': 'S-GAP स्वास्थ्य बेसिक',
            'type': 'health',
            'premium_monthly': 149,
            'cover_amount': 100000,
            'cover_hindi': '₹1,00,000 स्वास्थ्य कवर',
            'features': [
              'अस्पताल में भर्ती — ₹1,00,000 तक',
              'OPD कवर — ₹5,000/वर्ष',
              'दवाई खर्च — ₹3,000/वर्ष',
            ],
            'popular': false,
          },
          {
            'id': 'ins-003',
            'name': 'S-GAP परिवार रक्षक',
            'type': 'life',
            'premium_monthly': 199,
            'cover_amount': 500000,
            'cover_hindi': '₹5,00,000 जीवन बीमा',
            'features': [
              'मृत्यु लाभ — ₹5,00,000',
              'गंभीर बीमारी — ₹2,50,000',
              'बच्चों की शिक्षा — ₹50,000 (एकमुश्त)',
            ],
            'popular': false,
          },
        ],
      };
    }
    final res = await _api.get('insurance/plans');
    return res.data as Map<String, dynamic>;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  PRIVATE MOCK DATA BUILDERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// 500 ms artificial delay to simulate network latency.
  Future<void> _mockDelay() =>
      Future.delayed(const Duration(milliseconds: 500));

  /// Full mock worker profile.
  Map<String, dynamic> _mockWorkerProfile() => {
        'id': 'worker-001',
        'name': 'रमेश कुमार',
        'phone': '+919876543210',
        'language': 'hi',
        'occupation': 'Construction Worker',
        'city': 'Delhi',
        'trust_score': 720,
        'aadhaar_verified': true,
        'e_shram_linked': true,
        'avatar_url': null,
        'total_income_logged': 284000,
        'member_since': '2025-06-15',
        'created_at': '2025-06-15T10:30:00Z',
      };

  /// 10 realistic mock income records.
  List<Map<String, dynamic>> _mockIncomeRecords() => [
        {
          'id': 'rec-001',
          'amount': 800,
          'employer_name': 'Suresh Sharma',
          'work_type': 'Construction',
          'date': '2026-03-27',
          'status': 'verified',
          'verified_by': 'employer',
          'source': 'voice',
        },
        {
          'id': 'rec-002',
          'amount': 1200,
          'employer_name': 'Rakesh Builders',
          'work_type': 'Painting',
          'date': '2026-03-26',
          'status': 'verified',
          'verified_by': 'employer',
          'source': 'voice',
        },
        {
          'id': 'rec-003',
          'amount': 650,
          'employer_name': 'Anita Devi',
          'work_type': 'Plumbing',
          'date': '2026-03-25',
          'status': 'pending',
          'verified_by': null,
          'source': 'manual',
        },
        {
          'id': 'rec-004',
          'amount': 1500,
          'employer_name': 'Metro Construction',
          'work_type': 'Construction',
          'date': '2026-03-24',
          'status': 'verified',
          'verified_by': 'employer',
          'source': 'voice',
        },
        {
          'id': 'rec-005',
          'amount': 900,
          'employer_name': 'Pankaj Singh',
          'work_type': 'Electrical',
          'date': '2026-03-23',
          'status': 'verified',
          'verified_by': 'self',
          'source': 'voice',
        },
        {
          'id': 'rec-006',
          'amount': 700,
          'employer_name': 'Village Shop',
          'work_type': 'Labour',
          'date': '2026-03-22',
          'status': 'pending',
          'verified_by': null,
          'source': 'manual',
        },
        {
          'id': 'rec-007',
          'amount': 2000,
          'employer_name': 'Highway Project',
          'work_type': 'Construction',
          'date': '2026-03-21',
          'status': 'verified',
          'verified_by': 'employer',
          'source': 'voice',
        },
        {
          'id': 'rec-008',
          'amount': 550,
          'employer_name': 'Ramesh Gupta',
          'work_type': 'Carpentry',
          'date': '2026-03-20',
          'status': 'verified',
          'verified_by': 'employer',
          'source': 'voice',
        },
        {
          'id': 'rec-009',
          'amount': 1100,
          'employer_name': 'Sharma Contractor',
          'work_type': 'Masonry',
          'date': '2026-03-19',
          'status': 'verified',
          'verified_by': 'employer',
          'source': 'voice',
        },
        {
          'id': 'rec-010',
          'amount': 850,
          'employer_name': 'Pooja Construction',
          'work_type': 'Construction',
          'date': '2026-03-18',
          'status': 'rejected',
          'verified_by': null,
          'source': 'voice',
          'rejection_reason': 'नियोक्ता ने राशि से इनकार किया',
        },
      ];
}