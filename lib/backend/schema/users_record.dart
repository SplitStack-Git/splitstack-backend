import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user_id" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "phone" field.
  String? _phone;
  String get phone => _phone ?? '';
  bool hasPhone() => _phone != null;

  // "stripe_account_id" field.
  String? _stripeAccountId;
  String get stripeAccountId => _stripeAccountId ?? '';
  bool hasStripeAccountId() => _stripeAccountId != null;

  // "has_seen_get_paid" field.
  bool? _hasSeenGetPaid;
  bool get hasSeenGetPaid => _hasSeenGetPaid ?? false;
  bool hasHasSeenGetPaid() => _hasSeenGetPaid != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  void _initializeFields() {
    _userId = snapshotData['user_id'] as String?;
    _name = snapshotData['name'] as String?;
    _phone = snapshotData['phone'] as String?;
    _stripeAccountId = snapshotData['stripe_account_id'] as String?;
    _hasSeenGetPaid = snapshotData['has_seen_get_paid'] as bool?;
    _createdAt = snapshotData['created_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? userId,
  String? name,
  String? phone,
  String? stripeAccountId,
  bool? hasSeenGetPaid,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_id': userId,
      'name': name,
      'phone': phone,
      'stripe_account_id': stripeAccountId,
      'has_seen_get_paid': hasSeenGetPaid,
      'created_at': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    return e1?.userId == e2?.userId &&
        e1?.name == e2?.name &&
        e1?.phone == e2?.phone &&
        e1?.stripeAccountId == e2?.stripeAccountId &&
        e1?.hasSeenGetPaid == e2?.hasSeenGetPaid &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.userId,
        e?.name,
        e?.phone,
        e?.stripeAccountId,
        e?.hasSeenGetPaid,
        e?.createdAt
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
