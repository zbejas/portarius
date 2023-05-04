// ignore_for_file: avoid_dynamic_calls

import 'package:portarius/components/models/docker/detailed_container.dart';

class SimpleContainer {
  String id;
  String image;
  String imageId;
  String? command;
  String? status;
  DateTime? created;
  String? name;
  String? state;
  String? composeStack;
  DetailedContainer? details;

  SimpleContainer({
    required this.id,
    required this.image,
    required this.imageId,
    required this.command,
    required this.status,
    required this.created,
    required this.name,
    required this.state,
    this.composeStack,
    this.details,
  });

  // from json
  factory SimpleContainer.fromJson(Map<String, dynamic> json) {
    return SimpleContainer(
      // make sure types can be null
      id: (json['Id'] ?? '') as String,
      image: (json['Image'] ?? '') as String,
      imageId: (json['ImageID'] ?? '') as String,
      command: (json['Command'] ?? '') as String,
      status: (json['Status'] ?? '') as String,
      created: json['Created'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['Created'] as int) * 1000,
            )
          : null,
      name: ((json['Names'][0] ?? '/') as String).substring(1),
      state: (json['State'] ?? '') as String,
      composeStack: json['Labels']['com.docker.compose.project'] != null
          ? json['Labels']['com.docker.compose.project'] as String
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SimpleContainer && other.id == id;
  }

  @override
  // TODO: implement hashCode
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;
}
