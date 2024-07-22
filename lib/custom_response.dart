import 'dart:convert';

class CustomResponse {
  final int statusCode;
  final String body;

  CustomResponse({required this.statusCode, required this.body});

  factory CustomResponse.fromJson(Map<String, dynamic> json) {
    return CustomResponse(
      statusCode: json['statusCode'],
      body: jsonEncode(json['body']),
    );
  }
}
