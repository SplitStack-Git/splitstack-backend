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

Future<double> amountwithFee(
  double? amount,
  String? currency,
) async {
  if (amount == null || amount <= 0)
    return 0.0; // Return 0 if amount is null or invalid

  // Step 1: If the amount is greater than 30, add $1
  if (amount > 30) {
    amount += 1.0;
  }

  // Step 2: Apply the currency-based fee percentage
  double feePercent = 0.045; // Default fee for non-AUD or null currency

  // Check if currency is AUD
  if (currency != null && currency.toUpperCase() == 'AUD') {
    feePercent = 0.035; // Set fee to 3.5% for AUD
  }

  // Step 3: Calculate the fee
  double fee = amount * feePercent;

  // Step 4: Calculate the final amount with the fee
  double amountWithFee = amount + fee;

  return amountWithFee; // Return the total amount including the fee
}
