import 'package:expenses_tracker/utils/receipt_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
