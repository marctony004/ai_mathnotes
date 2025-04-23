import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../folder_system/folder_model.dart';
import '../folder_system/folder_repository.dart';
import '../folder_system/note_editor_page.dart';

class CreateNotebookPage extends StatefulWidget {
  const CreateNotebookPage({super.key});

  @override
  State<CreateNotebookPage> createState() => _CreateNotebookPageState();
}

class _CreateNotebookPageState extends State<CreateNotebookPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedSubject = '';
  Color _selectedColor = Colors.blue;

  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.teal,
  ];

  final List<String> _subjects = [
    'Algebra',
    'Geometry',
    'Calculus',
    'Statistics',
    'Trigonometry',
    'Linear Algebra',
  ];

  void _saveNotebook() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notebook title is required")),
      );
      return;
    }

    final newFolder = Folder(
      id: UniqueKey().toString(),
      name: title,
      description: _descriptionController.text.trim(),
      subject: _selectedSubject,
      colorValue: _selectedColor.value,
      notes: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final repo = FolderRepository();
    repo.addFolder(newFolder);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorPage(
          folder: newFolder,
          onNoteSaved: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Notebook"),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const Text("📘 Notebook Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Notebook Title',
                  hintText: 'e.g., Calculus I',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add a brief description of this notebook',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _selectedSubject.isEmpty ? null : _selectedSubject,
                items: _subjects.map((subject) {
                  return DropdownMenuItem<String>(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedSubject = value ?? ''),
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              const Text("Notebook Color",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: _colorOptions.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: CircleAvatar(
                      backgroundColor: color,
                      radius: 20,
                      child: _selectedColor == color
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),
              const Text("Advanced Options",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: implement syllabus import
                      },
                      child: const Text("Import from Syllabus"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: implement calendar sync
                      },
                      child: const Text("Connect to Calendar"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Create Notebook"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _saveNotebook,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
