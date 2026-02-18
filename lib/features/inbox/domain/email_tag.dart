/// Email Tag Model
/// Represents custom tags that users can add to emails
library;

import 'package:hive/hive.dart';

part 'email_tag.g.dart';

@HiveType(typeId: 2)
class EmailTag {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String color; // Hex color code

  @HiveField(3)
  final DateTime createdAt;

  EmailTag({
    required this.id,
    required this.name,
    required this.color,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory EmailTag.create(String name, String color) {
    return EmailTag(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      color: color,
    );
  }

  EmailTag copyWith({
    String? id,
    String? name,
    String? color,
    DateTime? createdAt,
  }) {
    return EmailTag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EmailTag.fromJson(Map<String, dynamic> json) {
    return EmailTag(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmailTag && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Preset tag colors for quick selection
class TagColors {
  static const List<String> presets = [
    '#FF6B6B', // Red
    '#4ECDC4', // Teal
    '#45B7D1', // Blue
    '#FFA07A', // Light Salmon
    '#98D8C8', // Mint
    '#F7DC6F', // Yellow
    '#BB8FCE', // Purple
    '#F8B4D9', // Pink
    '#95E1D3', // Aqua
    '#FF8B94', // Rose
    '#FFD93D', // Gold
    '#6BCB77', // Green
  ];

  static String getRandomColor() {
    return presets[DateTime.now().millisecondsSinceEpoch % presets.length];
  }
}
