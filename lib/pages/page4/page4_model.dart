import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'page4_widget.dart' show Page4Widget;
import 'package:flutter/material.dart';

class Page4Model extends FlutterFlowModel<Page4Widget> {
  ///  Local state fields for this page.

  List<String> sendToAllLinks = [];
  void addToSendToAllLinks(String item) => sendToAllLinks.add(item);
  void removeFromSendToAllLinks(String item) => sendToAllLinks.remove(item);
  void removeAtIndexFromSendToAllLinks(int index) =>
      sendToAllLinks.removeAt(index);
  void insertAtIndexInSendToAllLinks(int index, String item) =>
      sendToAllLinks.insert(index, item);
  void updateSendToAllLinksAtIndex(int index, Function(String) updateFn) =>
      sendToAllLinks[index] = updateFn(sendToAllLinks[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (CreateCheckoutSession)] action in Button widget.
  ApiCallResponse? checkoutResponseCopyCopy;
  // Stores action output result for [Backend Call - API (CreateCheckoutSession)] action in Button widget.
  ApiCallResponse? checkoutResponse;
  // Stores action output result for [Backend Call - API (CreateCheckoutSession)] action in Button widget.
  ApiCallResponse? multiCheckoutSessionRes;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
