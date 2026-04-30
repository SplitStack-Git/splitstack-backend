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

Future documentCreate(
  List<ParticipantsStruct>? data,
  DocumentReference? stackID,
) async {
  if (data == null || data.isEmpty || stackID == null) {
    return;
  }

  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('participants');

  ParticipantsStruct? organiserItem;

  for (final item in data) {
    if (item.userID != null && item.userID!.trim().isNotEmpty) {
      organiserItem = item;
      continue;
    }

    // 🔹 Create unique doc ID (prevents duplicates)
    final uniqueId =
        "${stackID.id}_${item.userID?.isNotEmpty == true ? item.userID : item.phone}";

    await collection.doc(uniqueId).set({
      'display_name': item.name,
      'amount': item.amount,
      'is_locked': item.lock,
      'paid_status': item.paidStatus,
      'payment_linksend': item.paymentLinkSend,
      'pendingPayment': item.pendingPayment,
      'userID': item.userID,
      'isOrganiser': false,
      'stack_id': stackID,
      'phone': item.phone,
      'created_at': Timestamp.now(),
    }, SetOptions(merge: true)); // ✅ prevents overwrite issues
  }

  // 🔹 Create organiser LAST
  if (organiserItem != null) {
    final organiserId = "${stackID.id}_${organiserItem.userID}";

    await collection.doc(organiserId).set({
      'display_name': organiserItem.name,
      'amount': organiserItem.amount,
      'is_locked': organiserItem.lock,
      'paid_status': organiserItem.paidStatus,
      'payment_linksend': organiserItem.paymentLinkSend,
      'pendingPayment': organiserItem.pendingPayment,
      'userID': organiserItem.userID,
      'isOrganiser': true,
      'stack_id': stackID,
      'created_at': Timestamp.now(),
    }, SetOptions(merge: true));
  }
}
