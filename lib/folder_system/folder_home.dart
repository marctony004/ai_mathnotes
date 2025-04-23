import 'package:flutter/material.dart';
import 'folder_model.dart';
import 'note_list_page.dart';
import 'folder_repository.dart';
import '../theme/settings_page.dart';

class FolderHomePage extends StatefulWidget {
  const FolderHomePage({super.key});

  @override
  State<FolderHomePage> createState() => _FolderHomePageState();
}

class _FolderHomePageState extends State<FolderHomePage> {
  final FolderRepository _repo = FolderRepository();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _addFolderDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Create New Folder',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: TextField(
          controller: controller,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Folder name',
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white54),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: Theme.of(context).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                                final now = DateTime.now();
                final newFolder = Folder(
                  id: now.millisecondsSinceEpoch.toString(),
                  name: name,
                  createdAt: now,
                  updatedAt: now, // ✅ This fixes the error
                  notes: [],
                );

                setState(() => _repo.addFolder(newFolder));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _openFolder(Folder folder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteListPage(
          folder: folder,
          onNoteSaved: _refreshUI,
        ),
      ),
    );
  }

  void _refreshUI() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final folders = _repo.getAllFolders();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: Drawer(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                '📁 Folders',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
            ),
            ...folders.map((folder) => ListTile(
                  leading: Icon(Icons.folder, color: Theme.of(context).iconTheme.color),
                  title: Text(folder.name, style: Theme.of(context).textTheme.bodyLarge),
                  onTap: () {
                    Navigator.pop(context);
                    _openFolder(folder);
                  },
                )),
            const Divider(),
            ListTile(
              leading: Icon(Icons.settings, color: Theme.of(context).iconTheme.color),
              title: Text("Settings", style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('📁 Your Math Folders'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addFolderDialog,
          ),
        ],
      ),
      body: folders.isEmpty
          ? Center(
              child: Text(
                'No folders yet. Tap + to create one!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: folders.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 4 / 3,
                ),
                itemBuilder: (context, index) {
                  final folder = folders[index];
                  return GestureDetector(
                    onTap: () => _openFolder(folder),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.folder, size: 40, color: Colors.white),
                          const SizedBox(height: 8),
                          Text(
                            folder.name,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            '${folder.notes.length} note(s)',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
