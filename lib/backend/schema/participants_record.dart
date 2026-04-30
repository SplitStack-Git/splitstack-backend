import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ParticipantsRecord extends FirestoreRecord {
  ParticipantsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "is_locked" field.
  bool? _isLocked;
  bool get isLocked => _isLocked ?? false;
  bool hasIsLocked() => _isLocked != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "amount" field.
  double? _amount;
  double get amount => _amount ?? 0.0;
  bool hasAmount() => _amount != null;

  // "paid_status" field.
  bool? _paidStatus;
  bool get paidStatus => _paidStatus ?? false;
  bool hasPaidStatus() => _paidStatus != null;

  // "payment_pending" field.
  bool? _paymentPending;
  bool get paymentPending => _paymentPending ?? false;
  bool hasPaymentPending() => _paymentPending != null;

  // "payment_linksend" field.
  bool? _paymentLinksend;
  bool get paymentLinksend => _paymentLinksend ?? false;
  bool hasPaymentLinksend() => _paymentLinksend != null;

  // "isOrganiser" field.
  bool? _isOrganiser;
  bool get isOrganiser => _isOrganiser ?? false;
  bool hasIsOrganiser() => _isOrganiser != null;

  // "stack_id" field.
  DocumentReference? _stackId;
  DocumentReference? get stackId => _stackId;
  bool hasStackId() => _stackId != null;

  // "stripe_account_id" field.
  String? _stripeAccountId;
  String get stripeAccountId => _stripeAccountId ?? '';
  bool hasStripeAccountId() => _stripeAccountId != null;

  // "stripe_payouts_enabled" field.
  bool? _stripePayoutsEnabled;
  bool get stripePayoutsEnabled => _stripePayoutsEnabled ?? false;
  bool hasStripePayoutsEnabled() => _stripePayoutsEnabled != null;

  // "phone" field.
  String? _phone;
  String get phone => _phone ?? '';
  bool hasPhone() => _phone != null;

  void _initializeFields() {
    _isLocked = snapshotData['is_locked'] as bool?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _displayName = snapshotData['display_name'] as String?;
    _amount = castToType<double>(snapshotData['amount']);
    _paidStatus = snapshotData['paid_status'] as bool?;
    _paymentPending = snapshotData['payment_pending'] as bool?;
    _paymentLinksend = snapshotData['payment_linksend'] as bool?;
    _isOrganiser = snapshotData['isOrganiser'] as bool?;
    _stackId = snapshotData['stack_id'] as DocumentReference?;
    _stripeAccountId = snapshotData['stripe_account_id'] as String?;
    _stripePayoutsEnabled = snapshotData['stripe_payouts_enabled'] as bool?;
    _phone = snapshotData['phone'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('participants');

  static Stream<ParticipantsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ParticipantsRecord.fromSnapshot(s));

  static Future<ParticipantsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ParticipantsRecord.fromSnapshot(s));

  static ParticipantsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ParticipantsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ParticipantsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ParticipantsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ParticipantsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ParticipantsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createParticipantsRecordData({
  bool? isLocked,
  DateTime? createdAt,
  String? displayName,
  double? amount,
  bool? paidStatus,
  bool? paymentPending,
  bool? paymentLinksend,
  bool? isOrganiser,
  DocumentReference? stackId,
  String? stripeAccountId,
  bool? stripePayoutsEnabled,
  String? phone,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'is_locked': isLocked,
      'created_at': createdAt,
      'display_name': displayName,
      'amount': amount,
      'paid_status': paidStatus,
      'payment_pending': paymentPending,
      'payment_linksend': paymentLinksend,
      'isOrganiser': isOrganiser,
      'stack_id': stackId,
      'stripe_account_id': stripeAccountId,
      'stripe_payouts_enabled': stripePayoutsEnabled,
      'phone': phone,
    }.withoutNulls,
  );

  return firestoreData;
}

class ParticipantsRecordDocumentEquality
    implements Equality<ParticipantsRecord> {
  const ParticipantsRecordDocumentEquality();

  @override
  bool equals(ParticipantsRecord? e1, ParticipantsRecord? e2) {
    return e1?.isLocked == e2?.isLocked &&
        e1?.createdAt == e2?.createdAt &&
        e1?.displayName == e2?.displayName &&
        e1?.amount == e2?.amount &&
        e1?.paidStatus == e2?.paidStatus &&
        e1?.paymentPending == e2?.paymentPending &&
        e1?.paymentLinksend == e2?.paymentLinksend &&
        e1?.isOrganiser == e2?.isOrganiser &&
        e1?.stackId == e2?.stackId &&
        e1?.stripeAccountId == e2?.stripeAccountId &&
        e1?.stripePayoutsEnabled == e2?.stripePayoutsEnabled &&
        e1?.phone == e2?.phone;
  }

  @override
  int hash(ParticipantsRecord? e) => const ListEquality().hash([
        e?.isLocked,
        e?.createdAt,
        e?.displayName,
        e?.amount,
        e?.paidStatus,
        e?.paymentPending,
        e?.paymentLinksend,
        e?.isOrganiser,
        e?.stackId,
        e?.stripeAccountId,
        e?.stripePayoutsEnabled,
        e?.phone
      ]);

  @override
  bool isValidKey(Object? o) => o is ParticipantsRecord;
}
