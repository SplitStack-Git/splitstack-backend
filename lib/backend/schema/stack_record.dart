import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StackRecord extends FirestoreRecord {
  StackRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "userID" field.
  String? _userID;
  String get userID => _userID ?? '';
  bool hasUserID() => _userID != null;

  // "stackCreatorName" field.
  String? _stackCreatorName;
  String get stackCreatorName => _stackCreatorName ?? '';
  bool hasStackCreatorName() => _stackCreatorName != null;

  // "stackFor" field.
  String? _stackFor;
  String get stackFor => _stackFor ?? '';
  bool hasStackFor() => _stackFor != null;

  // "amount" field.
  double? _amount;
  double get amount => _amount ?? 0.0;
  bool hasAmount() => _amount != null;

  // "IncludeCreator" field.
  bool? _includeCreator;
  bool get includeCreator => _includeCreator ?? false;
  bool hasIncludeCreator() => _includeCreator != null;

  // "participants" field.
  List<ParticipantsStruct>? _participants;
  List<ParticipantsStruct> get participants => _participants ?? const [];
  bool hasParticipants() => _participants != null;

  // "currency" field.
  String? _currency;
  String get currency => _currency ?? '';
  bool hasCurrency() => _currency != null;

  // "stackID" field.
  String? _stackID;
  String get stackID => _stackID ?? '';
  bool hasStackID() => _stackID != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "createAndShare" field.
  bool? _createAndShare;
  bool get createAndShare => _createAndShare ?? false;
  bool hasCreateAndShare() => _createAndShare != null;

  void _initializeFields() {
    _userID = snapshotData['userID'] as String?;
    _stackCreatorName = snapshotData['stackCreatorName'] as String?;
    _stackFor = snapshotData['stackFor'] as String?;
    _amount = castToType<double>(snapshotData['amount']);
    _includeCreator = snapshotData['IncludeCreator'] as bool?;
    _participants = getStructList(
      snapshotData['participants'],
      ParticipantsStruct.fromMap,
    );
    _currency = snapshotData['currency'] as String?;
    _stackID = snapshotData['stackID'] as String?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
    _createAndShare = snapshotData['createAndShare'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Stack');

  static Stream<StackRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => StackRecord.fromSnapshot(s));

  static Future<StackRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => StackRecord.fromSnapshot(s));

  static StackRecord fromSnapshot(DocumentSnapshot snapshot) => StackRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static StackRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      StackRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'StackRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is StackRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createStackRecordData({
  String? userID,
  String? stackCreatorName,
  String? stackFor,
  double? amount,
  bool? includeCreator,
  String? currency,
  String? stackID,
  DateTime? createdAt,
  bool? createAndShare,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'userID': userID,
      'stackCreatorName': stackCreatorName,
      'stackFor': stackFor,
      'amount': amount,
      'IncludeCreator': includeCreator,
      'currency': currency,
      'stackID': stackID,
      'createdAt': createdAt,
      'createAndShare': createAndShare,
    }.withoutNulls,
  );

  return firestoreData;
}

class StackRecordDocumentEquality implements Equality<StackRecord> {
  const StackRecordDocumentEquality();

  @override
  bool equals(StackRecord? e1, StackRecord? e2) {
    const listEquality = ListEquality();
    return e1?.userID == e2?.userID &&
        e1?.stackCreatorName == e2?.stackCreatorName &&
        e1?.stackFor == e2?.stackFor &&
        e1?.amount == e2?.amount &&
        e1?.includeCreator == e2?.includeCreator &&
        listEquality.equals(e1?.participants, e2?.participants) &&
        e1?.currency == e2?.currency &&
        e1?.stackID == e2?.stackID &&
        e1?.createdAt == e2?.createdAt &&
        e1?.createAndShare == e2?.createAndShare;
  }

  @override
  int hash(StackRecord? e) => const ListEquality().hash([
        e?.userID,
        e?.stackCreatorName,
        e?.stackFor,
        e?.amount,
        e?.includeCreator,
        e?.participants,
        e?.currency,
        e?.stackID,
        e?.createdAt,
        e?.createAndShare
      ]);

  @override
  bool isValidKey(Object? o) => o is StackRecord;
}
