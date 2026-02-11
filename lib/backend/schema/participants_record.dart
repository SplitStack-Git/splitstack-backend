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

  // "participant_id" field.
  String? _participantId;
  String get participantId => _participantId ?? '';
  bool hasParticipantId() => _participantId != null;

  // "stack_id" field.
  String? _stackId;
  String get stackId => _stackId ?? '';
  bool hasStackId() => _stackId != null;

  // "phone" field.
  String? _phone;
  String get phone => _phone ?? '';
  bool hasPhone() => _phone != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "sent_at" field.
  DateTime? _sentAt;
  DateTime? get sentAt => _sentAt;
  bool hasSentAt() => _sentAt != null;

  // "paid_at" field.
  DateTime? _paidAt;
  DateTime? get paidAt => _paidAt;
  bool hasPaidAt() => _paidAt != null;

  // "payment_intent_id" field.
  String? _paymentIntentId;
  String get paymentIntentId => _paymentIntentId ?? '';
  bool hasPaymentIntentId() => _paymentIntentId != null;

  // "is_locked" field.
  bool? _isLocked;
  bool get isLocked => _isLocked ?? false;
  bool hasIsLocked() => _isLocked != null;

  // "is_payer" field.
  bool? _isPayer;
  bool get isPayer => _isPayer ?? false;
  bool hasIsPayer() => _isPayer != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "adjusted_amount" field.
  double? _adjustedAmount;
  double get adjustedAmount => _adjustedAmount ?? 0.0;
  bool hasAdjustedAmount() => _adjustedAmount != null;

  // "base_amount" field.
  double? _baseAmount;
  double get baseAmount => _baseAmount ?? 0.0;
  bool hasBaseAmount() => _baseAmount != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "final_amount" field.
  double? _finalAmount;
  double get finalAmount => _finalAmount ?? 0.0;
  bool hasFinalAmount() => _finalAmount != null;

  // "paymentLinkUrl" field.
  String? _paymentLinkUrl;
  String get paymentLinkUrl => _paymentLinkUrl ?? '';
  bool hasPaymentLinkUrl() => _paymentLinkUrl != null;

  void _initializeFields() {
    _participantId = snapshotData['participant_id'] as String?;
    _stackId = snapshotData['stack_id'] as String?;
    _phone = snapshotData['phone'] as String?;
    _status = snapshotData['status'] as String?;
    _sentAt = snapshotData['sent_at'] as DateTime?;
    _paidAt = snapshotData['paid_at'] as DateTime?;
    _paymentIntentId = snapshotData['payment_intent_id'] as String?;
    _isLocked = snapshotData['is_locked'] as bool?;
    _isPayer = snapshotData['is_payer'] as bool?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _adjustedAmount = castToType<double>(snapshotData['adjusted_amount']);
    _baseAmount = castToType<double>(snapshotData['base_amount']);
    _displayName = snapshotData['display_name'] as String?;
    _finalAmount = castToType<double>(snapshotData['final_amount']);
    _paymentLinkUrl = snapshotData['paymentLinkUrl'] as String?;
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
  String? participantId,
  String? stackId,
  String? phone,
  String? status,
  DateTime? sentAt,
  DateTime? paidAt,
  String? paymentIntentId,
  bool? isLocked,
  bool? isPayer,
  DateTime? createdAt,
  double? adjustedAmount,
  double? baseAmount,
  String? displayName,
  double? finalAmount,
  String? paymentLinkUrl,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'participant_id': participantId,
      'stack_id': stackId,
      'phone': phone,
      'status': status,
      'sent_at': sentAt,
      'paid_at': paidAt,
      'payment_intent_id': paymentIntentId,
      'is_locked': isLocked,
      'is_payer': isPayer,
      'created_at': createdAt,
      'adjusted_amount': adjustedAmount,
      'base_amount': baseAmount,
      'display_name': displayName,
      'final_amount': finalAmount,
      'paymentLinkUrl': paymentLinkUrl,
    }.withoutNulls,
  );

  return firestoreData;
}

class ParticipantsRecordDocumentEquality
    implements Equality<ParticipantsRecord> {
  const ParticipantsRecordDocumentEquality();

  @override
  bool equals(ParticipantsRecord? e1, ParticipantsRecord? e2) {
    return e1?.participantId == e2?.participantId &&
        e1?.stackId == e2?.stackId &&
        e1?.phone == e2?.phone &&
        e1?.status == e2?.status &&
        e1?.sentAt == e2?.sentAt &&
        e1?.paidAt == e2?.paidAt &&
        e1?.paymentIntentId == e2?.paymentIntentId &&
        e1?.isLocked == e2?.isLocked &&
        e1?.isPayer == e2?.isPayer &&
        e1?.createdAt == e2?.createdAt &&
        e1?.adjustedAmount == e2?.adjustedAmount &&
        e1?.baseAmount == e2?.baseAmount &&
        e1?.displayName == e2?.displayName &&
        e1?.finalAmount == e2?.finalAmount &&
        e1?.paymentLinkUrl == e2?.paymentLinkUrl;
  }

  @override
  int hash(ParticipantsRecord? e) => const ListEquality().hash([
        e?.participantId,
        e?.stackId,
        e?.phone,
        e?.status,
        e?.sentAt,
        e?.paidAt,
        e?.paymentIntentId,
        e?.isLocked,
        e?.isPayer,
        e?.createdAt,
        e?.adjustedAmount,
        e?.baseAmount,
        e?.displayName,
        e?.finalAmount,
        e?.paymentLinkUrl
      ]);

  @override
  bool isValidKey(Object? o) => o is ParticipantsRecord;
}
