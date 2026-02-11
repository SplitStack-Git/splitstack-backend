import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StacksRecord extends FirestoreRecord {
  StacksRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "stack_id" field.
  String? _stackId;
  String get stackId => _stackId ?? '';
  bool hasStackId() => _stackId != null;

  // "creator_user_id" field.
  String? _creatorUserId;
  String get creatorUserId => _creatorUserId ?? '';
  bool hasCreatorUserId() => _creatorUserId != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "currency" field.
  String? _currency;
  String get currency => _currency ?? '';
  bool hasCurrency() => _currency != null;

  // "stack_status" field.
  String? _stackStatus;
  String get stackStatus => _stackStatus ?? '';
  bool hasStackStatus() => _stackStatus != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "settled_at" field.
  DateTime? _settledAt;
  DateTime? get settledAt => _settledAt;
  bool hasSettledAt() => _settledAt != null;

  // "payer_name" field.
  String? _payerName;
  String get payerName => _payerName ?? '';
  bool hasPayerName() => _payerName != null;

  // "total_amount" field.
  double? _totalAmount;
  double get totalAmount => _totalAmount ?? 0.0;
  bool hasTotalAmount() => _totalAmount != null;

  void _initializeFields() {
    _stackId = snapshotData['stack_id'] as String?;
    _creatorUserId = snapshotData['creator_user_id'] as String?;
    _title = snapshotData['title'] as String?;
    _currency = snapshotData['currency'] as String?;
    _stackStatus = snapshotData['stack_status'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _settledAt = snapshotData['settled_at'] as DateTime?;
    _payerName = snapshotData['payer_name'] as String?;
    _totalAmount = castToType<double>(snapshotData['total_amount']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('stacks');

  static Stream<StacksRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => StacksRecord.fromSnapshot(s));

  static Future<StacksRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => StacksRecord.fromSnapshot(s));

  static StacksRecord fromSnapshot(DocumentSnapshot snapshot) => StacksRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static StacksRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      StacksRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'StacksRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is StacksRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createStacksRecordData({
  String? stackId,
  String? creatorUserId,
  String? title,
  String? currency,
  String? stackStatus,
  DateTime? createdAt,
  DateTime? settledAt,
  String? payerName,
  double? totalAmount,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'stack_id': stackId,
      'creator_user_id': creatorUserId,
      'title': title,
      'currency': currency,
      'stack_status': stackStatus,
      'created_at': createdAt,
      'settled_at': settledAt,
      'payer_name': payerName,
      'total_amount': totalAmount,
    }.withoutNulls,
  );

  return firestoreData;
}

class StacksRecordDocumentEquality implements Equality<StacksRecord> {
  const StacksRecordDocumentEquality();

  @override
  bool equals(StacksRecord? e1, StacksRecord? e2) {
    return e1?.stackId == e2?.stackId &&
        e1?.creatorUserId == e2?.creatorUserId &&
        e1?.title == e2?.title &&
        e1?.currency == e2?.currency &&
        e1?.stackStatus == e2?.stackStatus &&
        e1?.createdAt == e2?.createdAt &&
        e1?.settledAt == e2?.settledAt &&
        e1?.payerName == e2?.payerName &&
        e1?.totalAmount == e2?.totalAmount;
  }

  @override
  int hash(StacksRecord? e) => const ListEquality().hash([
        e?.stackId,
        e?.creatorUserId,
        e?.title,
        e?.currency,
        e?.stackStatus,
        e?.createdAt,
        e?.settledAt,
        e?.payerName,
        e?.totalAmount
      ]);

  @override
  bool isValidKey(Object? o) => o is StacksRecord;
}
