import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'custom_theme.dart';

class NotesSection extends StatefulWidget {
  const NotesSection({super.key});

  @override
  State<NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends State<NotesSection> {
  final TextEditingController noteController = TextEditingController();
  final TextEditingController noteEditController = TextEditingController();
  final List<Map<String, dynamic>> notes = [];
  int editingNoteIndex = -1;

  void addNote() {
    if (noteController.text.isEmpty) return;

    setState(() {
      notes.add({
        'text': noteController.text,
        'createdAt': DateTime.now(),
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      noteController.clear();
    });
  }

  void updateNote(int index) {
    if (noteEditController.text.isEmpty) return;

    setState(() {
      notes[index]['text'] = noteEditController.text;
      noteEditController.clear();
      editingNoteIndex = -1;
    });
    Navigator.of(context).pop();
  }

  void deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: CustomTheme.primaryColor,
        title: const Text(
          'My Notes',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      hintText: 'Enter your note...',
                      hintStyle: const TextStyle(
                          color: CustomTheme.textLightColor,
                          fontFamily: 'Poppins'
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: CustomTheme.primaryColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: CustomTheme.primaryColor.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: CustomTheme.accentColor),
                      ),
                      filled: true,
                      fillColor: CustomTheme.backgroundColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: addNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomTheme.accentColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  color: CustomTheme.backgroundColor,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(20),
                    title: Text(
                      note['text'],
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: CustomTheme.textColor,
                      ),
                    ),
                    subtitle: Text(
                      'Created: ${DateFormat('yyyy-MM-dd HH:mm').format(note['createdAt'])}',
                      style: TextStyle(
                        color: CustomTheme.textLightColor,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _showDeleteConfirmationDialog(context, index),
                          icon: const Icon(Icons.delete, color: CustomTheme.errorColor),
                        ),
                        IconButton(
                          onPressed: () {
                            noteEditController.text = note['text'];
                            editingNoteIndex = index;
                            _showEditDialog(context);
                          },
                          icon: const Icon(Icons.edit, color: CustomTheme.primaryColor),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Edit your note',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: CustomTheme.textColor,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: TextField(
            controller: noteEditController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: CustomTheme.primaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: CustomTheme.accentColor),
              ),
              hintText: 'Edit your note...',
              filled: true,
              fillColor: CustomTheme.backgroundColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                    color: CustomTheme.errorColor,
                    fontFamily: 'Poppins'
                ),
              ),
            ),
            TextButton(
              onPressed: () => updateNote(editingNoteIndex),
              child: const Text(
                'Save',
                style: TextStyle(
                    color: CustomTheme.primaryColor,
                    fontFamily: 'Poppins'
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Are you sure?',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: CustomTheme.textColor,
            ),
          ),
          content: const Text(
            'Do you want to delete this note? This action cannot be undone.',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: CustomTheme.textLightColor,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                    color: CustomTheme.primaryColor,
                    fontFamily: 'Poppins'
                ),
              ),
            ),
            TextButton(
              onPressed: () => deleteNote(index),
              child: const Text(
                'Delete',
                style: TextStyle(
                    color: CustomTheme.errorColor,
                    fontFamily: 'Poppins'
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}