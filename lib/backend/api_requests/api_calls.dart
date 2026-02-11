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
    String? organiserAccountId = '',
    String? successUrl = '',
    String? cancelUrl = '',
  }) async {
    // Build JSON body dynamically using actual parameters
    final requestBodyMap = <String, dynamic>{
      'amount_cents': amountCents ?? 0,
      'currency': (currency ?? 'AUD').toLowerCase(),
      'stack_id': stackId ?? '',
    };
    
    // Only include optional fields if they are provided
    if (participantId != null && participantId!.isNotEmpty) {
      requestBodyMap['participant_id'] = participantId!;
    }
    if (organiserAccountId != null && organiserAccountId!.isNotEmpty) {
      requestBodyMap['organiser_account_id'] = organiserAccountId!;
    }
    if (successUrl != null && successUrl!.isNotEmpty) {
      requestBodyMap['success_url'] = successUrl!;
    }
    if (cancelUrl != null && cancelUrl!.isNotEmpty) {
      requestBodyMap['cancel_url'] = cancelUrl!;
    }
    
    final ffApiRequestBody = json.encode(requestBodyMap);
    
    // Debug: Log the amount being sent to Stripe
    if (kDebugMode) {
      print('Stripe Checkout - Amount: ${amountCents ?? 0} cents (${(amountCents ?? 0) / 100} ${currency ?? 'AUD'})');
      print('Stripe Checkout - Request Body: $ffApiRequestBody');
    }
    
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
