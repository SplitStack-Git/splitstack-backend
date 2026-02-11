import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'page2_widget.dart' show Page2Widget;
import 'package:flutter/material.dart';

class Page2Model extends FlutterFlowModel<Page2Widget> {
  ///  Local state fields for this page.

  String payerName = '\"\"';

  String stackTitle = '\"\"';

  String currency = '\"AUD\"';

  double? totalAmount = 0.0;

  bool includeSelf = true;

  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;
  // Stores action output result for [Custom Action - amountwithFee] action in TextField widget.
  double? amountwithFee;
  // State field(s) for Switch widget.
  bool? switchValue;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  StackRecord? createdStack;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    textFieldFocusNode3?.dispose();
    textController3?.dispose();
  }
}
