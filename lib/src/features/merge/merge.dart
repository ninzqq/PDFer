import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pdfer/src/utils/pdf_view.dart';
import 'package:pdfer/src/utils/save_file.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';

class MergeView extends StatefulWidget {
  const MergeView({super.key, required this.files});

  final List<File> files;

  @override
  State<MergeView> createState() => _MergeViewState();
}

class _MergeViewState extends State<MergeView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Select two files you want to merge.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: () async {
                  await saveFile(widget.files[0].path).then((value) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'File saved to "/storage/emulated/0/Download/output.pdf"'),
                      ),
                    );
                    Logger().d(
                        'File saved to "/storage/emulated/0/Download/output.pdf"');
                  });

                  // Delete the temporary files
                  final tempDirectory = await getTemporaryDirectory();
                  final tempPath = '${tempDirectory.path}/output.pdf';
                  if (await File(tempPath).exists()) {
                    await File(tempPath).delete().then((value) {
                      Logger().d('Temporary file deleted');
                    });
                  }
                },
                icon: const Icon(Icons.save),
                tooltip: 'Save',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    mergeDocuments();
                    Logger().d(widget.files);
                  },
                  icon: const Icon(Icons.merge_type),
                  tooltip: 'Merge documents'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: widget.files.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: Text(widget.files[index].path),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> mergeDocuments() async {
    if (widget.files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No files selected'),
        ),
      );
      Logger().e('No files selected');
      return;
    } else if (widget.files.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only one file selected'),
        ),
      );
      Logger().e('Only one file selected');
      return;
    }

    // Load the existing PDF document.
    // Create two documents, one for the first half and one for the second half
    final PdfDocument document1 =
        PdfDocument(inputBytes: File(widget.files[0].path).readAsBytesSync());
    final PdfDocument document2 =
        PdfDocument(inputBytes: File(widget.files[1].path).readAsBytesSync());

    // Merge documents and save the merged document temporarily.

    PdfDocument mergedDocument = PdfDocument();
    mergedDocument.pageSettings.setMargins(0.0);

    for (int i = 0; i < document1.pages.count; i++) {
      PdfPage page = document1.pages[i];
      PdfTemplate template = page.createTemplate();

      PdfPage destPage = mergedDocument.pages.add();

      Logger().d('height: ${page.size.height}');
      Logger().d('width: ${page.size.width}');
      Logger().d(page.size.height < page.size.width);
      if (page.size.height < page.size.width) {
        //destPage.rotation = PdfPageRotateAngle.rotateAngle90;
        //Logger().d('rotated');
      }

      destPage.graphics
          .drawPdfTemplate(template, const Offset(0, 0), destPage.size);

      Logger().d(mergedDocument.pages.count);
    }

    for (int i = 0; i < document2.pages.count; i++) {
      PdfPage page = document2.pages[i];
      PdfTemplate template = page.createTemplate();

      PdfPage destPage = mergedDocument.pages.add();

      Logger().d('height: ${page.size.height}');
      Logger().d('width: ${page.size.width}');
      Logger().d(page.size.height < page.size.width);
      if (page.size.height < page.size.width) {
        //destPage.rotation = PdfPageRotateAngle.rotateAngle270;
        //Logger().d('rotated');
      }

      destPage.graphics
          .drawPdfTemplate(template, const Offset(0, 0), destPage.size);

      Logger().d(mergedDocument.pages.count);
    }

    final tempDirectory = await getTemporaryDirectory();
    final outputPath = '${tempDirectory.path}/output.pdf';

    await File(outputPath)
        .writeAsBytes(await mergedDocument.save())
        .then((value) {
      setState(() {
        widget.files[0] = File(outputPath);
        widget.files.removeAt(1);
      });
    });

    //Dispose the documents.
    document1.dispose();
    document2.dispose();
    mergedDocument.dispose();

    // Show a snackbar to the user.
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Documents merged successfully.'),
      ),
    );
  }
}
