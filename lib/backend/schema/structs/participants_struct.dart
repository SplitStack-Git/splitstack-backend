// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class ParticipantsStruct extends FFFirebaseStruct {
  ParticipantsStruct({
    String? name,
    double? amount,
    bool? lock,
    bool? paidStatus,
    bool? paymentLinkSend,
    String? userID,
    bool? pendingPayment,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _name = name,
        _amount = amount,
        _lock = lock,
        _paidStatus = paidStatus,
        _paymentLinkSend = paymentLinkSend,
        _userID = userID,
        _pendingPayment = pendingPayment,
        super(firestoreUtilData);

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  // "amount" field.
  double? _amount;
  double get amount => _amount ?? 0.0;
  set amount(double? val) => _amount = val;

  void incrementAmount(double amount) => amount = amount + amount;

  bool hasAmount() => _amount != null;

  // "lock" field.
  bool? _lock;
  bool get lock => _lock ?? false;
  set lock(bool? val) => _lock = val;

  bool hasLock() => _lock != null;

  // "paidStatus" field.
  bool? _paidStatus;
  bool get paidStatus => _paidStatus ?? false;
  set paidStatus(bool? val) => _paidStatus = val;

  bool hasPaidStatus() => _paidStatus != null;

  // "paymentLinkSend" field.
  bool? _paymentLinkSend;
  bool get paymentLinkSend => _paymentLinkSend ?? false;
  set paymentLinkSend(bool? val) => _paymentLinkSend = val;

  bool hasPaymentLinkSend() => _paymentLinkSend != null;

  // "userID" field.
  String? _userID;
  String get userID => _userID ?? '';
  set userID(String? val) => _userID = val;

  bool hasUserID() => _userID != null;

  // "pendingPayment" field.
  bool? _pendingPayment;
  bool get pendingPayment => _pendingPayment ?? false;
  set pendingPayment(bool? val) => _pendingPayment = val;

  bool hasPendingPayment() => _pendingPayment != null;

  static ParticipantsStruct fromMap(Map<String, dynamic> data) =>
      ParticipantsStruct(
        name: data['name'] as String?,
        amount: castToType<double>(data['amount']),
        lock: data['lock'] as bool?,
        paidStatus: data['paidStatus'] as bool?,
        paymentLinkSend: data['paymentLinkSend'] as bool?,
        userID: data['userID'] as String?,
        pendingPayment: data['pendingPayment'] as bool?,
      );

  static ParticipantsStruct? maybeFromMap(dynamic data) => data is Map
      ? ParticipantsStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'name': _name,
        'amount': _amount,
        'lock': _lock,
        'paidStatus': _paidStatus,
        'paymentLinkSend': _paymentLinkSend,
        'userID': _userID,
        'pendingPayment': _pendingPayment,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'amount': serializeParam(
          _amount,
          ParamType.double,
        ),
        'lock': serializeParam(
          _lock,
          ParamType.bool,
        ),
        'paidStatus': serializeParam(
          _paidStatus,
          ParamType.bool,
        ),
        'paymentLinkSend': serializeParam(
          _paymentLinkSend,
          ParamType.bool,
        ),
        'userID': serializeParam(
          _userID,
          ParamType.String,
        ),
        'pendingPayment': serializeParam(
          _pendingPayment,
          ParamType.bool,
        ),
      }.withoutNulls;

  static ParticipantsStruct fromSerializableMap(Map<String, dynamic> data) =>
      ParticipantsStruct(
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
        amount: deserializeParam(
          data['amount'],
          ParamType.double,
          false,
        ),
        lock: deserializeParam(
          data['lock'],
          ParamType.bool,
          false,
        ),
        paidStatus: deserializeParam(
          data['paidStatus'],
          ParamType.bool,
          false,
        ),
        paymentLinkSend: deserializeParam(
          data['paymentLinkSend'],
          ParamType.bool,
          false,
        ),
        userID: deserializeParam(
          data['userID'],
          ParamType.String,
          false,
        ),
        pendingPayment: deserializeParam(
          data['pendingPayment'],
          ParamType.bool,
          false,
        ),
      );

  @override
  String toString() => 'ParticipantsStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ParticipantsStruct &&
        name == other.name &&
        amount == other.amount &&
        lock == other.lock &&
        paidStatus == other.paidStatus &&
        paymentLinkSend == other.paymentLinkSend &&
        userID == other.userID &&
        pendingPayment == other.pendingPayment;
  }

  @override
  int get hashCode => const ListEquality().hash([
        name,
        amount,
        lock,
        paidStatus,
        paymentLinkSend,
        userID,
        pendingPayment
      ]);
}

ParticipantsStruct createParticipantsStruct({
  String? name,
  double? amount,
  bool? lock,
  bool? paidStatus,
  bool? paymentLinkSend,
  String? userID,
  bool? pendingPayment,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ParticipantsStruct(
      name: name,
      amount: amount,
      lock: lock,
      paidStatus: paidStatus,
      paymentLinkSend: paymentLinkSend,
      userID: userID,
      pendingPayment: pendingPayment,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ParticipantsStruct? updateParticipantsStruct(
  ParticipantsStruct? participants, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    participants
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addParticipantsStructData(
  Map<String, dynamic> firestoreData,
  ParticipantsStruct? participants,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (participants == null) {
    return;
  }
  if (participants.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && participants.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final participantsData =
      getParticipantsFirestoreData(participants, forFieldValue);
  final nestedData =
      participantsData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = participants.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getParticipantsFirestoreData(
  ParticipantsStruct? participants, [
  bool forFieldValue = false,
]) {
  if (participants == null) {
    return {};
  }
  final firestoreData = mapToFirestore(participants.toMap());

  // Add any Firestore field values
  participants.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getParticipantsListFirestoreData(
  List<ParticipantsStruct>? participantss,
) =>
    participantss?.map((e) => getParticipantsFirestoreData(e, true)).toList() ??
    [];
