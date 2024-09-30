import 'package:flutter/material.dart';
import 'package:smart_notes/exports/export_model.dart';

class ExportsPage extends StatefulWidget {
  const ExportsPage({super.key});

  @override
  State<ExportsPage> createState() => _ExportsPageState();
}

class _ExportsPageState extends State<ExportsPage> {
  List<ExportModel> pdfExports = [];

  void _fetchPDFExports() async {}
  bool _isSearchEnabled = false;

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
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.red),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete_forever, color: Colors.red),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: pdfExports.isEmpty
            ? const Center(child: Text('No export files'))
            : ListView.builder(itemBuilder: (context, index) {
                ExportModel exportFile = pdfExports[index];
                return ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: Text(exportFile.exportTitle),
                  subtitle: Text(
                      '${exportFile.dateCreated} - ${exportFile.exportSize}'),
                  onTap: () {},
                  onLongPress: () {},
                );
              }),
      ),
    );
  }
}
