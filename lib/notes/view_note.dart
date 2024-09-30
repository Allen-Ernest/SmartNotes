import 'package:flutter/material.dart';
import 'package:smart_notes/notes/note_model.dart';

class NoteViewingPage extends StatefulWidget {
  NoteViewingPage({super.key, required this.note});
  NoteModel note;

  @override
  State<NoteViewingPage> createState() => _NoteViewingPageState();
}

class _NoteViewingPageState extends State<NoteViewingPage> {
  @override
  Widget build(BuildContext context) {
    NoteModel note = widget.note;
    return Scaffold(
      appBar: AppBar(title: Text(note.noteTitle)),
    );
  }
}
