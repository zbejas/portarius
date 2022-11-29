class ServerData {
  final String baseUrl;
  final String endpoint;
  final String token;
  final String name;

  ServerData({
    required this.baseUrl,
    required this.endpoint,
    required this.token,
    required this.name,
  });

  factory ServerData.fromJson(Map<String, dynamic> json) {
    return ServerData(
      baseUrl: json['baseUrl'] as String,
      endpoint: json['endpoint'] as String,
      token: json['token'] as String,
      name: (json['name'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseUrl': baseUrl,
      'endpoint': endpoint,
      'token': token,
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ServerData &&
        other.baseUrl == baseUrl &&
        other.token == token;
  }

  @override
  // TODO: implement hashCode
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;
}
