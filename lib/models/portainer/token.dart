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
  });

  @HiveField(0)
  String jwt;

  factory Token.fromJson(Map<String, dynamic> json) => Token(
        jwt: json["jwt"],
      );

  Map<String, dynamic> toJson() => {
        "jwt": jwt,
      };

  String getBearerToken() {
    return 'Bearer $jwt';
  }

  bool get hasJwt => jwt.isNotEmpty;
}
