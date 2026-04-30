// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class BankDetailStruct extends FFFirebaseStruct {
  BankDetailStruct({
    String? accountHolderName,
    String? country,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _accountHolderName = accountHolderName,
        _country = country,
        super(firestoreUtilData);

  // "accountHolderName" field.
  String? _accountHolderName;
  String get accountHolderName => _accountHolderName ?? '';
  set accountHolderName(String? val) => _accountHolderName = val;

  bool hasAccountHolderName() => _accountHolderName != null;

  // "country" field.
  String? _country;
  String get country => _country ?? '';
  set country(String? val) => _country = val;

  bool hasCountry() => _country != null;

  static BankDetailStruct fromMap(Map<String, dynamic> data) =>
      BankDetailStruct(
        accountHolderName: data['accountHolderName'] as String?,
        country: data['country'] as String?,
      );

  static BankDetailStruct? maybeFromMap(dynamic data) => data is Map
      ? BankDetailStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'accountHolderName': _accountHolderName,
        'country': _country,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'accountHolderName': serializeParam(
          _accountHolderName,
          ParamType.String,
        ),
        'country': serializeParam(
          _country,
          ParamType.String,
        ),
      }.withoutNulls;

  static BankDetailStruct fromSerializableMap(Map<String, dynamic> data) =>
      BankDetailStruct(
        accountHolderName: deserializeParam(
          data['accountHolderName'],
          ParamType.String,
          false,
        ),
        country: deserializeParam(
          data['country'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'BankDetailStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is BankDetailStruct &&
        accountHolderName == other.accountHolderName &&
        country == other.country;
  }

  @override
  int get hashCode => const ListEquality().hash([accountHolderName, country]);
}

BankDetailStruct createBankDetailStruct({
  String? accountHolderName,
  String? country,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    BankDetailStruct(
      accountHolderName: accountHolderName,
      country: country,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

BankDetailStruct? updateBankDetailStruct(
  BankDetailStruct? bankDetail, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    bankDetail
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addBankDetailStructData(
  Map<String, dynamic> firestoreData,
  BankDetailStruct? bankDetail,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (bankDetail == null) {
    return;
  }
  if (bankDetail.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && bankDetail.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final bankDetailData = getBankDetailFirestoreData(bankDetail, forFieldValue);
  final nestedData = bankDetailData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = bankDetail.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getBankDetailFirestoreData(
  BankDetailStruct? bankDetail, [
  bool forFieldValue = false,
]) {
  if (bankDetail == null) {
    return {};
  }
  final firestoreData = mapToFirestore(bankDetail.toMap());

  // Add any Firestore field values
  mapToFirestore(bankDetail.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getBankDetailListFirestoreData(
  List<BankDetailStruct>? bankDetails,
) =>
    bankDetails?.map((e) => getBankDetailFirestoreData(e, true)).toList() ?? [];
