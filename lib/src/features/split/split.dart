import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pdfer/src/utils/pdf_view.dart';
import 'package:pdfer/src/utils/save_file.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';

class SplitView extends StatefulWidget {
  const SplitView({super.key, required this.files});

  final List<File> files;

  @override
  State<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  @override
  Widget build(BuildContext context) {
    TextEditingController pageNumberController = TextEditingController();

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
                  'Type in the page number from where you want to split your PDF document into two. The first PDF will contain the pages before the specified page number (exclusive), and the second PDF will contain the pages after the specified page number (inclusive).',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: () async {
                  await saveFiles(widget.files).then((value) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Files saved to "/storage/emulated/0/Download/output1.pdf" and "/storage/emulated/0/Download/output2.pdf"'),
                      ),
                    );
                    Logger().d(
                        'Files saved to "/storage/emulated/0/Download/output1.pdf" and "/storage/emulated/0/Download/output2.pdf"');
                  });

                  // Delete the temporary files
                  final tempDirectory = await getTemporaryDirectory();
                  final tempPath1 = '${tempDirectory.path}/output1.pdf';
                  final tempPath2 = '${tempDirectory.path}/output2.pdf';
                  if (await File(tempPath1).exists()) {
                    await File(tempPath1).delete().then((value) {
                      Logger().d('Temporary file 1 deleted');
                    });
                  }
                  if (await File(tempPath2).exists()) {
                    await File(tempPath2).delete().then((value) {
                      Logger().d('Temporary file 2 deleted');
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
            children: [
              Expanded(
                  child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: TextField(
                    controller: pageNumberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Page number',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              )),
              const SizedBox(width: 8),
              IconButton(
                  onPressed: () {
                    if (pageNumberController.text.isNotEmpty) {
                      splitDocument(int.parse(pageNumberController.text));
                    }
                    Logger().d(widget.files);
                  },
                  icon: const Icon(Icons.call_split),
                  tooltip: 'Split document'),
            ],
          ),
          const SizedBox(height: 16),
          PdfView(file: widget.files[0]),
        ],
      ),
    );
  }

  Future<void> splitDocument(int pageNumber) async {
    if (widget.files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file selected'),
        ),
      );
      Logger().e('No file selected');
      return;
    }

    // Load the existing PDF document.
    // Create two documents, one for the first half and one for the second half
    final PdfDocument document1 =
        PdfDocument(inputBytes: File(widget.files[0].path).readAsBytesSync());
    final PdfDocument document2 =
        PdfDocument(inputBytes: File(widget.files[0].path).readAsBytesSync());

    if (document1.pages.count <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document has only one page, not possible to split'),
        ),
      );
      Logger().e('Document has only one page, not possible to split');
      return;
    } else if (pageNumber > document1.pages.count) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Page number must not exceed the number of pages in the document (${document1.pages.count})'),
        ),
      );
      Logger()
          .e('Page number is greater than the number of pages in the document');
      return;
    } else if (pageNumber < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Page number must be greater than 0'),
        ),
      );
      Logger().e('Page number is less than 1');
      return;
    }

    // Remove the pages from the documents
    // Removal is done from the end of the document to the start to avoid index out of bounds. (Indexes change if counting starts from 0).
    // The first document will contain the pages before the specified page number (exclusive)
    for (int i = document1.pages.count - 1; i >= pageNumber - 1; i--) {
      document1.pages.removeAt(i);
    }
    // The second document will contain the pages after the specified page number (inclusive)
    for (int i = pageNumber - 2; i >= 0; i--) {
      document2.pages.removeAt(i);
    }

    //Save the documents
    final tempDirectory = await getTemporaryDirectory();
    final outputPath1 = '${tempDirectory.path}/output1.pdf';
    final outputPath2 = '${tempDirectory.path}/output2.pdf';

    await File(outputPath1).writeAsBytes(await document1.save()).then((value) {
      setState(() {
        widget.files[0] = File(outputPath1);
      });
    });

    await File(outputPath2).writeAsBytes(await document2.save()).then((value) {
      setState(() {
        widget.files.add(File(outputPath2));
      });
    });

    //Dispose the documents.
    document1.dispose();
    document2.dispose();

    // Show a snackbar to the user.
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document split successfully. First half shown.'),
      ),
    );
  }
}
