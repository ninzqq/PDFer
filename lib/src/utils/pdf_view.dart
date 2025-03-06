import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfView extends StatelessWidget {
  const PdfView({super.key, required this.file});

  final File file;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SfPdfViewer.file(file),
    );
  }
}
