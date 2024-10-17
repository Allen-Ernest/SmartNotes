import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_notes/exports/export_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_notes/exports/search_for_exports.dart';

class ExportsPage extends StatefulWidget {
  const ExportsPage({super.key});

  @override
  State<ExportsPage> createState() => _ExportsPageState();
}

class _ExportsPageState extends State<ExportsPage> {
  List<ExportModel> pdfExports = [];
  bool isLoading = true;

  void _fetchPDFExports() async {
    bool isPermissionGranted = await _requestPermission();
    if (isPermissionGranted) {
      final directory = await getExternalStorageDirectory();
      final path = Directory('${directory!.path}/PDF exports');

      if (!(await path.exists())) {
        setState(() {
          pdfExports = [];
          isLoading = false;
        });
        return;
      }
      final exportFiles =
          path.listSync().where((file) => file.path.endsWith('.pdf'));
      List<ExportModel> fetchedExports = [];
      for (var export in exportFiles) {
        final exportFile = File(export.path);
        final exportPath = export.path;
        final exportTitle = exportFile.path.split('/').last.split('.').first;
        final exportSize = await exportFile.length();
        final fileStat = await exportFile.stat();
        final creationDate = fileStat.changed;
        final exportModel = ExportModel(
            exportTitle: exportTitle,
            exportPath: exportPath,
            dateCreated: creationDate,
            exportSize: exportSize.toString());
        fetchedExports.add(exportModel);
      }
      setState(() {
        pdfExports = fetchedExports;
        isLoading = false;
      });
    }
  }

  void _deletePDF(String path) async {
    File file = File(path);
    if (await file.exists()) {
      file.delete();
      _fetchPDFExports();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully deleted export file')));
    } else {
      return;
    }
  }

  void _renamePDF(String path) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setDialogState) {
              TextEditingController controller = TextEditingController();
              String message = '';
              var height = MediaQuery.of(context).size.height;
              return AlertDialog(
                title: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Rename File'),
                    ]),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                          labelText: 'New name',
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(13),
                              borderSide:
                                  const BorderSide(color: Colors.green)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(13),
                              borderSide:
                                  const BorderSide(color: Colors.green))),
                    ),
                    SizedBox(height: height * 0.03),
                    Text(message)
                  ],
                ),
                actions: <TextButton>[
                  TextButton(
                      onPressed: () async {
                        String newName = controller.text.trim();
                        if (newName.isEmpty) {
                          setDialogState(() {
                            message = "File name can't be empty";
                          });
                        } else if (newName.contains('/')) {
                          setDialogState(() {
                            message = 'File name cannot contain slashes';
                          });
                        } else {
                          String newPath =
                              '${path.substring(0, path.lastIndexOf('/'))}/$newName.pdf';
                          if (await File(newPath).exists()) {
                            setDialogState(() {
                              message = 'A file with that name already exists';
                            });
                          } else {
                            File file = File(path);
                            await file.rename(newPath);

                            _fetchPDFExports();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('File renamed successfully')),
                            );
                          }
                        }
                      },
                      child: const Text('Rename',
                          style: TextStyle(color: Colors.green))),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.green)))
                ],
              );
            }));
  }

  void openPDF(String path) async {
    await OpenFile.open(path);
  }

  Future<bool> _requestPermission() async {
    await Permission.storage.request();
    if (await Permission.storage.isGranted) {
      return true;
    }
    return false;
  }

  Future<void> deleteAllExports() async {}

  @override
  initState() {
    _fetchPDFExports();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Exports'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).push((MaterialPageRoute(
                  builder: (BuildContext context) =>
                      SearchForExports(exports: pdfExports))));
            },
            icon: const Icon(Icons.search, color: Colors.green),
          ),
          IconButton(
            onPressed: () {
              deleteAllExports();
            },
            icon: const Icon(Icons.delete_forever, color: Colors.green),
          )
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.green),
            )
          : pdfExports.isEmpty
              ? const Center(
                  child: Text('No exports'),
                )
              : ListView.builder(
                  itemCount: pdfExports.length,
                  itemBuilder: (context, index) {
                    ExportModel exportModel = pdfExports[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.green,
                      ),
                      title: Text(exportModel.exportTitle),
                      subtitle: Text(
                          '${exportModel.dateCreated} - ${exportModel.exportSize}'),
                      trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                                onPressed: () {
                                  _renamePDF(exportModel.exportPath);
                                },
                                icon: const Icon(Icons.abc)),
                            IconButton(
                                onPressed: () {
                                  _deletePDF(exportModel.exportPath);
                                },
                                icon: const Icon(Icons.delete_forever))
                          ]),
                      onTap: () {
                        openPDF(exportModel.exportPath);
                      },
                    );
                  }),
    );
  }
}
