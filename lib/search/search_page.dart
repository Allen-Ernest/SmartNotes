import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_notes/notes/note_model.dart';
import 'package:smart_notes/search/search_results.dart';
import 'package:smart_notes/database/database_helper.dart';

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
    List<NoteModel> loadedNotes = await DatabaseHelper().getNotes();
    setState(() {
      notes = loadedNotes;
      isLoading = false;
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
            label: const Icon(Icons.search, color: Colors.green),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.green)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.green)),
          ),
        ),
        isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.green))
            : Expanded(child: SearchResults(resultsList: results))
      ],
    );
  }
}
