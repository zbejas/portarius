class PortainerEndpoint {
  String name;
  String id;

  PortainerEndpoint({
    required this.name,
    required this.id,
  });

  factory PortainerEndpoint.fromJson(Map<dynamic, dynamic> json) {
    return PortainerEndpoint(
      name: json['Name'] as String,
      id: (json['Id'] as int).toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Id': int.parse(id),
    };
  }
}
