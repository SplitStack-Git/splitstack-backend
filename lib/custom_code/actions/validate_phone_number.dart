// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:country_phone_validator/country_phone_validator.dart';

Future<bool> validatePhoneNumber(
  String phone,
  String isoCode,
) async {
  final result = CountryUtils.validatePhoneNumber(phone, isoCode);
  return result;
  // Add your function code here!
}
