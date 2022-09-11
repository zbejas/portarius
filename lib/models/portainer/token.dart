// To parse this JSON data, do
//
//     final token = tokenFromJson(jsonString);
import 'dart:convert';

import 'package:hive/hive.dart';

part '../hive/token.g.dart';

Token tokenFromJson(String str) => Token.fromJson(json.decode(str));

String tokenToJson(Token data) => json.encode(data.toJson());

@HiveType(typeId: 1, adapterName: 'TokenAdapter')
class Token {
  Token({
    required this.jwt,
    required this.manuallySet,
  });

  @HiveField(0)
  String jwt;

  @HiveField(1)
  bool manuallySet;

  factory Token.fromJson(Map<String, dynamic> json) => Token(
        jwt: json["jwt"],
        manuallySet: json["manuallySet"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "jwt": jwt,
        "manuallySet": manuallySet,
      };

  Map<String, String> getHeaders() {
    if (manuallySet) {
      return {
        'X-API-Key': jwt,
      };
    }
    return {
      'Authorization': 'Bearer $jwt',
    };
  }

  bool get hasJwt => jwt.isNotEmpty;
}
