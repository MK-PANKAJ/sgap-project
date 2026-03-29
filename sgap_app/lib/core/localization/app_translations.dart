// lib/core/localization/app_translations.dart

const Map<String, Map<String, String>> appTranslations = {
  'हिंदी': {
    'dashboard': 'डैशबोर्ड',
    'loans': 'लोन',
    'schemes': 'योजनाएं',
    'profile': 'प्रोफ़ाइल',
    'trust_score': 'ट्रस्ट स्कोर',
    'income': 'कमाई',
    'expense': 'खर्च',
    'apply_loan': 'लोन के लिए अप्लाई करो',
    'available_offers': 'उपलब्ध ऑफर्स',
    'loan_amount': 'लोन राशि',
    'interest_rate': 'ब्याज दर',
    'tenure': 'अवधि (महीने)',
    'recent_transactions': 'हाल ही के लेन-देन',
    'voice_hint': 'अपनी कमाई या खर्च बोलकर दर्ज करें...',
    'logout': 'लॉग आउट',
  },
  'English': {
    'dashboard': 'Dashboard',
    'loans': 'Loans',
    'schemes': 'Schemes',
    'profile': 'Profile',
    'trust_score': 'Trust Score',
    'income': 'Income',
    'expense': 'Expense',
    'apply_loan': 'Apply for Loan',
    'available_offers': 'Available Offers',
    'loan_amount': 'Loan Amount',
    'interest_rate': 'Interest Rate',
    'tenure': 'Tenure (Months)',
    'recent_transactions': 'Recent Transactions',
    'voice_hint': 'Speak to record your income or expense...',
    'logout': 'Logout',
  }
};

// Ye function kisi bhi word ko translate karega
String tr(String lang, String key) {
  return appTranslations[lang]?[key] ?? key;
}