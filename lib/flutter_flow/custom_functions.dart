import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/structs/index.dart';
import '/auth/firebase_auth/auth_util.dart';

double? add(List<double>? amount) {
  // agar list null ho ya empty ho
  if (amount == null || amount.isEmpty) {
    return 0.0;
  }

  double sum = 0.0;

  for (double value in amount) {
    sum += value;
  }

  return sum;
}

double? progressbar(
  String? fullamount,
  String? collected,
) {
  // Null ya empty check
  if (fullamount == null ||
      collected == null ||
      fullamount.isEmpty ||
      collected.isEmpty) {
    return 0.0;
  }

  // String → double convert
  final double? full = double.tryParse(fullamount);
  final double? got = double.tryParse(collected);

  // Invalid cases
  if (full == null || got == null || full <= 0) {
    return 0.0;
  }

  // Progress calculation
  double progress = got / full;

  // Clamp between 0 and 1
  return progress.clamp(0.0, 1.0);
}

String? progressbarpercent(
  String? fullamount,
  String? collected,
) {
// Null ya empty check
  if (fullamount == null ||
      collected == null ||
      fullamount.isEmpty ||
      collected.isEmpty) {
    return "0%";
  }

  // String → double convert
  final double? full = double.tryParse(fullamount);
  final double? got = double.tryParse(collected);

  // Invalid cases
  if (full == null || got == null || full <= 0) {
    return "0%";
  }

  // Percentage calculate
  double percent = (got / full) * 100;

  // Limit 0–100
  percent = percent.clamp(0.0, 100.0);

  // Integer percentage return (40%, 60%, etc.)
  return "${percent.round()}%";
}

String? firstLetter(String? name) {
  // make me an function which split the first letter of the name argument value and return it in string
  if (name == null || name.isEmpty) {
    return null;
  }
  return name[0].toUpperCase();
}
