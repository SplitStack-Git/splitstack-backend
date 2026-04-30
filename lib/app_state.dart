import 'package:flutter/material.dart';
import '/backend/backend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _onbFirstName = prefs.getString('ff_onbFirstName') ?? _onbFirstName;
    });
    _safeInit(() {
      _onbLastName = prefs.getString('ff_onbLastName') ?? _onbLastName;
    });
    _safeInit(() {
      _onbEmail = prefs.getString('ff_onbEmail') ?? _onbEmail;
    });
    _safeInit(() {
      _onbPhone = prefs.getString('ff_onbPhone') ?? _onbPhone;
    });
    _safeInit(() {
      _onbDob = prefs.containsKey('ff_onbDob')
          ? DateTime.fromMillisecondsSinceEpoch(prefs.getInt('ff_onbDob')!)
          : _onbDob;
    });
    _safeInit(() {
      _onbStreet1 = prefs.getString('ff_onbStreet1') ?? _onbStreet1;
    });
    _safeInit(() {
      _onbStreet2 = prefs.getString('ff_onbStreet2') ?? _onbStreet2;
    });
    _safeInit(() {
      _onbCity = prefs.getString('ff_onbCity') ?? _onbCity;
    });
    _safeInit(() {
      _onbState = prefs.getString('ff_onbState') ?? _onbState;
    });
    _safeInit(() {
      _onbPostcode = prefs.getString('ff_onbPostcode') ?? _onbPostcode;
    });
    _safeInit(() {
      _onbCountry = prefs.getString('ff_onbCountry') ?? _onbCountry;
    });
    _safeInit(() {
      _onbAccountHolderName =
          prefs.getString('ff_onbAccountHolderName') ?? _onbAccountHolderName;
    });
    _safeInit(() {
      _onbBsb = prefs.getString('ff_onbBsb') ?? _onbBsb;
    });
    _safeInit(() {
      _onbAccountNumber =
          prefs.getString('ff_onbAccountNumber') ?? _onbAccountNumber;
    });
    _safeInit(() {
      _onbUsage = prefs.getString('ff_onbUsage') ?? _onbUsage;
    });
    _safeInit(() {
      _onbConsentAccepted =
          prefs.getBool('ff_onbConsentAccepted') ?? _onbConsentAccepted;
    });
    _safeInit(() {
      _isRegistrationComplete =
          prefs.getBool('ff_isRegistrationComplete') ?? _isRegistrationComplete;
    });
    _safeInit(() {
      _onbRoutingNumber =
          prefs.getString('ff_onbRoutingNumber') ?? _onbRoutingNumber;
    });
    _safeInit(() {
      _onbInstitutionNumber =
          prefs.getString('ff_onbInstitutionNumber') ?? _onbInstitutionNumber;
    });
    _safeInit(() {
      _onbTransitNumber =
          prefs.getString('ff_onbTransitNumber') ?? _onbTransitNumber;
    });
    _safeInit(() {
      _onbSortCode = prefs.getString('ff_onbSortCode') ?? _onbSortCode;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  String _currentUserId = '';
  String get currentUserId => _currentUserId;
  set currentUserId(String value) {
    _currentUserId = value;
  }

  List<ParticipantsStruct> _participants = [];
  List<ParticipantsStruct> get participants => _participants;
  set participants(List<ParticipantsStruct> value) {
    _participants = value;
  }

  void addToParticipants(ParticipantsStruct value) {
    participants.add(value);
  }

  void removeFromParticipants(ParticipantsStruct value) {
    participants.remove(value);
  }

  void removeAtIndexFromParticipants(int index) {
    participants.removeAt(index);
  }

  void updateParticipantsAtIndex(
    int index,
    ParticipantsStruct Function(ParticipantsStruct) updateFn,
  ) {
    participants[index] = updateFn(_participants[index]);
  }

  void insertAtIndexInParticipants(int index, ParticipantsStruct value) {
    participants.insert(index, value);
  }

  String _stackid = '';
  String get stackid => _stackid;
  set stackid(String value) {
    _stackid = value;
  }

  int _paymentAmountCents = 0;
  int get paymentAmountCents => _paymentAmountCents;
  set paymentAmountCents(int value) {
    _paymentAmountCents = value;
  }

  String _paymentCurrency = 'aud';
  String get paymentCurrency => _paymentCurrency;
  set paymentCurrency(String value) {
    _paymentCurrency = value;
  }

  String _selectedParticipantId = '';
  String get selectedParticipantId => _selectedParticipantId;
  set selectedParticipantId(String value) {
    _selectedParticipantId = value;
  }

  String _checkoutUrl = '';
  String get checkoutUrl => _checkoutUrl;
  set checkoutUrl(String value) {
    _checkoutUrl = value;
  }

  String _onbFirstName = '';
  String get onbFirstName => _onbFirstName;
  set onbFirstName(String value) {
    _onbFirstName = value;
    prefs.setString('ff_onbFirstName', value);
  }

  String _onbLastName = '';
  String get onbLastName => _onbLastName;
  set onbLastName(String value) {
    _onbLastName = value;
    prefs.setString('ff_onbLastName', value);
  }

  String _onbEmail = '';
  String get onbEmail => _onbEmail;
  set onbEmail(String value) {
    _onbEmail = value;
    prefs.setString('ff_onbEmail', value);
  }

  String _onbPhone = '';
  String get onbPhone => _onbPhone;
  set onbPhone(String value) {
    _onbPhone = value;
    prefs.setString('ff_onbPhone', value);
  }

  DateTime? _onbDob;
  DateTime? get onbDob => _onbDob;
  set onbDob(DateTime? value) {
    _onbDob = value;
    value != null
        ? prefs.setInt('ff_onbDob', value.millisecondsSinceEpoch)
        : prefs.remove('ff_onbDob');
  }

  String _onbStreet1 = '';
  String get onbStreet1 => _onbStreet1;
  set onbStreet1(String value) {
    _onbStreet1 = value;
    prefs.setString('ff_onbStreet1', value);
  }

  String _onbStreet2 = '';
  String get onbStreet2 => _onbStreet2;
  set onbStreet2(String value) {
    _onbStreet2 = value;
    prefs.setString('ff_onbStreet2', value);
  }

  String _onbCity = '';
  String get onbCity => _onbCity;
  set onbCity(String value) {
    _onbCity = value;
    prefs.setString('ff_onbCity', value);
  }

  String _onbState = '';
  String get onbState => _onbState;
  set onbState(String value) {
    _onbState = value;
    prefs.setString('ff_onbState', value);
  }

  String _onbPostcode = '';
  String get onbPostcode => _onbPostcode;
  set onbPostcode(String value) {
    _onbPostcode = value;
    prefs.setString('ff_onbPostcode', value);
  }

  String _onbCountry = '';
  String get onbCountry => _onbCountry;
  set onbCountry(String value) {
    _onbCountry = value;
    prefs.setString('ff_onbCountry', value);
  }

  String _onbAccountHolderName = '';
  String get onbAccountHolderName => _onbAccountHolderName;
  set onbAccountHolderName(String value) {
    _onbAccountHolderName = value;
    prefs.setString('ff_onbAccountHolderName', value);
  }

  String _onbBsb = '';
  String get onbBsb => _onbBsb;
  set onbBsb(String value) {
    _onbBsb = value;
    prefs.setString('ff_onbBsb', value);
  }

  String _onbAccountNumber = '';
  String get onbAccountNumber => _onbAccountNumber;
  set onbAccountNumber(String value) {
    _onbAccountNumber = value;
    prefs.setString('ff_onbAccountNumber', value);
  }

  String _onbUsage = '';
  String get onbUsage => _onbUsage;
  set onbUsage(String value) {
    _onbUsage = value;
    prefs.setString('ff_onbUsage', value);
  }

  bool _onbConsentAccepted = false;
  bool get onbConsentAccepted => _onbConsentAccepted;
  set onbConsentAccepted(bool value) {
    _onbConsentAccepted = value;
    prefs.setBool('ff_onbConsentAccepted', value);
  }

  DocumentReference? _stackRef;
  DocumentReference? get stackRef => _stackRef;
  set stackRef(DocumentReference? value) {
    _stackRef = value;
  }

  String _splittingdinners = '';
  String get splittingdinners => _splittingdinners;
  set splittingdinners(String value) {
    _splittingdinners = value;
  }

  String _grouptravel = '';
  String get grouptravel => _grouptravel;
  set grouptravel(String value) {
    _grouptravel = value;
  }

  String _householdbills = '';
  String get householdbills => _householdbills;
  set householdbills(String value) {
    _householdbills = value;
  }

  String _sharedevents = '';
  String get sharedevents => _sharedevents;
  set sharedevents(String value) {
    _sharedevents = value;
  }

  String _other = '';
  String get other => _other;
  set other(String value) {
    _other = value;
  }

  String _publicStatusToken = '';
  String get publicStatusToken => _publicStatusToken;
  set publicStatusToken(String value) {
    _publicStatusToken = value;
  }

  String _onbPassword = '';
  String get onbPassword => _onbPassword;
  set onbPassword(String value) {
    _onbPassword = value;
  }

  String _participantPhoneTemp = '';
  String get participantPhoneTemp => _participantPhoneTemp;
  set participantPhoneTemp(String value) {
    _participantPhoneTemp = value;
  }

  List<CurrencyStruct> _currencyList = [
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"AED\",\"symbol\":\"د.إ\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"AUD\",\"symbol\":\"\$\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"BRL\",\"symbol\":\"R\$\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"CAD\",\"symbol\":\"\$\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"CHF\",\"symbol\":\"CHF\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"CZK\",\"symbol\":\"Kč\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"DKK\",\"symbol\":\"kr\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"EUR\",\"symbol\":\"€\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"GBP\",\"symbol\":\"£\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"HKD\",\"symbol\":\"\$\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"HUF\",\"symbol\":\"Ft\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"IDR\",\"symbol\":\"Rp\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"INR\",\"symbol\":\"₹\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"JPY\",\"symbol\":\"¥\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"KRW\",\"symbol\":\"₩\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"MXN\",\"symbol\":\"\$\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"MYR\",\"symbol\":\"RM\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"NOK\",\"symbol\":\"kr\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"NZD\",\"symbol\":\"\$\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"PHP\",\"symbol\":\"₱\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"PLN\",\"symbol\":\"zł\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"SEK\",\"symbol\":\"kr\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"SGD\",\"symbol\":\"\$\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"THB\",\"symbol\":\"฿\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"USD\",\"symbol\":\"\$\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"VND\",\"symbol\":\"₫\"}')),
    CurrencyStruct.fromSerializableMap(
        jsonDecode('{\"code\":\"ZAR\",\"symbol\":\"R\"}'))
  ];
  List<CurrencyStruct> get currencyList => _currencyList;
  set currencyList(List<CurrencyStruct> value) {
    _currencyList = value;
  }

  void addToCurrencyList(CurrencyStruct value) {
    currencyList.add(value);
  }

  void removeFromCurrencyList(CurrencyStruct value) {
    currencyList.remove(value);
  }

  void removeAtIndexFromCurrencyList(int index) {
    currencyList.removeAt(index);
  }

  void updateCurrencyListAtIndex(
    int index,
    CurrencyStruct Function(CurrencyStruct) updateFn,
  ) {
    currencyList[index] = updateFn(_currencyList[index]);
  }

  void insertAtIndexInCurrencyList(int index, CurrencyStruct value) {
    currencyList.insert(index, value);
  }

  bool _isRegistrationComplete = false;
  bool get isRegistrationComplete => _isRegistrationComplete;
  set isRegistrationComplete(bool value) {
    _isRegistrationComplete = value;
    prefs.setBool('ff_isRegistrationComplete', value);
  }

  String _onbRoutingNumber = '';
  String get onbRoutingNumber => _onbRoutingNumber;
  set onbRoutingNumber(String value) {
    _onbRoutingNumber = value;
    prefs.setString('ff_onbRoutingNumber', value);
  }

  String _onbInstitutionNumber = '';
  String get onbInstitutionNumber => _onbInstitutionNumber;
  set onbInstitutionNumber(String value) {
    _onbInstitutionNumber = value;
    prefs.setString('ff_onbInstitutionNumber', value);
  }

  String _onbTransitNumber = '';
  String get onbTransitNumber => _onbTransitNumber;
  set onbTransitNumber(String value) {
    _onbTransitNumber = value;
    prefs.setString('ff_onbTransitNumber', value);
  }

  String _onbSortCode = '';
  String get onbSortCode => _onbSortCode;
  set onbSortCode(String value) {
    _onbSortCode = value;
    prefs.setString('ff_onbSortCode', value);
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
