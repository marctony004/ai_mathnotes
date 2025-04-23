import 'package:flutter/material.dart';
import 'folder_model.dart';
import 'note_editor_page.dart';
import 'folder_repository.dart';

class NoteListPage extends StatelessWidget {
  final Folder folder;
  final VoidCallback onNoteSaved;

  const NoteListPage({
    super.key,
    required this.folder,
    required this.onNoteSaved,
  });

  @override
  Widget build(BuildContext context) {
    final notes = FolderRepository.getNotes(folder.id);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // ✅ respects theme

      appBar: AppBar(
        title: Text(folder.name),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("New Note"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NoteEditorPage(
                      folder: folder,
                      onNoteSaved: onNoteSaved,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: notes.isEmpty
                  ? const Center(
                      child: Text("No notes yet",
                          style: TextStyle(color: Colors.white54)),
                    )
                  : ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return Card(
                          color: Colors.deepPurple.shade900,
                          child: ListTile(
                            title: Text(
                              note.title,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              note.content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NoteEditorPage(
                                    folder: folder,
                                    existingNote: note,
                                    onNoteSaved: onNoteSaved,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
