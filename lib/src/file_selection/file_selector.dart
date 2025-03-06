import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';

Future<List<File>> pickFiles({required bool allowMultiple}) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: allowMultiple,
    );

    if (result != null) {
      // Handle selected files
      final files = result.files;
      return files.map((file) => File(file.path!)).toList();
    }
  } catch (e) {
    Logger().e('Error picking files: $e');
  }

  // Return empty list if no files were selected or an error occurred
  return List.empty();
}
