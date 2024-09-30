import 'package:flutter/material.dart';
import 'package:smart_notes/notes/note_model.dart';

class SearchResults extends StatefulWidget {
  SearchResults({super.key, required this.resultsList});

  List<NoteModel> resultsList;

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  @override
  Widget build(BuildContext context) {
    List<NoteModel> results = widget.resultsList;
    return ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          if (results.isNotEmpty){
            NoteModel note = results[index];
            return ListTile(
              leading: const Icon(Icons.checklist_outlined),
              title: Text(note.noteTitle),
              onTap: (){},
            );
          } else {
            return const Center(child: Text('No items matching your query'));
          }
        });
  }
}
