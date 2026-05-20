import 'dart:convert';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class CreateCheckoutSessionCall {
  static Future<ApiCallResponse> call({
    int? amountCents = 0,
    String? currency = 'AUD',
    String? stackId = '',
    String? participantId = '',
    String? successUrl = '',
    String? cancelUrl = '',
  }) async {
    final ffApiRequestBody = '''
{
  "amount_cents": ${amountCents},
  "currency": "aud",
  "stack_id": "x7dguMEIFvyXB3Xzb6JS",
  "participant_id": "2PwM3q1dyxXIJsm1etTD_0409995509",
  "success_url": "${escapeStringForJson(successUrl)}",
  "cancel_url": "${escapeStringForJson(cancelUrl)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'CreateCheckoutSession',
      apiUrl:
          'https://splitstack-backend.vercel.app/api/create-checkout-session',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? checkoutUrl(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.checkout_url''',
      ));
}

class EnsureConnectAccountCall {
  static Future<ApiCallResponse> call() async {
    final ffApiRequestBody = '''
{
  "organiser_id": "[currentUserUid]"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'EnsureConnectAccount',
      apiUrl:
          'https://splitstack-backend.vercel.app/api/ensure-connect-account',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? status(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.status''',
      ));
  static String? onboardingurl(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.onboarding_url''',
      ));
}

class SubmitStripeOnboardingCall {
  static Future<ApiCallResponse> call({
    String? currentUserId = '',
    String? onbFirstName = '',
    String? onbLastName = '',
    String? onbEmail = '',
    String? onbPhone = '',
    String? onbDob = '',
    String? onbStreet1 = '',
    String? onbStreet2 = '',
    String? onbCity = '',
    String? onbState = '',
    String? onbPostcode = '',
    String? onbCountry = '',
    String? onbAccountHolderName = '',
    String? onbBsb = '',
    String? onbAccountNumber = '',
    String? onbUsage = '',
    bool? onbConsentAccepted,
  }) async {
    final ffApiRequestBody = '''
{
  "userId": "${escapeStringForJson(currentUserId)}",
  "onbFirstName": "${escapeStringForJson(onbFirstName)}",
  "onbLastName": "${escapeStringForJson(onbLastName)}",
  "onbEmail": "${escapeStringForJson(onbEmail)}",
  "onbPhone": "${escapeStringForJson(onbPhone)}",
  "onbDob": "${escapeStringForJson(onbDob)}",
  "onbStreet1": "${escapeStringForJson(onbStreet1)}",
  "onbStreet2": "${escapeStringForJson(onbStreet2)}",
  "onbCity": "${escapeStringForJson(onbCity)}",
  "onbState": "${escapeStringForJson(onbState)}",
  "onbPostcode": "${escapeStringForJson(onbPostcode)}",
  "onbCountry": "${escapeStringForJson(onbCountry)}",
  "onbAccountHolderName": "${escapeStringForJson(onbAccountHolderName)}",
  "onbBsb": "${escapeStringForJson(onbBsb)}",
  "onbAccountNumber": "${escapeStringForJson(onbAccountNumber)}",
  "onbUsage": "${escapeStringForJson(onbUsage)}",
  "onbConsentAccepted": "${onbConsentAccepted}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'SubmitStripeOnboarding',
      apiUrl: 'https://splitstack-backend.vercel.app/api/submit-onboarding',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  if (item is DocumentReference) {
    return item.path;
  }
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
