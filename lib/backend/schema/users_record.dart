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

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "date_of_birth" field.
  DateTime? _dateOfBirth;
  DateTime? get dateOfBirth => _dateOfBirth;
  bool hasDateOfBirth() => _dateOfBirth != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "is_registered" field.
  bool? _isRegistered;
  bool get isRegistered => _isRegistered ?? false;
  bool hasIsRegistered() => _isRegistered != null;

  void _initializeFields() {
    _userId = snapshotData['user_id'] as String?;
    _name = snapshotData['name'] as String?;
    _phone = snapshotData['phone'] as String?;
    _stripeAccountId = snapshotData['stripe_account_id'] as String?;
    _hasSeenGetPaid = snapshotData['has_seen_get_paid'] as bool?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _email = snapshotData['email'] as String?;
    _dateOfBirth = snapshotData['date_of_birth'] as DateTime?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _isRegistered = snapshotData['is_registered'] as bool?;
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
  String? email,
  DateTime? dateOfBirth,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
  bool? isRegistered,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_id': userId,
      'name': name,
      'phone': phone,
      'stripe_account_id': stripeAccountId,
      'has_seen_get_paid': hasSeenGetPaid,
      'created_at': createdAt,
      'email': email,
      'date_of_birth': dateOfBirth,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'is_registered': isRegistered,
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
        e1?.createdAt == e2?.createdAt &&
        e1?.email == e2?.email &&
        e1?.dateOfBirth == e2?.dateOfBirth &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.isRegistered == e2?.isRegistered;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.userId,
        e?.name,
        e?.phone,
        e?.stripeAccountId,
        e?.hasSeenGetPaid,
        e?.createdAt,
        e?.email,
        e?.dateOfBirth,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber,
        e?.isRegistered
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
