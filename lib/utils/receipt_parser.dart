class ReceiptData {
  final double? amount;
  final DateTime? date;
  final String? merchant;
  final String categoryName;
  final String? subCategoryHint;
  final String? paymentMethod;

  const ReceiptData({
    this.amount,
    this.date,
    this.merchant,
    required this.categoryName,
    this.subCategoryHint,
    this.paymentMethod,
  });
}

/// Extracts expense fields from raw OCR text of a bill/receipt.
class ReceiptParser {
  static final _money = r'(?:rs\.?|inr|₹|\$)?\s*([0-9]{1,3}(?:,[0-9]{2,3})+(?:\.[0-9]{1,2})?|[0-9]+(?:\.[0-9]{1,2})?)';

  // Lines with these words carry the payable total, in priority order.
  static final _totalKeys = [
    RegExp(r'(grand\s*total|net\s*(?:amount|payable|total)|amount\s*(?:payable|due|paid)|total\s*(?:amount|payable|due)|bill\s*amount|balance\s*due)', caseSensitive: false),
    // Card-machine slips: "SALE AMT", "TOTAL AMT", "BASE AMT", "Amount(Rs.)"
    RegExp(r'\b(?:sale|total|base|txn|net)\s*amt\b|\bamount\s*\(\s*rs|\bsale\s*amount', caseSensitive: false),
    RegExp(r'\btotal\b', caseSensitive: false),
  ];
  static final _ignoreTotal = RegExp(r'sub\s*-?\s*total|total\s*(?:qty|quantity|items|savings|discount|gst|tax)|cgst|sgst|igst|vat', caseSensitive: false);

  static ReceiptData parse(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final category = categorize(text);
    return ReceiptData(
      amount: _extractAmount(lines),
      date: _extractDate(text),
      merchant: _extractMerchant(lines),
      categoryName: category.$1,
      subCategoryHint: category.$2,
      paymentMethod: _extractPayment(text),
    );
  }

  static double? _parseNum(String s) => double.tryParse(s.replaceAll(',', ''));

  static List<double> _numbersIn(String line) {
    return RegExp(_money, caseSensitive: false)
        .allMatches(line)
        .map((m) => _parseNum(m.group(1)!))
        .whereType<double>()
        .where((v) => v > 0)
        .toList();
  }

  static double? _extractAmount(List<String> lines) {
    for (final key in _totalKeys) {
      for (var i = lines.length - 1; i >= 0; i--) {
        final line = lines[i];
        if (!key.hasMatch(line) || _ignoreTotal.hasMatch(line)) continue;
        var nums = _numbersIn(line);
        // OCR often puts the value on the next line.
        if (nums.isEmpty && i + 1 < lines.length) nums = _numbersIn(lines[i + 1]);
        if (nums.isNotEmpty) return nums.last;
      }
    }
    // Fallback: largest decimal-looking amount on the receipt.
    double? best;
    for (final line in lines) {
      if (RegExp(r'phone|mob|tel|gstin|invoice|bill\s*no|\bno\b', caseSensitive: false).hasMatch(line)) continue;
      for (final m in RegExp(r'([0-9]{1,3}(?:,[0-9]{2,3})*\.[0-9]{2})').allMatches(line)) {
        final v = _parseNum(m.group(1)!);
        if (v != null && (best == null || v > best)) best = v;
      }
    }
    return best;
  }

  static const _months = {
    'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
    'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
  };

  static DateTime? _extractDate(String text) {
    // Prefer lines labelled "date" (not "exp date"), then fall back to the whole text.
    final labelled = text
        .split('\n')
        .where((l) => RegExp(r'date', caseSensitive: false).hasMatch(l) && !RegExp(r'exp', caseSensitive: false).hasMatch(l))
        .join('\n');
    return _findDate(labelled) ?? _findDate(text) ?? _findShortDate(labelled);
  }

  static DateTime? _findDate(String text) {
    final now = DateTime.now();
    // Receipts are recent; this also rejects version numbers like 1.1.1.
    bool ok(DateTime d) =>
        d.isAfter(now.subtract(const Duration(days: 365 * 3))) &&
        !d.isAfter(now.add(const Duration(days: 1)));

    // 25/12/2024, 25-12-24, 25.12.2024 (day first, as on Indian bills)
    for (final m in RegExp(r'\b(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4}|\d{2})\b').allMatches(text)) {
      final d = int.parse(m.group(1)!), mo = int.parse(m.group(2)!);
      var y = int.parse(m.group(3)!);
      if (y < 100) y += 2000;
      if (mo < 1 || mo > 12 || d < 1 || d > 31) continue;
      final dt = DateTime(y, mo, d);
      if (ok(dt)) return dt;
    }
    // 2024-12-25
    for (final m in RegExp(r'\b(\d{4})[-/](\d{1,2})[-/](\d{1,2})\b').allMatches(text)) {
      final mo = int.parse(m.group(2)!), d = int.parse(m.group(3)!);
      if (mo < 1 || mo > 12 || d < 1 || d > 31) continue;
      final dt = DateTime(int.parse(m.group(1)!), mo, d);
      if (ok(dt)) return dt;
    }
    // 25 Dec 2024, 28 Sept 2026, 25-Dec-24
    for (final m in RegExp(r'\b(\d{1,2})[\s\-]*([A-Za-z]{3})[a-z]*\.?[\s,\-]*(\d{4}|\d{2})\b').allMatches(text)) {
      final mo = _months[m.group(2)!.toLowerCase()];
      if (mo == null) continue;
      var y = int.parse(m.group(3)!);
      if (y < 100) y += 2000;
      final dt = DateTime(y, mo, int.parse(m.group(1)!));
      if (ok(dt)) return dt;
    }
    // Dec 25, 2024
    for (final m in RegExp(r'\b([A-Za-z]{3})[a-z]*\.?\s+(\d{1,2}),?\s+(\d{4})\b').allMatches(text)) {
      final mo = _months[m.group(1)!.toLowerCase()];
      if (mo == null) continue;
      final dt = DateTime(int.parse(m.group(3)!), mo, int.parse(m.group(2)!));
      if (ok(dt)) return dt;
    }
    return null;
  }

  /// Card slips that print only "Date:0917" (MMDD, no year). Assumes the current year.
  static DateTime? _findShortDate(String text) {
    final m = RegExp(r'date\s*:?\s*(\d{2})(\d{2})\b', caseSensitive: false).firstMatch(text);
    if (m == null) return null;
    final now = DateTime.now();
    final a = int.parse(m.group(1)!), b = int.parse(m.group(2)!);
    DateTime? build(int mo, int d) {
      if (mo < 1 || mo > 12 || d < 1 || d > 31) return null;
      var dt = DateTime(now.year, mo, d);
      if (dt.isAfter(now.add(const Duration(days: 1)))) dt = DateTime(now.year - 1, mo, d);
      return dt;
    }
    return build(a, b) ?? build(b, a);
  }

  static String? _extractMerchant(List<String> lines) {
    // Skip receipt titles, contact details, and the card-machine / bank printing the slip.
    final skip = RegExp(
        r'^(tax\s*invoice|retail\s*invoice|invoice|bill|receipt|cash\s*memo|gstin|ph|phone|tel|mob|date|time|www|http|welcome|thank\s*you|duplicate|customer|merchant)'
        r'|bank\b|pine\s*labs|mosambee|plutus|worldline|razorpay|paytm|bharatpe|^[\d\W]+$',
        caseSensitive: false);
    for (final line in lines.take(8)) {
      if (skip.hasMatch(line) || line.length < 3) continue;
      if (RegExp(r'[A-Za-z]{3}').hasMatch(line)) return _titleCase(line);
    }
    return null;
  }

  static String _titleCase(String s) {
    if (s != s.toUpperCase()) return s;
    // Keep short abbreviations (BP, MS, UP) upper-case.
    return s.replaceAllMapped(RegExp(r'[A-Za-z]+'), (m) {
      final w = m.group(0)!;
      return w.length <= 2 ? w : w[0] + w.substring(1).toLowerCase();
    });
  }

  static String? _extractPayment(String text) {
    final t = text.toLowerCase();
    if (RegExp(r'\bupi\b|gpay|google\s*pay|phonepe|paytm|bhim').hasMatch(t)) return 'UPI';
    if (RegExp(r'(?:credit|debit)[\s_]*card|\bcard\s*(?:payment|no|number|type|entry|:)|\bvisa\b|mastercard|rupay|\bchip\b|\bswipe\b|\bpos\b|\bpin\s*verified').hasMatch(t)) return 'Card';
    if (RegExp(r'net\s*banking|\bneft\b|\bimps\b|\brtgs\b').hasMatch(t)) return 'Bank';
    if (RegExp(r'\bcash\b').hasMatch(t)) return 'Cash';
    return null;
  }

  // (category name as seeded in the DB, subcategory keyword)
  static final List<(RegExp, String, String?)> _rules = [
    (RegExp(r'petrol|diesel|\bfuel\b|unleaded|\bhpcl\b|\bbpcl\b|\bb\.?p\.?c\.?l\b|\biocl\b|indian\s*oil|bharat\s*petroleum|hindustan\s*petroleum|\bshell\b|nayara|\bbp\b|nozzle|\bcng\b|rate\s*/\s*ltr|\bltrs?\b|litre'), 'Vehicle', 'petrol'),
    (RegExp(r'pharma|medical|medicine|chemist|apollo|hospital|clinic|doctor|diagnostic|\btablets?\b|\bcapsules?\b|\bsyrup\b'), 'Medical', 'medicine'),
    (RegExp(r'restaurant|\bcafe\b|coffee|\bdine\b|dining|biryani|pizza|burger|\bkfc\b|mcdonald|domino|starbucks|swiggy|zomato|bakery|\bfood\b|\bmeals?\b|thali|dosa|idli|\btea\b|juice|snacks?|\bkot\b|table\s*no|kunafa|halwa|cake|sweets'), 'Food', 'eatout'),
    (RegExp(r'dress|shirt|jeans|trouser|saree|\bsilks?\b|kurta|kurti|textiles?|garments?|apparel|fashion|clothing|clothes|boutique|footwear|\bshoes\b|myntra|ajio|lifestyle|pantaloons|westside|zudio|max\s*fashion|\btrends\b|readymade|\bjewel'), 'PersonalCare', 'clothes'),
    (RegExp(r'\bsalon\b|parlou?r|haircut|\bspa\b|cosmetic|beauty'), 'PersonalCare', 'haircut'),
    (RegExp(r'grocery|supermarket|smart\s*bazaar|\bdmart\b|d-mart|big\s*bazaar|more\s*retail|reliance\s*(?:fresh|smart|retail)|vegetable|provision|kirana|\bmilk\b|\bration\b|\brice\b|\batta\b|\bdal\b|\bsugar\b|hypermarket'), 'HomeExp', 'grocery'),
    (RegExp(r'ectricals?|hardware|plumbing|paint|\bfans?\b|lighting|furniture|appliances?'), 'HomeExp', 'household'),
    (RegExp(r'mobile\s*recharge|recharge|airtel|\bjio\b|vodafone|\bvi\b|bsnl|broadband'), 'Phone', null),
    (RegExp(r'electricity|\beb\b|tneb|bescom|water\s*bill|gas\s*cylinder|\blpg\b'), 'HomeExp', 'eb'),
    (RegExp(r'\bbooks?\b|stationer|notebook|\bschool\b|tuition|\bcourse\b|\bexam\b|college'), 'Education', null),
    (RegExp(r'laptop|computer|smartphone|charger|earphone|headphone|\bcamera\b|electronics|croma|vijay\s*sales'), 'Gadgets', null),
    (RegExp(r'movie|cinema|\bpvr\b|\binox\b|netflix|concert'), 'Entertainment', 'movie'),
    (RegExp(r'\bbus\b|\btrain\b|flight|\bcab\b|taxi|\buber\b|\bola\b|\btoll\b|\bmetro\b|irctc|airline'), 'Travel', null),
    (RegExp(r'\bgifts?\b|donation|charity|temple'), 'Gifts', null),
  ];

  /// Returns (categoryName, subCategoryKeyword). Falls back to Misc.
  static (String, String?) categorize(String text) {
    final t = text.toLowerCase();
    final lines = t.split('\n');
    // Weight the header (merchant name) more than line items.
    final header = lines.take(7).join(' ');
    for (final r in _rules) {
      if (r.$1.hasMatch(header)) return (r.$2, r.$3);
    }
    final scores = <int, int>{};
    for (var i = 0; i < _rules.length; i++) {
      final c = _rules[i].$1.allMatches(t).length;
      if (c > 0) scores[i] = c;
    }
    if (scores.isEmpty) return ('Misc', null);
    final best = scores.entries.reduce((a, b) => b.value > a.value ? b : a).key;
    return (_rules[best].$2, _rules[best].$3);
  }
}
