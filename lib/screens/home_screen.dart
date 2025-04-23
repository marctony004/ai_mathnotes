import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../folder_system/folder_model.dart';
import '../folder_system/folder_repository.dart';
import '../folder_system/note_editor_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../screens/create_notebook_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FolderRepository folderRepo = FolderRepository();
  File? _avatarImage;
  Folder? _recentFolder;
  bool _sortAlphabetically = false;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
    _loadRecentFolder();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('avatarPath');
    if (path != null && File(path).existsSync()) {
      setState(() {
        _avatarImage = File(path);
      });
    }
  }

  Future<void> _saveAvatar(File image) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatarPath', image.path);
  }

  Future<void> _pickNewAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final imageFile = File(picked.path);
      setState(() => _avatarImage = imageFile);
      await _saveAvatar(imageFile);
    }
  }

  void _loadRecentFolder() {
    final folders = folderRepo.getAllFolders();
    if (folders.isNotEmpty) {
      folders.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      setState(() {
        _recentFolder = folders.first;
      });
    }
  }

  void _createNotebook() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateNotebookPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final folders = folderRepo.getAllFolders();

    final sortedFolders = [...folders];
    sortedFolders.sort((a, b) => _sortAlphabetically
        ? a.name.compareTo(b.name)
        : b.updatedAt.compareTo(a.updatedAt));

    return Scaffold(
      backgroundColor: const Color(0xFFDCF2ED),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "👋 Welcome back!",
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: _pickNewAvatar,
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: _avatarImage != null
                          ? FileImage(_avatarImage!)
                          : const NetworkImage("https://i.imgur.com/BoN9kdC.png") as ImageProvider,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
  onTap: () {
    Navigator.pushNamed(context, '/calendar'); // 👈 You'll need to define this route in `main.dart`
  },
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        const Icon(Icons.calendar_month, color: Colors.teal),
        const SizedBox(width: 10),
        Text(
          "Today: ${DateFormat.yMMMMEEEEd().format(DateTime.now())}",
          style: theme.textTheme.titleMedium?.copyWith(
            decoration: TextDecoration.underline,
            color: Colors.teal[800],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  ),
),

              const SizedBox(height: 24),
              Text("📓 Recently Edited",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _recentFolder == null
                  ? const Text("No notebooks yet.")
                  : ListTile(
                      tileColor: Colors.white,
                      title: Text(_recentFolder!.name),
                      subtitle: Text("Last edited: ${DateFormat.yMMMd().add_jm().format(_recentFolder!.updatedAt)}"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NoteEditorPage(
                              folder: _recentFolder!,
                              onNoteSaved: _loadRecentFolder,
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("📁 Your Folders",
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(_sortAlphabetically ? Icons.sort_by_alpha : Icons.access_time),
                    onPressed: () => setState(() => _sortAlphabetically = !_sortAlphabetically),
                    tooltip: "Sort folders",
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedFolders.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 4 / 3,
                ),
                itemBuilder: (context, index) {
                  final folder = sortedFolders[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NoteEditorPage(
                            folder: folder,
                            onNoteSaved: _loadRecentFolder,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.folder, color: Colors.teal, size: 30),
                          const SizedBox(height: 8),
                          Text(
                            folder.name,
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            "${folder.notes.length} note(s)",
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _createNotebook,
                icon: const Icon(Icons.note_add),
                label: const Text("Create New Notebook"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12), // for spacing

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/syllabus');
                },
                icon: const Icon(Icons.upload_file),
                label: const Text("Import Syllabus"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}