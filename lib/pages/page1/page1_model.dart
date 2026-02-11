import '/components/empty_list_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'page1_widget.dart' show Page1Widget;
import 'package:flutter/material.dart';

class Page1Model extends FlutterFlowModel<Page1Widget> {
  ///  State fields for stateful widgets in this page.

  // Model for emptyList component.
  late EmptyListModel emptyListModel;

  @override
  void initState(BuildContext context) {
    emptyListModel = createModel(context, () => EmptyListModel());
  }

  @override
  void dispose() {
    emptyListModel.dispose();
  }
}
