// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets

import 'package:phone_form_field/phone_form_field.dart';

class AppPhoneField extends StatefulWidget {
  final String? errorText;
  final Future Function(String number, String countryCode, dynamic phoneNumber)?
      onChanged;
  final double? width;
  final double? height;
  final String? initialPhoneNumber;
  final bool? noDefaultStyle;

  const AppPhoneField({
    super.key,
    this.errorText,
    this.onChanged,
    this.width,
    this.height,
    this.initialPhoneNumber,
    this.noDefaultStyle,
  });

  @override
  State<AppPhoneField> createState() => _AppPhoneFieldState();
}

class _AppPhoneFieldState extends State<AppPhoneField> {
  late PhoneController controller;

  @override
  void initState() {
    super.initState();
    // Initialize with India as default, or any other default you prefer
    controller = PhoneController(initialValue: PhoneNumber.parse('+91'));
    _updateValue();
  }

  @override
  void didUpdateWidget(covariant AppPhoneField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPhoneNumber != widget.initialPhoneNumber) {
      _updateValue();
    }
  }

  void _updateValue() {
    final String? phone = widget.initialPhoneNumber;
    if (phone == null || phone.isEmpty) {
      // If the number is cleared, we keep the CURRENT flag but clear the number
      final emptyValue =
          PhoneNumber(isoCode: controller.value.isoCode, nsn: '');
      if (controller.value != emptyValue) {
        controller.value = emptyValue;
      }
      return;
    }

    try {
      PhoneNumber newValue;
      if (phone.startsWith('+')) {
        // If it starts with +, parse it as a full international number
        newValue = PhoneNumber.parse(phone);
      } else {
        // If it's just the number part, keep the CURRENTLY SELECTED flag
        newValue = PhoneNumber(isoCode: controller.value.isoCode, nsn: phone);
      }

      // Only update if the result is actually different, to avoid cursor jumps
      if (controller.value != newValue) {
        controller.value = newValue;
      }
    } catch (_) {
      // If parsing fails, don't update to avoid breaking user input
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayError = widget.errorText;
    final bool simple = widget.noDefaultStyle == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: simple ? null : (widget.height ?? 54),
          width: widget.width,
          child: Container(
            decoration: simple
                ? null
                : BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    border: Border.all(
                      color: const Color(0xffe0e3e7),
                    ),
                    color: const Color(0xFFf1f4f8)),
            child: PhoneFormField(
              shouldLimitLengthByCountry: true,
              autovalidateMode: AutovalidateMode.always,
              countrySelectorNavigator: const CountrySelectorNavigator.dialog(),
              countryButtonStyle: CountryButtonStyle(
                showDialCode: true,
                padding: EdgeInsets.only(
                  top: simple ? 0 : 4,
                  bottom: simple ? 0 : 2,
                  left: simple ? 0 : 16,
                ),
                dropdownIconColor: const Color(0xffD4D4D4),
              ),
              controller: controller,
              onChanged: (newValue) {
                widget.onChanged
                    ?.call(newValue.nsn, newValue.countryCode, newValue);
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Number',
                hintStyle:
                    const TextStyle(fontSize: 14, color: Color(0xff57636c)),
                isDense: simple,
                contentPadding:
                    simple ? const EdgeInsets.symmetric(vertical: 8) : null,
              ),
              style: const TextStyle(fontSize: 16),
              textAlignVertical: TextAlignVertical.center,
            ),
          ),
        ),
        if (displayError?.isNotEmpty == true)
          Padding(
            padding:
                EdgeInsets.only(top: simple ? 2 : 8, left: simple ? 0 : 10),
            child: Text(displayError!,
                style: const TextStyle(color: Color(0xffff5963), fontSize: 12)),
          ),
      ],
    );
  }
}
