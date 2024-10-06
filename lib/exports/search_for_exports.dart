import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:smart_notes/exports/export_model.dart';

class SearchForExports extends StatefulWidget {
  const SearchForExports({super.key, required this.exports});

  final List<ExportModel> exports;

  @override
  State<SearchForExports> createState() => _SearchForExportsState();
}

class _SearchForExportsState extends State<SearchForExports> {
  TextEditingController controller = TextEditingController();
  List<ExportModel> filteredExports = [];

  @override
  void initState() {
    filteredExports = widget.exports;

    controller.addListener(() {
      setState(() {
        filteredExports = widget.exports.where((export) {
          final query = controller.text.toLowerCase();
          return export.exportTitle.toLowerCase().contains(query);
        }).toList();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: <Widget>[
              TextField(
                  controller: controller,
                  decoration: InputDecoration(
                      labelText: 'Search for exports',
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green)))),
              Expanded(child: ExportSearchResults(results: filteredExports))
            ])));
  }
}

class ExportSearchResults extends StatefulWidget {
  const ExportSearchResults({super.key, required this.results});

  final List<ExportModel> results;

  @override
  State<ExportSearchResults> createState() => _ExportSearchResultsState();
}

class _ExportSearchResultsState extends State<ExportSearchResults> {
  @override
  Widget build(BuildContext context) {
    if (widget.results.isEmpty) {
      return const Center(child: Text('No exports found'));
    }

    void _deletePDF(String path) async {
      File file = File(path);
      if (await file.exists()) {
        file.delete();
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully deleted export file')));
      } else {
        return;
      }
    }

    void renamePDF(String path) async {
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
                                message =
                                    'A file with that name already exists';
                              });
                            } else {
                              File file = File(path);
                              await file.rename(newPath);

                              Navigator.pop(context);
                              setState(() {});
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

    return ListView.builder(
        itemCount: widget.results.length,
        itemBuilder: (context, index) {
          ExportModel export = widget.results[index];
          return ListTile(
            leading: const Icon(
              Icons.picture_as_pdf,
              color: Colors.green,
            ),
            title: Text(export.exportTitle),
            subtitle: Text('${export.dateCreated} - ${export.exportSize}'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              IconButton(
                  onPressed: () {
                    renamePDF(export.exportPath);
                  },
                  icon: const Icon(Icons.abc)),
              IconButton(
                  onPressed: () {
                    _deletePDF(export.exportPath);
                  },
                  icon: const Icon(Icons.delete_forever))
            ]),
            onTap: () {
              openPDF(export.exportPath);
            },
          );
        });
  }
}
