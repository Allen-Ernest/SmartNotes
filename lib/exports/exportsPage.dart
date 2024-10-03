import 'package:flutter/material.dart';
import 'package:smart_notes/exports/export_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

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
    if (isPermissionGranted){
      final directory = getExternalStorageDirectory();
    }
  }
  Future<bool> _requestPermission() async {
    await Permission.storage.request();
    if (await Permission.storage.isGranted){
      return true;
    }
    return false;
  }
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
