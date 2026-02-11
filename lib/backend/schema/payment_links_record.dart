import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PaymentLinksRecord extends FirestoreRecord {
  PaymentLinksRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "link_id" field.
  String? _linkId;
  String get linkId => _linkId ?? '';
  bool hasLinkId() => _linkId != null;

  // "stack_id" field.
  String? _stackId;
  String get stackId => _stackId ?? '';
  bool hasStackId() => _stackId != null;

  // "participant_id" field.
  String? _participantId;
  String get participantId => _participantId ?? '';
  bool hasParticipantId() => _participantId != null;

  // "stripe_checkout_url" field.
  String? _stripeCheckoutUrl;
  String get stripeCheckoutUrl => _stripeCheckoutUrl ?? '';
  bool hasStripeCheckoutUrl() => _stripeCheckoutUrl != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  void _initializeFields() {
    _linkId = snapshotData['link_id'] as String?;
    _stackId = snapshotData['stack_id'] as String?;
    _participantId = snapshotData['participant_id'] as String?;
    _stripeCheckoutUrl = snapshotData['stripe_checkout_url'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('payment_links');

  static Stream<PaymentLinksRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PaymentLinksRecord.fromSnapshot(s));

  static Future<PaymentLinksRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PaymentLinksRecord.fromSnapshot(s));

  static PaymentLinksRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PaymentLinksRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PaymentLinksRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PaymentLinksRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PaymentLinksRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PaymentLinksRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPaymentLinksRecordData({
  String? linkId,
  String? stackId,
  String? participantId,
  String? stripeCheckoutUrl,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'link_id': linkId,
      'stack_id': stackId,
      'participant_id': participantId,
      'stripe_checkout_url': stripeCheckoutUrl,
      'created_at': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class PaymentLinksRecordDocumentEquality
    implements Equality<PaymentLinksRecord> {
  const PaymentLinksRecordDocumentEquality();

  @override
  bool equals(PaymentLinksRecord? e1, PaymentLinksRecord? e2) {
    return e1?.linkId == e2?.linkId &&
        e1?.stackId == e2?.stackId &&
        e1?.participantId == e2?.participantId &&
        e1?.stripeCheckoutUrl == e2?.stripeCheckoutUrl &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(PaymentLinksRecord? e) => const ListEquality().hash([
        e?.linkId,
        e?.stackId,
        e?.participantId,
        e?.stripeCheckoutUrl,
        e?.createdAt
      ]);

  @override
  bool isValidKey(Object? o) => o is PaymentLinksRecord;
}
