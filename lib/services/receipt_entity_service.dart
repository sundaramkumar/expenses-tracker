import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';

/// Extra date/amount found by ML Kit's on-device entity extraction.
class ReceiptEntities {
  final DateTime? date;
  final double? amount;
  const ReceiptEntities({this.date, this.amount});
}

/// Second opinion on receipt text using Google's on-device language model.
/// Used only to fill gaps the rule-based [ReceiptParser] couldn't read.
/// The model (a few MB) downloads once; after that it works offline.
/// Every failure returns an empty result so scanning never breaks.
class ReceiptEntityService {
  static const _language = EntityExtractorLanguage.english;

  static Future<ReceiptEntities> extract(String text, {bool needDate = true, bool needAmount = true}) async {
    final extractor = EntityExtractor(language: _language);
    try {
      final manager = EntityExtractorModelManager();
      if (!await manager.isModelDownloaded(_language.name)) {
        await manager
            .downloadModel(_language.name, isWifiRequired: false)
            .timeout(const Duration(seconds: 20));
      }

      // Ignore card expiry dates.
      final cleaned = text.split('\n').where((l) => !RegExp(r'exp', caseSensitive: false).hasMatch(l)).join('\n');
      final annotations = await extractor.annotateText(
        cleaned,
        preferredLocale: 'en-IN',
        entityTypesFilter: [
          if (needDate) EntityType.dateTime,
          if (needAmount) EntityType.money,
        ],
      );

      final now = DateTime.now();
      DateTime? date;
      double? amount;
      for (final a in annotations) {
        for (final e in a.entities) {
          if (e is DateTimeEntity && date == null) {
            final d = DateTime.fromMillisecondsSinceEpoch(e.timestamp);
            final local = DateTime(d.year, d.month, d.day);
            final dayPrecise = e.dateTimeGranularity.index >= DateTimeGranularity.day.index;
            if (dayPrecise &&
                local.isAfter(now.subtract(const Duration(days: 365 * 3))) &&
                !local.isAfter(now.add(const Duration(days: 1)))) {
              date = local;
            }
          } else if (e is MoneyEntity) {
            final v = e.integerPart + e.fractionPart / (e.fractionPart >= 10 ? 100 : 10);
            if (v > 0 && (amount == null || v > amount)) amount = v;
          }
        }
      }
      return ReceiptEntities(date: date, amount: amount);
    } catch (_) {
      return const ReceiptEntities();
    } finally {
      await extractor.close();
    }
  }
}
