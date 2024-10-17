import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:smart_notes/notes/note_model.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_notes/database/database_helper.dart';
import 'package:smart_notes/settings/category_model.dart';

class CreateNote extends StatefulWidget {
  const CreateNote({super.key});

  @override
  State<CreateNote> createState() => _CreateNoteState();
}

class _CreateNoteState extends State<CreateNote> {
  bool isToolbarExpanded = true;
  final QuillController _quillController = QuillController.basic();
  late SpeechToText _speech;
  bool isListening = false;
  List<CategoryModel> noteCategories = [];
  TextEditingController categoryController = TextEditingController();

  void fetchNoteCategories() async {
    List<CategoryModel> categories = await DatabaseHelper().getCategories();
    setState(() {
      noteCategories = categories;
    });
  }

  void _startListening() async {
    if (isListening) return;
    String lastRecognizedWords = '';
    await _speech.initialize(
      onStatus: (val) {
        if (val == 'notListening') {
          setState(() {
            isListening = false;
          });
        }
      },
      onError: (val) {
        setState(() {
          isListening = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('An error occurred')));
      },
    );
    setState(() {
      isListening = true;
    });
    _speech.listen(
      onResult: (val) {
        final currentRecognizedWords = val.recognizedWords;

        if (currentRecognizedWords.isNotEmpty) {
          final newWords =
              currentRecognizedWords.replaceFirst(lastRecognizedWords, '');

          if (newWords.isNotEmpty) {
            final index = _quillController.selection.baseOffset;
            _quillController.document.insert(index, newWords);
            _quillController.updateSelection(
                TextSelection.collapsed(offset: index + newWords.length + 1),
                ChangeSource.local);
          }
          lastRecognizedWords = currentRecognizedWords;
          if (val.finalResult) {
            setState(() {
              isListening = false;
            });
          }
        }
      },
    );
  }

  void _stopListening() {
    if (!isListening) return;
    _speech.stop();
    setState(() {
      isListening = false;
    });
  }

  void _setToolbarState() {
    setState(() {
      isToolbarExpanded = !isToolbarExpanded;
    });
  }

  Future<void> _saveNote() async {
    String noteId = const Uuid().v4();
    String? noteTitle = await _getNoteData();
    String noteCategory = categoryController.text.trim();
    final noteContent =
        jsonEncode(_quillController.document.toDelta().toJson());
    if (noteTitle == null || noteTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Title can not be empty')));
      return;
    }
    if (noteCategory.isEmpty) {
      setState(() {
        noteCategory = 'General';
      });
    }

    final note = NoteModel(
        noteId: noteId,
        noteTitle: noteTitle,
        noteType: noteCategory,
        noteContent: noteContent,
        dateCreated: DateTime.now());

    await DatabaseHelper().insertNote(note);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Note Saved Successfully')));
    Navigator.pushNamedAndRemoveUntil(
        context, '/home', (Route<dynamic> route) => false);
  }

  Future<String?> _getNoteData() async {
    TextEditingController controller = TextEditingController();
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) =>
                AlertDialog(
                  title: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text('Save Note')]),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(
                          controller: controller,
                          decoration: InputDecoration(
                              labelText: 'Note Title',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12))),
                        ),
                        SizedBox(height: height * 0.03),
                        DropdownMenu(
                            hintText: 'Select Note Category',
                            controller: categoryController,
                            dropdownMenuEntries: noteCategories
                                .map<DropdownMenuEntry<String>>((category) {
                              return DropdownMenuEntry<String>(
                                  value: category.categoryId,
                                  label: category.categoryTitle,
                                  leadingIcon: Icon(IconData(
                                      category.categoryIcon,
                                      fontFamily: category.fontFamily)));
                            }).toList()),
                        SizedBox(height: height * 0.03),
                        Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.green.withOpacity(0.1)),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.campaign,
                                    color: Colors.green,
                                  ),
                                  Text('You can add new categories in settings',
                                      style: TextStyle(color: Colors.green)),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(controller.text.trim());
                        },
                        child: const Text('Save')),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'))
                  ],
                )));
  }

  void _exportToPDF() async {
    await _requestPermission();

    final folder = await _createFolder();
    final String filePath =
        '${folder.path}/note_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final PDFPageFormat pageFormat = PDFPageFormat.all(
        width: PDFPageFormat.a4.width,
        height: PDFPageFormat.a4.height,
        margin: 10.0);

    PDFConverter pdfConverter = PDFConverter(
        pageFormat: pageFormat,
        document: _quillController.document.toDelta(),
        fallbacks: []);
    await pdfConverter.createDocumentFile(path: filePath);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved successfully to ${folder.path}')));

    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening the PDF: ${result.message}')),
      );
    }
  }

  Future<void> _requestPermission() async {
    await Permission.storage.request();
    if (await Permission.storage.isGranted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage Permission is required')));
  }

  Future<Directory> _createFolder() async {
    Directory? directory;

    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    }

    final path = Directory('${directory!.path}/PDF exports');

    if (!(await path.exists())) {
      await path.create();
    }
    return path;
  }

  @override
  initState() {
    _speech = SpeechToText();
    fetchNoteCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
        actions: <Widget>[
          IconButton(
              onPressed: _setToolbarState,
              icon: isToolbarExpanded
                  ? const Icon(Icons.close_fullscreen)
                  : const Icon(Icons.open_in_full_outlined)),
          IconButton(
              onPressed: _exportToPDF, icon: const Icon(Icons.picture_as_pdf)),
          IconButton(
            onPressed: _saveNote,
            icon: const Icon(Icons.done),
          )
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              QuillToolbar.simple(
                  configurations: QuillSimpleToolbarConfigurations(
                      multiRowsDisplay: isToolbarExpanded,
                      embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                      customButtons: [
                        QuillToolbarCustomButtonOptions(
                            tooltip: "Voice typing",
                            icon: isListening
                                ? const Icon(Icons.mic_off_outlined)
                                : const Icon(Icons.mic_outlined),
                            onPressed:
                                isListening ? _stopListening : _startListening),
                      ]),
                  controller: _quillController),
              Expanded(
                child: QuillEditor.basic(
                    configurations: QuillEditorConfigurations(
                        embedBuilders: FlutterQuillEmbeds.editorBuilders()),
                    controller: _quillController),
              )
            ],
          )),
    );
  }
}
