import 'package:flutter/foundation.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final String folderId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.folderId,
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? folderId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      folderId: folderId ?? this.folderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'folderId': folderId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Note.fromMap(Map<String, dynamic> map) => Note(
        id: map['id'],
        title: map['title'],
        content: map['content'],
        folderId: map['folderId'],
        createdAt: DateTime.parse(map['createdAt']),
        updatedAt: DateTime.parse(map['updatedAt']),
      );
}

class Folder {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Note> notes;

  // ✅ Optional metadata fields
  final String? description;
  final String? subject;
  final int? colorValue;

  Folder({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.notes,
    this.description,
    this.subject,
    this.colorValue,
  });

  Folder copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Note>? notes,
    String? description,
    String? subject,
    int? colorValue,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? List.from(this.notes),
      description: description ?? this.description,
      subject: subject ?? this.subject,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'description': description,
        'subject': subject,
        'colorValue': colorValue,
      };

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'],
      name: map['name'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      notes: [], // Notes are handled separately
      description: map['description'],
      subject: map['subject'],
      colorValue: map['colorValue'],
    );
  }
}
