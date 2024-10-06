import 'package:flutter/material.dart';
import 'package:smart_notes/notes/note_model.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';
import 'dart:io';
import 'package:speech_to_text/speech_to_text.dart';

class NoteViewingPage extends StatefulWidget {
  const NoteViewingPage({super.key, required this.note});

  final NoteModel note;

  @override
  State<NoteViewingPage> createState() => _NoteViewingPageState();
}

class _NoteViewingPageState extends State<NoteViewingPage> {
  bool isToolbarExpanded = true;
  QuillController _quillController = QuillController.basic();
  late SpeechToText _speech;
  bool isListening = false;

  Future<void> saveChanges() async {
    String noteId = widget.note.noteId;
    String noteTitle = widget.note.noteTitle;
    String noteCategory = widget.note.noteType;
    final noteContent = jsonEncode(_quillController.document.toDelta().toJson);
    final directory = await getApplicationDocumentsDirectory();
    final note = NoteModel(
      noteId: noteId,
      noteTitle: noteTitle,
      noteType: noteCategory,
      noteContent: noteContent,
      dateCreated: DateTime.now()
    );
    final file = File('${directory.path}/$noteTitle.json');
    await file.writeAsString(jsonEncode(note.toJson()));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Changes Saved Successfully')));
    Navigator.pushNamedAndRemoveUntil(
        context, '/home', (Route<dynamic> route) => false);
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

  void _setToolbarState() {
    setState(() {
      isToolbarExpanded = !isToolbarExpanded;
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

  void getNoteContent(){
    final document = Document.fromJson(jsonDecode(widget.note.noteContent));
    _quillController = QuillController(document: document, selection: const TextSelection.collapsed(offset: 0));
  }

  @override
  void initState() {
    getNoteContent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NoteModel note = widget.note;
    return Scaffold(
      appBar: AppBar(
        title: Text(note.noteTitle),
        actions: [
          IconButton(
              onPressed: _setToolbarState,
              icon: isToolbarExpanded
                  ? const Icon(Icons.close_fullscreen)
                  : const Icon(Icons.open_in_full_outlined)),
          IconButton(
              onPressed: _exportToPDF, icon: const Icon(Icons.picture_as_pdf)),
          IconButton(
            onPressed: saveChanges,
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
