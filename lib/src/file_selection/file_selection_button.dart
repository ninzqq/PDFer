import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pdfer/src/file_selection/file_selector.dart';

class FileSelectionButton extends StatelessWidget {
  final bool allowMultiple;
  final Function(List<File>) onFilesSelected;

  const FileSelectionButton({
    super.key,
    this.allowMultiple = false,
    required this.onFilesSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final List<File> files =
            await pickFiles(allowMultiple: allowMultiple).then((files) {
          onFilesSelected(files);
          return files;
        }).catchError((error) {
          Logger().e(error);
          return List<File>.empty();
        });

        Logger().d(files);
      },
      child:
          Text('Select a file', style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
