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

  // "total_amount" field.
  double? _totalAmount;
  double get totalAmount => _totalAmount ?? 0.0;
  bool hasTotalAmount() => _totalAmount != null;

  // "createAndShare" field.
  bool? _createAndShare;
  bool get createAndShare => _createAndShare ?? false;
  bool hasCreateAndShare() => _createAndShare != null;

  // "organiser_name" field.
  String? _organiserName;
  String get organiserName => _organiserName ?? '';
  bool hasOrganiserName() => _organiserName != null;

  // "include_creator" field.
  bool? _includeCreator;
  bool get includeCreator => _includeCreator ?? false;
  bool hasIncludeCreator() => _includeCreator != null;

  // "organiser_id" field.
  String? _organiserId;
  String get organiserId => _organiserId ?? '';
  bool hasOrganiserId() => _organiserId != null;

  // "stack_for" field.
  String? _stackFor;
  String get stackFor => _stackFor ?? '';
  bool hasStackFor() => _stackFor != null;

  // "public_status_token" field.
  String? _publicStatusToken;
  String get publicStatusToken => _publicStatusToken ?? '';
  bool hasPublicStatusToken() => _publicStatusToken != null;

  void _initializeFields() {
    _title = snapshotData['title'] as String?;
    _currency = snapshotData['currency'] as String?;
    _stackStatus = snapshotData['stack_status'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _totalAmount = castToType<double>(snapshotData['total_amount']);
    _createAndShare = snapshotData['createAndShare'] as bool?;
    _organiserName = snapshotData['organiser_name'] as String?;
    _includeCreator = snapshotData['include_creator'] as bool?;
    _organiserId = snapshotData['organiser_id'] as String?;
    _stackFor = snapshotData['stack_for'] as String?;
    _publicStatusToken = snapshotData['public_status_token'] as String?;
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
  String? title,
  String? currency,
  String? stackStatus,
  DateTime? createdAt,
  double? totalAmount,
  bool? createAndShare,
  String? organiserName,
  bool? includeCreator,
  String? organiserId,
  String? stackFor,
  String? publicStatusToken,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'title': title,
      'currency': currency,
      'stack_status': stackStatus,
      'created_at': createdAt,
      'total_amount': totalAmount,
      'createAndShare': createAndShare,
      'organiser_name': organiserName,
      'include_creator': includeCreator,
      'organiser_id': organiserId,
      'stack_for': stackFor,
      'public_status_token': publicStatusToken,
    }.withoutNulls,
  );

  return firestoreData;
}

class StacksRecordDocumentEquality implements Equality<StacksRecord> {
  const StacksRecordDocumentEquality();

  @override
  bool equals(StacksRecord? e1, StacksRecord? e2) {
    return e1?.title == e2?.title &&
        e1?.currency == e2?.currency &&
        e1?.stackStatus == e2?.stackStatus &&
        e1?.createdAt == e2?.createdAt &&
        e1?.totalAmount == e2?.totalAmount &&
        e1?.createAndShare == e2?.createAndShare &&
        e1?.organiserName == e2?.organiserName &&
        e1?.includeCreator == e2?.includeCreator &&
        e1?.organiserId == e2?.organiserId &&
        e1?.stackFor == e2?.stackFor &&
        e1?.publicStatusToken == e2?.publicStatusToken;
  }

  @override
  int hash(StacksRecord? e) => const ListEquality().hash([
        e?.title,
        e?.currency,
        e?.stackStatus,
        e?.createdAt,
        e?.totalAmount,
        e?.createAndShare,
        e?.organiserName,
        e?.includeCreator,
        e?.organiserId,
        e?.stackFor,
        e?.publicStatusToken
      ]);

  @override
  bool isValidKey(Object? o) => o is StacksRecord;
}
