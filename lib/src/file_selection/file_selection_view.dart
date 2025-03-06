import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfer/src/features/delete/delete.dart';
import 'package:pdfer/src/features/feature_item.dart';
import 'package:pdfer/src/file_selection/file_selection_button.dart';

class FileSelectionView extends StatefulWidget {
  final FeatureItem featureItem;
  final bool allowMultiple;
  const FileSelectionView({
    super.key,
    required this.featureItem,
    this.allowMultiple = false,
  });

  @override
  State<FileSelectionView> createState() => _FileSelectionViewState();
}

class _FileSelectionViewState extends State<FileSelectionView> {
  bool filesSelected = false;
  late List<File> selectedFiles;

  @override
  Widget build(BuildContext context) {
    if (!filesSelected) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(widget.featureItem.description,
              style: Theme.of(context).textTheme.titleLarge),
          FileSelectionButton(
            allowMultiple: widget.allowMultiple,
            onFilesSelected: (files) {
              if (files.isEmpty) return;
              selectedFiles = files;
              setState(() {
                filesSelected = true;
              });
            },
          ),
          const SizedBox(height: 20),
        ],
      );
    } else {
      switch (widget.featureItem.name) {
        case 'Split':
          return const Text('Split');
        case 'Merge':
          return const Text('Merge');
        case 'Rotate':
          return const Text('Rotate');
        case 'Delete':
          return DeleteView(files: selectedFiles);
        default:
          return const Text('Error, feature not found');
      }
    }
  }
}
