import 'package:flutter/material.dart';
import 'package:smart_notes/notes/note_model.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  List<NoteModel> notes = [];

  Future<void> fetchNotes() async {}

  @override
  void initState() {
    fetchNotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (notes.isNotEmpty){
              return ListView.builder(itemBuilder: (context, index) {
                return ListTile();
              });
            } else {
              return const Center(child: Text("You currently have no notes"),);
            }
          }
        });
  }
}
