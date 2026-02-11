import 'package:flutter/material.dart';
import '/backend/backend.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

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

  DocumentReference? _ref;
  DocumentReference? get ref => _ref;
  set ref(DocumentReference? value) {
    _ref = value;
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
}
