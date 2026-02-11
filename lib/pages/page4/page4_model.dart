import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'page4_widget.dart' show Page4Widget;
import 'package:flutter/material.dart';

class Page4Model extends FlutterFlowModel<Page4Widget> {
  ///  Local state fields for this page.

  List<dynamic> participantsOriginal = [];
  void addToParticipantsOriginal(dynamic item) =>
      participantsOriginal.add(item);
  void removeFromParticipantsOriginal(dynamic item) =>
      participantsOriginal.remove(item);
  void removeAtIndexFromParticipantsOriginal(int index) =>
      participantsOriginal.removeAt(index);
  void insertAtIndexInParticipantsOriginal(int index, dynamic item) =>
      participantsOriginal.insert(index, item);
  void updateParticipantsOriginalAtIndex(
          int index, Function(dynamic) updateFn) =>
      participantsOriginal[index] = updateFn(participantsOriginal[index]);

  List<dynamic> participantsUpdated = [];
  void addToParticipantsUpdated(dynamic item) => participantsUpdated.add(item);
  void removeFromParticipantsUpdated(dynamic item) =>
      participantsUpdated.remove(item);
  void removeAtIndexFromParticipantsUpdated(int index) =>
      participantsUpdated.removeAt(index);
  void insertAtIndexInParticipantsUpdated(int index, dynamic item) =>
      participantsUpdated.insert(index, item);
  void updateParticipantsUpdatedAtIndex(
          int index, Function(dynamic) updateFn) =>
      participantsUpdated[index] = updateFn(participantsUpdated[index]);

  dynamic loopParticipant;

  dynamic updatedParticipant;

  String targetParticipantPhone = '\"\"';

  int targetParticipantIndex = 0;

  List<dynamic> participantsLocal = [];
  void addToParticipantsLocal(dynamic item) => participantsLocal.add(item);
  void removeFromParticipantsLocal(dynamic item) =>
      participantsLocal.remove(item);
  void removeAtIndexFromParticipantsLocal(int index) =>
      participantsLocal.removeAt(index);
  void insertAtIndexInParticipantsLocal(int index, dynamic item) =>
      participantsLocal.insert(index, item);
  void updateParticipantsLocalAtIndex(int index, Function(dynamic) updateFn) =>
      participantsLocal[index] = updateFn(participantsLocal[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (CreateCheckoutSession)] action in Container widget.
  ApiCallResponse? checkoutResponseCopy;
  // Stores action output result for [Backend Call - API (CreateCheckoutSession)] action in Button widget.
  ApiCallResponse? checkoutResponse;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
