/*
    Volume data
*/
class Mount {
  String? name;
  String source;
  String destination;
  String? driver;
  String? mode;

  Mount({
    required this.name,
    required this.source,
    required this.destination,
    required this.driver,
    required this.mode,
  });

  factory Mount.fromJson(Map<String, dynamic> json) {
    return Mount(
      name: json['Name'] != null ? json['Name'] as String : null,
      source: json['Source'] as String,
      destination: json['Destination'] as String,
      driver: json['Driver'] != null ? json['Driver'] as String : null,
      mode: json['Mode'] != null ? json['Mode'] as String : null,
    );
  }
}
