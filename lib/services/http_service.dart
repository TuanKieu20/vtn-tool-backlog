import 'dart:convert';

import 'package:flutter/foundation.dart' as foundation;

import 'package:http/http.dart' as http;

import 'package:get/get.dart';
import 'package:vtn_web_backlog/constants/app_constants.dart';

class ApiClient {
  ApiClient() {
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }
  final String appBaseUrl = AppConstants.baseUrl;
  final String noInternetMessage =
      'Connection to API server failed due to internet connection';
  final String invalidToken = 'Invalid token specified! Please login again!';
  final int timeoutInSeconds = 60;

  late String token;
  late Map<String, String> _mainHeaders;

  void updateHeader(String token) {
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  Future<Response> getData(
    String? otherURL,
    String uri, {
    Map<String, String>? headers,
  }) async {
    try {
      final String url = otherURL != null ? otherURL + uri : appBaseUrl + uri;

      // if (foundation.kDebugMode) {
      //   print('GET URL: $url');
      //   print('GET Headers: $headers');
      // }

      final http.Response response0 = await http
          .get(
            Uri.parse(url),
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));

      Response response;
      if (response0.body.isNotEmpty) {
        response = handleResponse(response0);
      } else {
        response = Response(
            statusCode: response0.statusCode,
            statusText: response0.statusCode == 200 ? 'Success' : 'False');
      }

      // if (foundation.kDebugMode) {
      //   print('[${response.statusCode}] $uri\n\n${response.body}');
      // }
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postData(
    String? otherURL,
    String uri,
    dynamic body, {
    Map<String, String>? headers,
    bool isJson = false, // Chọn kiểu JSON hoặc x-www-form-urlencoded
  }) async {
    try {
      final String url = otherURL != null ? otherURL + uri : appBaseUrl + uri;

      // Kiểm tra headers, đảm bảo không ghi đè toàn bộ headers
      headers ??= {};
      if (isJson) {
        body = jsonEncode(body);
        headers['Content-Type'] = 'application/json';
      } else {
        if (body is Map<String, dynamic>) {
          body = body.entries
              .map((e) =>
                  '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
              .join('&');
        } else {
          throw ArgumentError(
              'Body must be a Map<String, dynamic> when isJson=false');
        }
        headers['Content-Type'] = 'application/x-www-form-urlencoded';
      }

      // if (foundation.kDebugMode) {
      //   print('POST URL: $url');
      //   print('POST Headers: $headers');
      //   print('POST Body: $body');
      // }

      final http.Response response0 = await http
          .post(
            Uri.parse(url),
            body: body,
            headers: headers,
          )
          .timeout(Duration(seconds: timeoutInSeconds));

      Response response;
      if (response0.body.isNotEmpty) {
        response = handleResponse(response0);
      } else {
        response = Response(
            statusCode: response0.statusCode,
            statusText: response0.statusCode == 200 ? 'Success' : 'False');
      }

      // if (foundation.kDebugMode) {
      //   print('[${response.statusCode}] $uri\n\n${response.body}');
      // }
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> patchData(
      String? otherURL,
      String uri,
      dynamic body, {
        Map<String, String>? headers,
        bool isJson = false, // Chọn giữa JSON và x-www-form-urlencoded
      }) async {
    try {
      final String url = otherURL != null ? otherURL + uri : appBaseUrl + uri;

      // Xử lý dữ liệu gửi lên
      String encodedBody;
      if (isJson) {
        encodedBody = jsonEncode(body);
        headers = {...?headers, 'Content-Type': 'application/json'};
      } else {
        encodedBody = body.entries
            .map((e) =>
        '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
            .join('&');
        headers = {
          ...?headers,
          'Content-Type': 'application/x-www-form-urlencoded'
        };
      }

      // if (foundation.kDebugMode) {
      //   print('PATCH URL: $url');
      //   print('PATCH Headers: $headers');
      //   print('PATCH Body: $encodedBody');
      // }

      final http.Response response0 = await http
          .patch(
        Uri.parse(url),
        body: encodedBody,
        headers: headers ?? _mainHeaders,
      )
          .timeout(Duration(seconds: timeoutInSeconds));

      Response response;
      if (response0.body.isNotEmpty) {
        response = handleResponse(response0);
      } else {
        response = Response(
            statusCode: response0.statusCode,
            statusText: response0.statusCode == 200 ? 'Success' : 'False');
      }

      // if (foundation.kDebugMode) {
      //   print('[${response.statusCode}] $uri\n\n${response.body}');
      // }
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Response handleResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      // logger.e(e);
    }
    Response response0 = Response(
      body: body ?? response.body,
      bodyString: response.body,
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );
    if (response0.statusCode != 200 &&
        response0.body != null &&
        response0.body is! String) {
      if (response0.body.toString().startsWith('{errors: [{code:')) {
        // ErrorResponse _errorResponse = ErrorResponse.fromJson(_response.body);
        response0 = Response(
            statusCode: response0.statusCode,
            body: response0.body,
            statusText: 'Message error');
      } else if (response0.body.toString().startsWith('{message')) {
        response0 = Response(
            statusCode: response0.statusCode,
            body: response0.body,
            statusText: response0.body['message']);
      }
    } else if (response0.statusCode != 200 && response0.body == null) {
      response0 = Response(statusCode: 0, statusText: noInternetMessage);
    } else if (response0.statusCode != 200) {
      // ApiChecker.checkApi(_response);
      response0 = Response(statusCode: 0, statusText: invalidToken);
    }
    return response0;
  }
}
