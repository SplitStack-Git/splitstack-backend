import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'onboarding_step1_identity_widget.dart'
    show OnboardingStep1IdentityWidget;
import 'package:flutter/material.dart';

class OnboardingStep1IdentityModel
    extends FlutterFlowModel<OnboardingStep1IdentityWidget> {
  ///  Local state fields for this page.

  DateTime? dob;

  String? firstNameError;

  String? lastNameError;

  String? dobError;

  String? phoneNumberError;

  String? emailError;

  String? passwordError;

  String? contactNumber;

  String countryCode = '+1';

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - validatePhoneNumber] action in IconButton widget.
  bool? validateNumber;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  DateTime? datePicked;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode4;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode5;
  TextEditingController? passwordTextController;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? passwordTextControllerValidator;

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;
  }

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    textFieldFocusNode3?.dispose();
    textController3?.dispose();

    textFieldFocusNode4?.dispose();
    emailTextController?.dispose();

    textFieldFocusNode5?.dispose();
    passwordTextController?.dispose();
  }
}
