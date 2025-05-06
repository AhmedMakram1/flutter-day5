import 'package:flutter/material.dart';
import 'package:day5/controllers/hive_controller.dart';
import 'package:day5/controllers/sqlite_controller.dart';
import 'package:day5/models/note.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

enum StorageType { hive, sqlite }

class _NotesScreenState extends State<NotesScreen> {
  final SqliteController sqliteController = SqliteController();
  final HiveController hiveController = HiveController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Note> _notes = [];

  StorageType selectedStorage = StorageType.hive;

  void _initHive() async {
    hiveController.init();
  }

  void _loadNotes() async {
    if (selectedStorage == StorageType.sqlite) {
      final notes = await sqliteController.getNotes();
      setState(() {
        _notes = notes;
      });
    } else if (selectedStorage == StorageType.hive) {
      final notes = await hiveController.getNotes();
      setState(() {
        _notes = notes;
      });
    }
  }

  void _addNote() async {
    final note = Note(
      title: _titleController.text,
      description: _descriptionController.text,
    );
    if (selectedStorage == StorageType.sqlite) {
      await sqliteController.insert(note);
    } else if (selectedStorage == StorageType.hive) {
      hiveController.add(note);
    }
    _titleController.clear();
    _descriptionController.clear();
    _loadNotes();
  }

  void deleteNote(int? id) async {
    if (selectedStorage == StorageType.sqlite) {
      await sqliteController.delete(id);
    } else {
      hiveController.delete(id);
    }
    _loadNotes();
  }

  @override
  void initState() {
    super.initState();
    _initHive();
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: Colors.teal,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
          accentColor: Colors.tealAccent,
        ),
        textTheme: Theme.of(context).textTheme.copyWith(
              titleLarge: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
              titleMedium: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
              bodyMedium: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              labelLarge: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Notes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          backgroundColor: Colors.teal,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter note title',
                  prefixIcon: Icon(Icons.title, color: Colors.teal),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter note description',
                  prefixIcon: Icon(Icons.description, color: Colors.teal),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<StorageType>(
                    value: selectedStorage,
                    items: [
                      DropdownMenuItem(
                        value: StorageType.sqlite,
                        child: Text('SQLite', style: Theme.of(context).textTheme.labelLarge),
                      ),
                      DropdownMenuItem(
                        value: StorageType.hive,
                        child: Text('Hive', style: Theme.of(context).textTheme.labelLarge),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStorage = value!;
                      });
                      _loadNotes();
                    },
                    underline: Container(),
                    icon: Icon(Icons.storage, color: Colors.teal),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      hiveController.clear();
                      _loadNotes();
                    },
                    icon: Icon(Icons.clear_all),
                    label: Text('Clear Hive'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _notes.isEmpty
                    ? Center(
                        child: Text(
                          'No notes yet. Add one!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 18,
                              ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _notes.length,
                        itemBuilder: (context, index) {
                          final note = _notes[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                note.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  note.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () {
                                  if (selectedStorage == StorageType.hive) {
                                    deleteNote(index);
                                  } else {
                                    deleteNote(note.id);
                                  }
                                  _loadNotes();
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty ||
                _descriptionController.text.isNotEmpty) {
              _addNote();
            }
          },
          shape: CircleBorder(),
          child: Icon(Icons.add),
          backgroundColor: Colors.teal,
          tooltip: 'Add Note',
        ),
      ),
    );
  }
}