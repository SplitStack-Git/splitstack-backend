import '/backend/api_requests/api_calls.dart';
import '/components/empty_list_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'page1_widget.dart' show Page1Widget;
import 'package:flutter/material.dart';

class Page1Model extends FlutterFlowModel<Page1Widget> {
  ///  Local state fields for this page.

  bool isCreatingStack = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (EnsureConnectAccount)] action in Button widget.
  ApiCallResponse? ensureConnectResponse;
  // Model for emptyList component.
  late EmptyListModel emptyListModel1;
  // Model for emptyList component.
  late EmptyListModel emptyListModel2;

  @override
  void initState(BuildContext context) {
    emptyListModel1 = createModel(context, () => EmptyListModel());
    emptyListModel2 = createModel(context, () => EmptyListModel());
  }

  @override
  void dispose() {
    emptyListModel1.dispose();
    emptyListModel2.dispose();
  }
}
