class Folder {
  final String id;
  final String name;
  final String? parentId;
  final String updatedAt;

  Folder({
    required this.id,
    required this.name,
    this.parentId,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'updatedAt': updatedAt,
    };
  }

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'],
      name: json['name'],
      parentId: json['parentId'],
      updatedAt: json['updatedAt'],
    );
  }

  Folder copyWith({
    String? id,
    String? name,
    String? parentId,
    String? updatedAt,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
