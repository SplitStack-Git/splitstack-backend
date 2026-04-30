// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class CurrencyStruct extends FFFirebaseStruct {
  CurrencyStruct({
    String? code,
    String? symbol,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _code = code,
        _symbol = symbol,
        super(firestoreUtilData);

  // "code" field.
  String? _code;
  String get code => _code ?? '';
  set code(String? val) => _code = val;

  bool hasCode() => _code != null;

  // "symbol" field.
  String? _symbol;
  String get symbol => _symbol ?? '';
  set symbol(String? val) => _symbol = val;

  bool hasSymbol() => _symbol != null;

  static CurrencyStruct fromMap(Map<String, dynamic> data) => CurrencyStruct(
        code: data['code'] as String?,
        symbol: data['symbol'] as String?,
      );

  static CurrencyStruct? maybeFromMap(dynamic data) =>
      data is Map ? CurrencyStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'code': _code,
        'symbol': _symbol,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'code': serializeParam(
          _code,
          ParamType.String,
        ),
        'symbol': serializeParam(
          _symbol,
          ParamType.String,
        ),
      }.withoutNulls;

  static CurrencyStruct fromSerializableMap(Map<String, dynamic> data) =>
      CurrencyStruct(
        code: deserializeParam(
          data['code'],
          ParamType.String,
          false,
        ),
        symbol: deserializeParam(
          data['symbol'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'CurrencyStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is CurrencyStruct &&
        code == other.code &&
        symbol == other.symbol;
  }

  @override
  int get hashCode => const ListEquality().hash([code, symbol]);
}

CurrencyStruct createCurrencyStruct({
  String? code,
  String? symbol,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    CurrencyStruct(
      code: code,
      symbol: symbol,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

CurrencyStruct? updateCurrencyStruct(
  CurrencyStruct? currency, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    currency
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addCurrencyStructData(
  Map<String, dynamic> firestoreData,
  CurrencyStruct? currency,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (currency == null) {
    return;
  }
  if (currency.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && currency.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final currencyData = getCurrencyFirestoreData(currency, forFieldValue);
  final nestedData = currencyData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = currency.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getCurrencyFirestoreData(
  CurrencyStruct? currency, [
  bool forFieldValue = false,
]) {
  if (currency == null) {
    return {};
  }
  final firestoreData = mapToFirestore(currency.toMap());

  // Add any Firestore field values
  mapToFirestore(currency.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getCurrencyListFirestoreData(
  List<CurrencyStruct>? currencys,
) =>
    currencys?.map((e) => getCurrencyFirestoreData(e, true)).toList() ?? [];
