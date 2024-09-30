import 'package:flutter/material.dart';
import 'package:smart_notes/notes/note_model.dart';
import 'package:smart_notes/search/search_results.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<NoteModel> notes = [];

  void _filterNotes(String query) {
    setState(() {
      if (query.isEmpty) {
        results = notes;
      } else {
        results = notes
            .where((NoteModel note) =>
                note.noteTitle.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  List<NoteModel> results = [];

  Future<void> _fetchNotes() async {}

  @override
  void initState() {
    _fetchNotes();
    _controller.addListener(() {
      _filterNotes(_controller.text.trim());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
              labelText: 'Search term',
              icon: Icon(Icons.search),
              border: OutlineInputBorder()),
        ),
        Expanded(child: SearchResults(resultsList: notes))
      ],
    );
  }
}
