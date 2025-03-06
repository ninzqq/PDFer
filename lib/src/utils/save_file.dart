import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

Future<void> saveFile(String filePath) async {
  final downloadsDir = Directory('/storage/emulated/0/Download');
  final PdfDocument document =
      PdfDocument(inputBytes: File(filePath).readAsBytesSync());

  final outputPath = '${downloadsDir.path}/output.pdf';
  await File(outputPath).writeAsBytes(await document.save());

  document.dispose();
}
