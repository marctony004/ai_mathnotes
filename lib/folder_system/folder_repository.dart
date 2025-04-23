import 'folder_model.dart';

class FolderRepository {
  static final List<Folder> _folders = [];

  // Add a new folder
  void addFolder(Folder folder) {
    _folders.add(folder);
  }

  // Get all folders
  List<Folder> getAllFolders() {
    return _folders;
  }

  // Get notes for a specific folder
  static List<Note> getNotes(String folderId) {
    return _folders.firstWhere((f) => f.id == folderId).notes;
  }

  // Save or update a note in the folder
  void saveNoteToFolder(String folderId, Note note) {
    final folderIndex = _folders.indexWhere((f) => f.id == folderId);
    if (folderIndex == -1) return;

    final folder = _folders[folderIndex];
    final existingIndex = folder.notes.indexWhere((n) => n.id == note.id);

    if (existingIndex != -1) {
      // Update existing note
      folder.notes[existingIndex] = note;
    } else {
      // Add new note
      folder.notes.add(note);
    }

    _folders[folderIndex] = folder.copyWith(notes: folder.notes);
  }

  // Optional: update a folder's metadata (e.g., title, color, subject)
  void updateFolderMetadata(String folderId, {
    String? name,
    String? description,
    String? subject,
    int? colorValue,
  }) {
    final index = _folders.indexWhere((f) => f.id == folderId);
    if (index != -1) {
      final existing = _folders[index];
      _folders[index] = Folder(
        id: existing.id,
        name: name ?? existing.name,
        description: description ?? existing.description,
        subject: subject ?? existing.subject,
        colorValue: colorValue ?? existing.colorValue,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
        notes: existing.notes,
      );
    }
  }
}
