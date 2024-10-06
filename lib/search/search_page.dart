import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
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
  bool isLoading = true;

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

  Future<void> fetchNotes() async {
    final directory = await getApplicationDocumentsDirectory();
    final noteFiles =
        directory.listSync().where((file) => file.path.endsWith('.json'));
    List<NoteModel> loadedNotes = [];
    for (var file in noteFiles) {
      final noteContent = await File(file.path).readAsString();
      final noteJson = jsonDecode(noteContent);
      loadedNotes.add(NoteModel.fromJson(noteJson));
    }
    setState(() {
      notes = loadedNotes;
      isLoading = false; // Make sure to stop loading after fetching notes
    });
  }

  @override
  void initState() {
    fetchNotes();
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
          decoration: InputDecoration(
            labelText: 'Search term',
            icon: const Icon(Icons.search),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.green)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.green)),
          ),
        ),
        Expanded(child: SearchResults(resultsList: notes))
      ],
    );
  }
}
