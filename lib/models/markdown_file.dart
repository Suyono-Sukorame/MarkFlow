class MarkdownFile {
  final String id;
  final String name;
  final String content;
  final String? folderId;
  final List<String> tags;
  final bool isFavorite;
  final String updatedAt;
  final String size;

  MarkdownFile({
    required this.id,
    required this.name,
    required this.content,
    this.folderId,
    required this.tags,
    required this.isFavorite,
    required this.updatedAt,
    required this.size,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'content': content,
      'folderId': folderId,
      'tags': tags,
      'isFavorite': isFavorite,
      'updatedAt': updatedAt,
      'size': size,
    };
  }

  factory MarkdownFile.fromJson(Map<String, dynamic> json) {
    return MarkdownFile(
      id: json['id'],
      name: json['name'],
      content: json['content'],
      folderId: json['folderId'],
      tags: List<String>.from(json['tags'] ?? []),
      isFavorite: json['isFavorite'] ?? false,
      updatedAt: json['updatedAt'],
      size: json['size'],
    );
  }

  MarkdownFile copyWith({
    String? id,
    String? name,
    String? content,
    String? folderId,
    List<String>? tags,
    bool? isFavorite,
    String? updatedAt,
    String? size,
  }) {
    return MarkdownFile(
      id: id ?? this.id,
      name: name ?? this.name,
      content: content ?? this.content,
      folderId: folderId ?? this.folderId,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      updatedAt: updatedAt ?? this.updatedAt,
      size: size ?? this.size,
    );
  }
}
