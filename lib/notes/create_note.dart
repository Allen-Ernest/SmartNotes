import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:speech_to_text/speech_to_text.dart';

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

  Future<void> _saveNote() async {}

  void _exportToPDF() {}

  @override
  initState() {
    _speech = SpeechToText();
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
