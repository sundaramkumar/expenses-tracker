import 'package:expenses_tracker/utils/receipt_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  taxTests();
  merchantGuardTests();
  realMlKitTests();
  missingTotalTests();
  test('Smart Bazaar HDFC card slip (no year, no "total" word)', () {
    final r = ReceiptParser.parse('''
HDFC Bank
Reliance Retail Limited
SMART BAZAAR
RRL GF FF SF
IS Towers No 1/1765 1/1765A and 1/1765B
Kadhakinaru Main Road Madhurai
Madurai , Tamil Nadu - 625107
Store contact no.1800 891 0001
GSTIN:-33AABCR1718E1ZW
Website:www.relianceretail.com
Date:0917 Time:185130
MID: TID:26194164
BATCH NUM:0 INV NUM:003375
SALE
SWIPE
EXP DATE: CARD:CREDIT_CARD
APPR CODE:070262 RRN:00000003375
TOTAL AMT:1325.71
SIGN:
I AGREE TO PAY AS PER CARD ISSUER AGRMNT''');
    expect(r.amount, 1325.71);
    expect(r.date!.month, 9);
    expect(r.date!.day, 17);
    expect(r.merchant, 'Reliance Retail Limited');
    expect(r.categoryName, 'HomeExp');
    expect(r.subCategoryHint, 'grocery');
    expect(r.paymentMethod, 'Card');
  });

  test('RMKV Silks HDFC slip', () {
    final r = ReceiptParser.parse('''
HDFC BANK
RMKV SILKS PRIVATE LTD
RMKV SILKSP LTD MENS SECTION 1 T
OWN BRANCH PATTUSOLAI SECTION TO
WN BRANCH 176F TRIVANDRUM ROAD 6
27003
DATE: 12-09-2026
TIME: 15:54:55
Card No.: XXXXXXXXXXX5745
Card Type: VISA
Exp Date: **/**
RRN: 000000006152
V-1.1.1.145
SALE AMT INR 9380.00
PIN VERIFIED OK''');
    expect(r.amount, 9380.0);
    expect(r.date, DateTime(2026, 9, 12));
    expect(r.merchant, 'Rmkv Silks Private Ltd');
    expect(r.categoryName, 'PersonalCare');
    expect(r.subCategoryHint, 'clothes');
    expect(r.paymentMethod, 'Card');
  });

  test('ICICI slip, electricals shop', () {
    final r = ReceiptParser.parse('''
ICICI Bank
M S RAJESI I LECTRICALS
52-C/48 Raja Building Madurai
Road Tirunelveli Tirunelveli
Tamil Nadu 627001
Duplicate Copy
Sale
DATE : 2026-07-17 TIME : 19:53:54
MID : 100000000407409
CARD TYPE : VISA
SALE AMT : INR 3500.00
PIN VERIFIED OK''');
    expect(r.amount, 3500.0);
    expect(r.date, DateTime(2026, 7, 17));
    expect(r.merchant, isNot(contains('Bank')));
    expect(r.categoryName, 'HomeExp');
    expect(r.subCategoryHint, 'household');
    expect(r.paymentMethod, 'Card');
  });

  test('BPCL petrol bill', () {
    final r = ReceiptParser.parse('''
WELCOME TO B.P.C.L
BP-THIRUMANGALAM
Date: 03-10-2026
Time: 08:00:41
Product: EBMS
PayMode: CREDIT CARD
TxSt: 03-10-26 07:58:13
Rate/Ltr.: 108.31
Volume(Ltr.): 33.53
Amount(Rs.): 3631.63
Preset Value: 99.00
VechNo: TN07CJ2247''');
    expect(r.amount, 3631.63);
    expect(r.date, DateTime(2026, 10, 3));
    expect(r.merchant, 'BP-Thirumangalam');
    expect(r.categoryName, 'Vehicle');
    expect(r.subCategoryHint, 'petrol');
    expect(r.paymentMethod, 'Card');
  });

  test('Cafe retail invoice with subtotal and GST', () {
    final r = ReceiptParser.parse('''
RETAIL INVOICE
Thank U Cafe-Surya Nagar
Surya Nagar
A Unit of IAB Solutions Pvt. Ltd.
GSTIN:33AADCI5738H1ZL
Order POS-SNR-20260928-095
Date 28 Sept 2026, 07:34 pm
Type dining
Table No D10
Phone 9999999999
Margheritta Pizza x1 94.29
Peppy Paneer Pizza x1 199.05
Subtotal 607.62
CGST 2.5% 15.19
SGST 2.5% 15.19
TOTAL Rs.638''');
    expect(r.amount, 638.0);
    expect(r.date, DateTime(2026, 9, 28));
    expect(r.merchant, 'Thank U Cafe-Surya Nagar');
    expect(r.categoryName, 'Food');
  });

  test('Pine Labs slip for petrol bunk', () {
    final r = ReceiptParser.parse('''
pine labs
BP THIRUMANGALAM
BP THIRUMANGALAM
THIRUMANGALAM
DATE :2026-10-03 TIME :08:00:32
BATCH NUM : 001232
BILL NUM : 6100306712
SALE
************5745 CHIP
EXP DATE :XX/XX CARD TYPE :VISA
BASE AMT. :RS 3631.63
PIN VERIFIED OK
Plutus v10.1.1 RBL''');
    expect(r.amount, 3631.63);
    expect(r.date, DateTime(2026, 10, 3));
    expect(r.merchant, 'BP Thirumangalam');
    expect(r.categoryName, 'Vehicle');
    expect(r.paymentMethod, 'Card');
  });
}

void taxTests() {
  test('total printed before CGST/SGST, payable after', () {
    final r = ReceiptParser.parse('''
Fresh Mart
Date 05-10-2026
Rice 2 kg 120.00
Oil 1 ltr 180.00
Total 300.00
CGST 2.5% 7.50
SGST 2.5% 7.50
Net Payable 315.00
Cash 500.00
Change 185.00''');
    expect(r.amount, 315.0);
  });

  test('pre-tax total with no total below taxes: taxes are added', () {
    final r = ReceiptParser.parse('''
Hardware Store
Date 05-10-2026
Item A 1000.00
Total 1000.00
CGST 9% 90.00
SGST 9% 90.00''');
    expect(r.amount, 1180.0);
  });

  test('round off after taxes', () {
    final r = ReceiptParser.parse('''
Cafe
Date 05-10-2026
Subtotal 607.62
Total 607.62
CGST 2.5% 15.19
SGST 2.5% 15.19
Round off 0.38
Amount Payable 638.00''');
    expect(r.amount, 638.0);
  });

  test('already tax-inclusive total below taxes is unchanged', () {
    final r = ReceiptParser.parse('''
Cafe
Subtotal 607.62
CGST 2.5% 15.19
SGST 2.5% 15.19
TOTAL Rs.638''');
    expect(r.amount, 638.0);
  });

  test('GST included in total is not added again', () {
    final r = ReceiptParser.parse('''
Shop
Total 1180.00
Includes GST 18% 180.00''');
    expect(r.amount, 1180.0);
  });
}

void missingTotalTests() {
  test('OCR missed the TOTAL line: subtotal plus taxes', () {
    final r = ReceiptParser.parse('''
Thank U Cafe-Surya Nagar
Date 28 Sept 2026
Margheritta Pizza x1 94.29
Peppy Paneer Pizza x1 199.05
Subtotal 607.62
CGST 2.5% 15.19
SGST 2.5% 15.19
Thank You''');
    expect(r.amount, 638.0);
  });

  test('OCR missed label but kept Rs.638', () {
    final r = ReceiptParser.parse('''
Thank U Cafe-Surya Nagar
Subtotal 607.62
CGST 2.5% 15.19
SGST 2.5% 15.19
Rs.638''');
    expect(r.amount, 638.0);
  });
}

void realMlKitTests() {
  // Exact text ML Kit returned on a phone: whole columns merged into single lines.
  test('merged-column ML Kit text no longer gives 639.33', () {
    final r = ReceiptParser.parse('''
POS-SNR-20260928-095 dining D10 9999999999 Muthulakshmi 94.29 199.05 71.43 109.52 133.33 607.62 15.19 15.19 Rs.638
28 Sept 2026, 07:34 pm Thank U Cafeâ aESurya Nagar
RETAIL INVOICE Thark U Cafe-Surya Nagar Surya Nagar A Ünit of IAB SOlutions Pvt. Ltd. GSTIN:33AADCI5736H1ZL FSSAI Lic No. 12425012000961 Thank You
Order Date Type Table No Phone Biller Served By Margheritta Pizza xl 1 x 94.29 Peppy Paneer Pizza x1 1x 199.05 Honey Cake_4 Pcs x1 1x 71.43 ates Halwa (Gms) X250 250 x 0.44 jamond Kunafa (Gms) x100 100 x 1.33 Subtotal CGST 2.5% SGST 2.5% TOTAL''');
    expect(r.amount, 638.0);
  });
}

void merchantGuardTests() {
  test('merged number row is never used as the merchant', () {
    final r = ReceiptParser.parse('''
07:34 pm dining D10 9999999999 Nagar 94.29 199.05 71.43 109.52 133.33 607.62 15.19 15.19 Rs.638
Thank U Cafe-Surya Nagar
TOTAL Rs.638''');
    expect(r.merchant, 'Thank U Cafe-Surya Nagar');
  });
}
