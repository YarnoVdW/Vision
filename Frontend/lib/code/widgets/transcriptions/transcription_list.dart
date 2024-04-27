import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:thelab/code/widgets/transcriptions/transcription_item.dart';
import 'package:thelab/pages/transcription_page.dart';

class TranscriptionList extends StatefulWidget {
  const TranscriptionList({Key? key}) : super(key: key);

  @override
  State<TranscriptionList> createState() => _TranscriptionListState();
}

class _TranscriptionListState extends State<TranscriptionList> {
  late Future<List<File>> filesFuture;
  final TextEditingController _fileNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filesFuture = _loadFiles();
  }

  Future<List<File>> _loadFiles() async {
    try {
      Directory directory = Directory(
          "${(await getApplicationDocumentsDirectory()).path}/transcriptions/");

      List<FileSystemEntity> fileList = directory.listSync();

      List<File> files = fileList.whereType<File>().toList().reversed.toList();

      if (files.isEmpty) {
        return [];
      }

      return files;
    } catch (e) {
      return [];
    }
  }

  Future<void> _loadFileContent(File file) async {
    // Load the data from the file here
    String content = await file.readAsString();
    String title = path.basename(file.uri.toString());

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              TranscriptionPage(content: content, title: title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<File>>(
      future: filesFuture,
      builder: (BuildContext context, AsyncSnapshot<List<File>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error loading files: ${snapshot.error}');
        } else {
          List<File> files = snapshot.data!;
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: files.isNotEmpty
                      ? files
                          .map(
                            (file) => TranscriptionListItem(
                                file: file,
                                onTap: () => _loadFileContent(file),
                                onLongPress: () => _renameFile(context, file),
                                onHorizontalDragEnd: () =>
                                    _deleteFile(context, file)),
                          )
                          .toList()
                      : [
                          SizedBox(
                            height: constraints.maxHeight,
                            // Set height to match the height of SingleChildScrollView
                            child: Container(
                              alignment: Alignment.center,
                              child: const Text("No transcriptions found"),
                            ),
                          ),
                        ],
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<void> _renameFile(BuildContext context, File file) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter New File Name'),
          content: TextField(
            controller: _fileNameController,
            decoration: const InputDecoration(hintText: 'New File Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Rename'),
              onPressed: () {
                String newFileName = _fileNameController.text.trim();
                // You can handle renaming logic here
                String directory = file.parent.path;
                // Construct the new file path with the new file name
                String newPath = '$directory/$newFileName';
                // Rename the file
                file.renameSync(newPath);
                print('File renamed to: $newPath');
                // Optionally, you can notify the user that the file has been renamed
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('File renamed')),
                );
                setState(() {
                  filesFuture = _loadFiles();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteFile(BuildContext context, File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File deleted successfully.')),
        );
        setState(() {
          filesFuture = _loadFiles();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File does not exist.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting file: $e')),
      );
    }
  }
}
