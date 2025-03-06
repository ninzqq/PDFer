import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

Future<void> saveFile(String filePath) async {
  final downloadsDir = Directory('/storage/emulated/0/Download');
  final PdfDocument document =
      PdfDocument(inputBytes: File(filePath).readAsBytesSync());

  String outputPath = '${downloadsDir.path}/output.pdf';

  if (await File(outputPath).exists()) {
    for (int i = 1; i <= 100; i++) {
      outputPath = '${downloadsDir.path}/output($i).pdf';
      if (!await File(outputPath).exists()) {
        break;
      }
    }
  } else {
    outputPath = '${downloadsDir.path}/output.pdf';
  }

  await File(outputPath).writeAsBytes(await document.save());

  document.dispose();
}

Future<void> saveFiles(List<File> files) async {
  final downloadsDir = Directory('/storage/emulated/0/Download');
  int i = 1;

  for (File file in files) {
    final PdfDocument document =
        PdfDocument(inputBytes: File(file.path).readAsBytesSync());

    String outputPath = '${downloadsDir.path}/output$i.pdf';

    if (await File(outputPath).exists()) {
      for (int j = 1; j <= 100; j++) {
        outputPath = '${downloadsDir.path}/output($j).pdf';
        if (!await File(outputPath).exists()) {
          break;
        }
      }
    } else {
      outputPath = '${downloadsDir.path}/output$i.pdf';
    }

    await File(outputPath).writeAsBytes(await document.save());

    document.dispose();
    i++;
  }
}
